import Foundation

/// The RMS of `samples`: how loud the mic is.
func rms(_ samples: [Float]) -> Float { sqrt(samples.reduce(0) { $0 + $1 * $1 } / Float(max(samples.count, 1))) }

/// The quietest level treated as a string, for a sensitivity from 0 (loud room) to 1 (quiet strings).
func minimumLevel(sensitivity: Float) -> Float { 0.03 * pow(0.1, min(max(sensitivity, 0), 1)) }

/// The fundamental frequency of `samples`, by YIN (de Cheveigné & Kawahara, 2002), or nil when there is no clear pitch.
/// `sensitivity` (0...1) trades rejecting room noise for hearing quiet, less clear strings.
func detectPitch(_ samples: [Float], sampleRate: Double, range: ClosedRange<Double> = 60...1200, sensitivity: Float = 0.7) -> Double? {
    let minLag = Int(sampleRate / range.upperBound), maxLag = Int(sampleRate / range.lowerBound)
    let window = samples.count - maxLag
    guard minLag > 1, window > 0 else { return nil }
    guard rms(samples) > minimumLevel(sensitivity: sensitivity) else { return nil }  // too quiet to be a string

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
    guard cmnd[lag] < 0.08 + 0.07 * min(max(sensitivity, 0), 1) else { return nil }  // not periodic enough to trust

    // Parabolic interpolation between neighbouring lags for sub-sample precision.
    let a = cmnd[lag - 1], b = cmnd[lag], c = cmnd[lag + 1]
    let curve = a - 2 * b + c
    let shift = curve == 0 ? 0 : 0.5 * (a - c) / curve
    return sampleRate / (Double(lag) + Double(shift))
}
