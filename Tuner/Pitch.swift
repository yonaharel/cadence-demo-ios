import Foundation

/// The nearest equal-tempered note to a frequency (A4 = 440 Hz), and how far off it is in cents.
struct Note: Equatable {
    static let names = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    /// Standard guitar tuning, low to high, as MIDI note numbers.
    static let guitar = [40, 45, 50, 55, 59, 64]

    let midi: Int
    let cents: Double
    let frequency: Double

    init(frequency: Double) {
        let exact = 69 + 12 * log2(frequency / 440)
        midi = Int(exact.rounded())
        cents = (exact - Double(midi)) * 100
        self.frequency = frequency
    }

    init(midi: Int) { self.init(frequency: 440 * pow(2, Double(midi - 69) / 12)) }

    var name: String { Note.names[((midi % 12) + 12) % 12] }
    var octave: Int { midi / 12 - 1 }
    /// The guitar string this note is closest to.
    var nearestString: Int { Note.guitar.min { abs($0 - midi) < abs($1 - midi) }! }
}

/// The fundamental frequency of `samples`, by YIN (de Cheveigné & Kawahara, 2002), or nil when there is no clear pitch.
func detectPitch(_ samples: [Float], sampleRate: Double, range: ClosedRange<Double> = 60...1200) -> Double? {
    let minLag = Int(sampleRate / range.upperBound), maxLag = Int(sampleRate / range.lowerBound)
    let window = samples.count - maxLag
    guard minLag > 1, window > 0 else { return nil }
    let rms = sqrt(samples.reduce(0) { $0 + $1 * $1 } / Float(samples.count))
    guard rms > 0.01 else { return nil } // too quiet to be a string

    var diff = [Float](repeating: 0, count: maxLag + 1)
    samples.withUnsafeBufferPointer { x in
        for lag in 1...maxLag {
            var sum: Float = 0
            for j in 0..<window { let d = x[j] - x[j + lag]; sum += d * d }
            diff[lag] = sum
        }
    }
    // Cumulative mean normalised difference: the first dip under the threshold is the period.
    var cmnd = [Float](repeating: 1, count: maxLag + 1), running: Float = 0
    for lag in 1...maxLag {
        running += diff[lag]
        cmnd[lag] = running > 0 ? diff[lag] * Float(lag) / running : 1
    }
    var lag = minLag
    while lag < maxLag, cmnd[lag] >= 0.15 { lag += 1 }
    guard lag < maxLag else { return nil }
    while lag + 1 < maxLag, cmnd[lag + 1] < cmnd[lag] { lag += 1 }

    // Parabolic interpolation between neighbouring lags for sub-sample precision.
    let a = cmnd[lag - 1], b = cmnd[lag], c = cmnd[lag + 1]
    let curve = a - 2 * b + c
    let shift = curve == 0 ? 0 : 0.5 * (a - c) / curve
    return sampleRate / (Double(lag) + Double(shift))
}
