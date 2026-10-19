import Foundation

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
        case .standard: [40, 45, 50, 55, 59, 64]  // E A D G B E
        case .halfStepDown: [39, 44, 49, 54, 58, 63]  // E♭ A♭ D♭ G♭ B♭ E♭
        case .wholeStepDown: [38, 43, 48, 53, 57, 62]  // D G C F A D
        case .cStandard: [36, 41, 46, 51, 55, 60]  // C F B♭ E♭ G C
        case .dropD: [38, 45, 50, 55, 59, 64]  // D A D G B E
        case .dropCSharp: [37, 44, 49, 54, 58, 63]  // C♯ G♯ C♯ F♯ A♯ D♯
        case .dropC: [36, 43, 48, 53, 57, 62]  // C G C F A D
        case .doubleDropD: [38, 45, 50, 55, 59, 62]  // D A D G B D
        case .openD: [38, 45, 50, 54, 57, 62]  // D A D F♯ A D
        case .openE: [40, 47, 52, 56, 59, 64]  // E B E G♯ B E
        case .openG: [38, 43, 50, 55, 59, 62]  // D G D G B D
        case .openA: [40, 45, 52, 57, 61, 64]  // E A E A C♯ E
        case .openC: [36, 43, 48, 55, 60, 64]  // C G C G C E
        case .dadgad: [38, 45, 50, 55, 57, 62]  // D A D G A D
        }
    }
}
