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

    private let engine = AVAudioEngine()
    private var recent: [Double] = []
    private var quietFrames = 0
    private let demo = UserDefaults.standard.double(forKey: "demoFrequency")

    init() {
        // App Store screenshots: launch with `-demoFrequency 108.9` for a fixed reading without the microphone.
        if demo > 0 { note = Note(frequency: demo); hearing = true; state = .listening }
    }

    func start() async {
        guard demo == 0, state == .idle else { return }
        guard await AVAudioApplication.requestRecordPermission() else { state = .denied; return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
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
        { buffer, _ in
            guard let data = buffer.floatChannelData?[0] else { return }
            report(detectPitch(Array(UnsafeBufferPointer(start: data, count: Int(buffer.frameLength))), sampleRate: sampleRate))
        }
    }

    private func heard(_ pitch: Double?) {
        guard let pitch else {
            quietFrames += 1
            if quietFrames > 10 { hearing = false; recent.removeAll() }
            return
        }
        quietFrames = 0
        hearing = true
        // The median of the last few readings steadies the needle without lagging behind a retune.
        recent = Array((recent + [pitch]).suffix(5))
        note = Note(frequency: recent.sorted()[recent.count / 2])
    }
}
