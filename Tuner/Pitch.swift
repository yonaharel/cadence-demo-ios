import Foundation

/// The nearest equal-tempered note to a frequency (A4 = 440 Hz), and how far off it is in cents.
struct Note: Equatable {
    static let names = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]

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
