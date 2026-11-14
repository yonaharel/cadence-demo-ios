import Foundation

/// Cuts mic rumble below `low` and hiss above `high` (outside the instrument's range), which would otherwise confuse YIN. Keeps state between calls: one per audio stream.
struct BandPass {
    private struct Biquad {
        var b0 = 0.0, b1 = 0.0, b2 = 0.0, a1 = 0.0, a2 = 0.0
        var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0

        init(sampleRate: Double, cutoff: Double, highPass: Bool) { setCutoff(cutoff, sampleRate: sampleRate, highPass: highPass) }

        /// RBJ audio-EQ cookbook, Q = 1/√2 (Butterworth). Sets the coefficients only: the state carries over,
        /// so moving the cutoff mid-stream doesn't click.
        mutating func setCutoff(_ cutoff: Double, sampleRate: Double, highPass: Bool) {
            let w = 2 * Double.pi * cutoff / sampleRate
            let alpha = sin(w) / (2 * 0.7071)
            let c = cos(w)
            let a0 = 1 + alpha
            b0 = (highPass ? 1 + c : 1 - c) / 2 / a0
            b1 = (highPass ? -(1 + c) : 1 - c) / a0
            b2 = b0
            a1 = -2 * c / a0
            a2 = (1 - alpha) / a0
        }

        mutating func process(_ x: Double) -> Double {
            let y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
            x2 = x1
            x1 = x
            y2 = y1
            y1 = y
            return y
        }
    }

    private var highPass: Biquad, lowPass: Biquad
    private let sampleRate: Double
    /// The high-pass cutoff. Lower it for bass; it can change between buffers.
    var low: Double {
        didSet {
            if low != oldValue { highPass.setCutoff(low, sampleRate: sampleRate, highPass: true) }
        }
    }

    init(sampleRate: Double, low: Double = 55, high: Double = 1300) {  // 55 Hz stays below C2 at A4=415 (61.7 Hz)
        self.sampleRate = sampleRate
        self.low = low
        highPass = Biquad(sampleRate: sampleRate, cutoff: low, highPass: true)
        lowPass = Biquad(sampleRate: sampleRate, cutoff: high, highPass: false)
    }

    mutating func process(_ samples: inout [Float]) {
        for i in samples.indices { samples[i] = Float(lowPass.process(highPass.process(Double(samples[i])))) }
    }
}
