import AVFoundation
import os

/// Plays a string's note so you can tune by ear.
/// A plucked tone with overtones, not a pure sine: phone speakers barely reproduce a low string's fundamental,
/// but the ear hears the pitch from its harmonics.
@MainActor
final class ReferenceTone {
    private let engine = AVAudioEngine()
    /// The frequency to play, and a count that restarts the pluck on every tap. Read by the audio thread.
    private let pluck = OSAllocatedUnfairLock(initialState: (frequency: 0.0, count: 0))
    var a4 = 440.0

    init() {
        let rate = 48_000.0
        let pluck = pluck
        var phase = 0.0
        var time = 0.0
        var playing = 0
        let source = AVAudioSourceNode { _, _, frames, output in
            let (frequency, count) = pluck.withLock { $0 }
            if count != playing {
                playing = count
                phase = 0
                time = 0
            }
            for i in 0..<Int(frames) {
                let envelope = frequency > 0 ? min(time / 0.005, 1) * exp(-time / 0.8) : 0  // 5 ms attack, rings ~2 s
                var x = 0.0
                for h in 1...6 { x += sin(phase * Double(h)) / Double(h) }
                let sample = Float(0.45 * envelope * x)  // peaks below 0.9
                phase = (phase + 2 * .pi * frequency / rate).truncatingRemainder(dividingBy: 2 * .pi)
                time += 1 / rate
                for buffer in UnsafeMutableAudioBufferListPointer(output) { buffer.mData!.assumingMemoryBound(to: Float.self)[i] = sample }
            }
            return noErr
        }
        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1))
    }

    func play(_ midi: Int) {
        // The engine stops when the audio session changes (the tuner starting or stopping), so restart it on demand.
        if !engine.isRunning { try? engine.start() }
        let frequency = Note(midi: midi, a4: a4).frequency
        pluck.withLock { $0 = (frequency, $0.count + 1) }
    }
}
