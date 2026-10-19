import AVFoundation
import Observation
import os

/// Listens to the microphone and reports the note being played. Audio is analysed on the device and never stored.
@MainActor @Observable
final class PitchListener {
    enum State: Equatable {
        case idle, listening, denied
        case failed(String)
    }

    private(set) var state = State.idle
    private(set) var note: Note?
    /// False once the string has rung out; the last note stays on screen, dimmed.
    private(set) var hearing = false
    /// Cents per buffer, oldest first; nil where nothing confident was heard.
    private(set) var history: [Double?] = []
    var a4 = 440.0 {
        didSet {  // note and trace were measured against the old A4; demo keeps its fixed flat line
            guard demo == 0 else { return }
            history = []
            if let n = note { note = Note(frequency: n.frequency, a4: a4) }
        }
    }
    /// How loud the mic is (RMS after filtering), for the sensitivity meter.
    private(set) var level: Float = 0
    /// 0 (loud room) to 1 (quiet strings).
    var sensitivity: Float = 0.7 {
        didSet {
            let s = sensitivity
            tapSensitivity.withLock { $0 = s }
        }
    }
    /// The lowest pitch listened for, in Hz; it follows the tuning (see `Tuning.detectionFloor`).
    var detectionFloor = 60.0 {
        didSet {
            let floor = detectionFloor
            tapFloor.withLock { $0 = floor }
        }
    }
    static let historyLength = 60  // ~5 s at 4096 samples / 48 kHz

    private let engine = AVAudioEngine()
    private var smoother = Smoother()
    private let tapSensitivity = OSAllocatedUnfairLock(initialState: Float(0.7))  // read by the audio thread
    private let tapFloor = OSAllocatedUnfairLock(initialState: 60.0)  // read by the audio thread
    private var quietFrames = 0
    private let demo = UserDefaults.standard.double(forKey: "demoFrequency")
    /// The permission alert makes the scene inactive then active, which calls start() again while the first call waits.
    private var starting = false

    init() {
        // App Store screenshots: launch with `-demoFrequency 108.9` for a fixed reading without the microphone.
        if demo > 0 {
            note = Note(frequency: demo)
            hearing = true
            state = .listening
            history = Array(repeating: note!.cents, count: Self.historyLength)
        }
    }

    func start() async {
        guard demo == 0, state == .idle, !starting else { return }
        starting = true
        defer { starting = false }
        guard await AVAudioApplication.requestRecordPermission() else {
            state = .denied
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            // playAndRecord so ReferenceTone can play while listening; the speaker, not the earpiece.
            try session.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            // iOS silences haptics while an app records; the tuner always records, so opt back in.
            try session.setAllowHapticsAndSystemSoundsDuringRecording(true)
            try session.setActive(true)
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.installTap(
                onBus: 0, bufferSize: 4096, format: format,
                block: Self.analyser(sampleRate: format.sampleRate, sensitivity: tapSensitivity, floor: tapFloor) { [weak self] pitch, level in
                    Task { @MainActor in
                        self?.level = level
                        self?.heard(pitch)
                    }
                })
            try engine.start()
            state = .listening
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func stop() {
        guard demo == 0, state == .listening else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
        state = .idle
        // Resume with a gap, not joined to the old trace.
        history = []
        smoother.reset()
        quietFrames = 0
        hearing = false
        level = 0
    }

    /// Built outside the main actor: the tap runs on an audio thread.
    private nonisolated static func analyser(
        sampleRate: Double, sensitivity: OSAllocatedUnfairLock<Float>, floor: OSAllocatedUnfairLock<Double>,
        report: @escaping @Sendable (Double?, Float) -> Void
    ) -> AVAudioNodeTapBlock {
        var filter = BandPass(sampleRate: sampleRate)  // fresh per tap; keeps its state across buffers
        return { buffer, _ in
            guard let data = buffer.floatChannelData?[0] else { return }
            var samples = Array(UnsafeBufferPointer(start: data, count: Int(buffer.frameLength)))
            filter.process(&samples)
            let range = floor.withLock { $0 }...1200
            report(detectPitch(samples, sampleRate: sampleRate, range: range, sensitivity: sensitivity.withLock { $0 }), rms(samples))
        }
    }

    private func heard(_ pitch: Double?) {
        guard let pitch else {
            record(nil)
            quietFrames += 1
            if quietFrames > 10 {
                hearing = false
                smoother.reset()
            }
            return
        }
        quietFrames = 0
        hearing = true
        guard let f = smoother.add(pitch) else {
            record(nil)
            return
        }
        let new = Note(frequency: f, a4: a4)
        if new.midi != note?.midi { history = [] }
        record(new.cents)
        note = new
    }

    // shortcut: one entry per buffer, so the strip steps ~12×/s; move to timestamps + TimelineView if it looks choppy
    private func record(_ cents: Double?) {
        if cents == nil, !history.contains(where: { $0 != nil }) { return }  // already blank; don't re-render
        history = Array((history + [cents]).suffix(Self.historyLength))
    }
}
