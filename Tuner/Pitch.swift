import Foundation

/// The nearest equal-tempered note to a frequency, relative to `a4` (440 Hz unless set), and how far off it is in cents.
struct Note: Equatable {
    static let names = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]

    let midi: Int
    let cents: Double
    let frequency: Double

    init(frequency: Double, a4: Double = 440) {
        let exact = 69 + 12 * log2(frequency / a4)
        midi = Int(exact.rounded())
        cents = (exact - Double(midi)) * 100
        self.frequency = frequency
    }

    init(midi: Int, a4: Double = 440) { self.init(frequency: a4 * pow(2, Double(midi - 69) / 12), a4: a4) }

    var name: String { Note.names[((midi % 12) + 12) % 12] }
    var octave: Int { midi / 12 - 1 }
    /// The string of `tuning` this note is closest to.
    func nearestString(in tuning: Tuning) -> Int { tuning.strings.min { abs($0 - midi) < abs($1 - midi) }! }
}

/// Six-string guitar tunings. The raw value is what's saved, so don't rename cases.
enum Tuning: String, CaseIterable, Identifiable {
    case standard, halfStepDown, wholeStepDown, cStandard
    case dropD, dropCSharp, dropC, doubleDropD
    case openD, openE, openG, openA, openC
    case dadgad

    var id: Self { self }

    var name: String {
        switch self {
        case .standard: "Standard"
        case .halfStepDown: "Half step down"
        case .wholeStepDown: "Whole step down"
        case .cStandard: "C Standard"
        case .dropD: "Drop D"
        case .dropCSharp: "Drop C♯"
        case .dropC: "Drop C"
        case .doubleDropD: "Double Drop D"
        case .openD: "Open D"
        case .openE: "Open E"
        case .openG: "Open G"
        case .openA: "Open A"
        case .openC: "Open C"
        case .dadgad: "DADGAD"
        }
    }

    /// Low string to high, as MIDI note numbers.
    var strings: [Int] {
        switch self {
        case .standard: [40, 45, 50, 55, 59, 64]      // E A D G B E
        case .halfStepDown: [39, 44, 49, 54, 58, 63]  // E♭ A♭ D♭ G♭ B♭ E♭
        case .wholeStepDown: [38, 43, 48, 53, 57, 62] // D G C F A D
        case .cStandard: [36, 41, 46, 51, 55, 60]     // C F B♭ E♭ G C
        case .dropD: [38, 45, 50, 55, 59, 64]         // D A D G B E
        case .dropCSharp: [37, 44, 49, 54, 58, 63]    // C♯ G♯ C♯ F♯ A♯ D♯
        case .dropC: [36, 43, 48, 53, 57, 62]         // C G C F A D
        case .doubleDropD: [38, 45, 50, 55, 59, 62]   // D A D G B D
        case .openD: [38, 45, 50, 54, 57, 62]         // D A D F♯ A D
        case .openE: [40, 47, 52, 56, 59, 64]         // E B E G♯ B E
        case .openG: [38, 43, 50, 55, 59, 62]         // D G D G B D
        case .openA: [40, 45, 52, 57, 61, 64]         // E A E A C♯ E
        case .openC: [36, 43, 48, 55, 60, 64]         // C G C G C E
        case .dadgad: [38, 45, 50, 55, 57, 62]        // D A D G A D
        }
    }
}

/// Cuts mic rumble below `low` and hiss above `high` (outside guitar range), which would otherwise confuse YIN. Keeps state between calls: one per audio stream.
struct BandPass {
    private struct Biquad {
        var b0 = 0.0, b1 = 0.0, b2 = 0.0, a1 = 0.0, a2 = 0.0
        var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0

        // RBJ audio-EQ cookbook, Q = 1/√2 (Butterworth).
        init(sampleRate: Double, cutoff: Double, highPass: Bool) {
            let w = 2 * Double.pi * cutoff / sampleRate, alpha = sin(w) / (2 * 0.7071), c = cos(w)
            let a0 = 1 + alpha
            b0 = (highPass ? 1 + c : 1 - c) / 2 / a0
            b1 = (highPass ? -(1 + c) : 1 - c) / a0
            b2 = b0
            a1 = -2 * c / a0
            a2 = (1 - alpha) / a0
        }

        mutating func process(_ x: Double) -> Double {
            let y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
            x2 = x1; x1 = x; y2 = y1; y1 = y
            return y
        }
    }

    private var highPass: Biquad, lowPass: Biquad

    init(sampleRate: Double, low: Double = 55, high: Double = 1300) { // 55 Hz stays below C2 at A4=415 (61.7 Hz)
        highPass = Biquad(sampleRate: sampleRate, cutoff: low, highPass: true)
        lowPass = Biquad(sampleRate: sampleRate, cutoff: high, highPass: false)
    }

    mutating func process(_ samples: inout [Float]) {
        for i in samples.indices { samples[i] = Float(lowPass.process(highPass.process(Double(samples[i])))) }
    }
}

/// Steadies the needle: the median of the last few readings doesn't lag a retune, and a reading over a semitone away
/// is held back until three agree, so a stray octave jump never reaches the needle.
struct Smoother {
    private var history: [Double] = []
    private var pending: [Double] = []

    private static func cents(_ a: Double, _ b: Double) -> Double { abs(1200 * log2(a / b)) }
    private static func median(_ x: [Double]) -> Double { x.sorted()[x.count / 2] }

    /// The frequency to show, or nil while `frequency` is held back as a possible outlier.
    mutating func add(_ frequency: Double) -> Double? {
        if history.isEmpty || Self.cents(frequency, Self.median(history)) <= 100 {
            pending.removeAll()
            history = Array((history + [frequency]).suffix(5))
            return Self.median(history)
        }
        if let first = pending.first, Self.cents(frequency, first) <= 100 { pending.append(frequency) } else { pending = [frequency] }
        guard pending.count >= 3 else { return nil }
        history = pending
        pending.removeAll()
        return Self.median(history)
    }

    mutating func reset() { history.removeAll(); pending.removeAll() }
}

/// The fundamental frequency of `samples`, by YIN (de Cheveigné & Kawahara, 2002), or nil when there is no clear pitch.
func detectPitch(_ samples: [Float], sampleRate: Double, range: ClosedRange<Double> = 60...1200) -> Double? {
    let minLag = Int(sampleRate / range.upperBound), maxLag = Int(sampleRate / range.lowerBound)
    let window = samples.count - maxLag
    guard minLag > 1, window > 0 else { return nil }
    let rms = sqrt(samples.reduce(0) { $0 + $1 * $1 } / Float(samples.count))
    guard rms > 0.02 else { return nil } // too quiet to be a string

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
    guard cmnd[lag] < 0.1 else { return nil } // not periodic enough to trust

    // Parabolic interpolation between neighbouring lags for sub-sample precision.
    let a = cmnd[lag - 1], b = cmnd[lag], c = cmnd[lag + 1]
    let curve = a - 2 * b + c
    let shift = curve == 0 ? 0 : 0.5 * (a - c) / curve
    return sampleRate / (Double(lag) + Double(shift))
}
