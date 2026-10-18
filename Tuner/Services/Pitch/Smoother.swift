import Foundation

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

    mutating func reset() {
        history.removeAll()
        pending.removeAll()
    }
}
