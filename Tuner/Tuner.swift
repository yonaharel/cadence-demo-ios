import AVFoundation
import Observation

/// Listens to the microphone and reports the note being played. Audio is analysed on the device and never stored.
@MainActor @Observable
final class Tuner {
    enum State: Equatable { case idle, listening, denied, failed(String) }

    private(set) var state = State.idle
    private(set) var note: Note?
    /// False once the string has rung out; the last note stays on screen, dimmed.
    private(set) var hearing = false
    /// Cents per buffer, oldest first; nil where nothing confident was heard.
    private(set) var history: [Double?] = []
    var a4 = 440.0
    static let historyLength = 60 // ~5 s at 4096 samples / 48 kHz

    private let engine = AVAudioEngine()
    private var smoother = Smoother()
    private var quietFrames = 0
    private let demo = UserDefaults.standard.double(forKey: "demoFrequency")
    /// The permission alert makes the scene inactive then active, which calls start() again while the first call waits.
    private var starting = false

    init() {
        // App Store screenshots: launch with `-demoFrequency 108.9` for a fixed reading without the microphone.
        if demo > 0 { note = Note(frequency: demo); hearing = true; state = .listening
            history = Array(repeating: note!.cents, count: Self.historyLength)
        }
    }

    func start() async {
        guard demo == 0, state == .idle, !starting else { return }
        starting = true
        defer { starting = false }
        guard await AVAudioApplication.requestRecordPermission() else { state = .denied; return }
        do {
            let session = AVAudioSession.sharedInstance()
            // playAndRecord so ReferenceTone can play while listening; the speaker, not the earpiece.
            try session.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try session.setActive(true)
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 4096, format: format, block: Self.analyser(sampleRate: format.sampleRate) { [weak self] pitch in
                Task { @MainActor in self?.heard(pitch) }
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
    }

    /// Built outside the main actor: the tap runs on an audio thread.
    private nonisolated static func analyser(sampleRate: Double, report: @escaping @Sendable (Double?) -> Void) -> AVAudioNodeTapBlock {
        var filter = BandPass(sampleRate: sampleRate) // fresh per tap; keeps its state across buffers
        return { buffer, _ in
            guard let data = buffer.floatChannelData?[0] else { return }
            var samples = Array(UnsafeBufferPointer(start: data, count: Int(buffer.frameLength)))
            filter.process(&samples)
            report(detectPitch(samples, sampleRate: sampleRate))
        }
    }

    private func heard(_ pitch: Double?) {
        guard let pitch else {
            record(nil)
            quietFrames += 1
            if quietFrames > 10 { hearing = false; smoother.reset() }
            return
        }
        quietFrames = 0
        hearing = true
        guard let f = smoother.add(pitch) else { record(nil); return }
        let new = Note(frequency: f, a4: a4)
        if new.midi != note?.midi { history = [] }
        record(new.cents)
        note = new
    }

    // shortcut: one entry per buffer, so the strip steps ~12×/s; move to timestamps + TimelineView if it looks choppy
    private func record(_ cents: Double?) {
        history = Array((history + [cents]).suffix(Self.historyLength))
    }
}

/// Plays a string's note so you can tune by ear.
@MainActor
final class ReferenceTone {
    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler() // with no instrument loaded it plays a plain sine tone
    private var release: Task<Void, Never>?
    /// Retunes the sampler so the strings' notes follow the reference pitch.
    var a4 = 440.0 { didSet { sampler.globalTuning = Float(1200 * log2(a4 / 440)) } }

    init() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
    }

    func play(_ midi: Int) {
        // The engine stops when the audio session changes (the tuner starting or stopping), so restart it on demand.
        if !engine.isRunning { try? engine.start() }
        release?.cancel()
        sampler.sendController(123, withValue: 0, onChannel: 0) // all notes off
        sampler.startNote(UInt8(midi), withVelocity: 110, onChannel: 0)
        release = Task {
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled { sampler.stopNote(UInt8(midi), onChannel: 0) }
        }
    }
}
