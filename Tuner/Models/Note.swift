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
    /// The string (or pair of strings) of `tuning` this note is closest to; a 12-string's octave strings count for their pair.
    func nearestString(in tuning: Tuning) -> Int {
        func distance(to string: Int) -> Int {
            let octave = tuning.octaveString(of: string).map { abs($0 - midi) } ?? .max
            return min(abs(string - midi), octave)
        }
        return tuning.strings.min { distance(to: $0) < distance(to: $1) }!
    }
}
