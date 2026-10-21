import Foundation

/// Tunings for every instrument. The raw value is what's saved, so don't rename cases.
enum Tuning: String, CaseIterable, Identifiable {
    // Guitar
    case standard, halfStepDown, wholeStepDown, cStandard
    case dropD, dropCSharp, dropC, doubleDropD
    case openD, openE, openG, openA, openC
    case dadgad
    // 7-string guitar
    case sevenStandard, sevenDropA, sevenHalfStepDown
    // 12-string guitar
    case twelveStandard, twelveDropD, twelveHalfStepDown
    // Ukulele
    case ukuleleStandard, ukuleleLowG, ukuleleBaritone, ukuleleD
    // Mandolin
    case mandolinStandard
    // 5-string banjo
    case banjoOpenG, banjoDoubleC, banjoOpenD, banjoC
    // Bass
    case bassStandard, bassDropD, bassHalfStepDown
    case fiveBassStandard
    case sixBassStandard

    var id: Self { self }

    var instrument: Instrument {
        switch self {
        case .standard, .halfStepDown, .wholeStepDown, .cStandard, .dropD, .dropCSharp, .dropC, .doubleDropD,
            .openD, .openE, .openG, .openA, .openC, .dadgad:
            .guitar
        case .sevenStandard, .sevenDropA, .sevenHalfStepDown: .sevenString
        case .twelveStandard, .twelveDropD, .twelveHalfStepDown: .twelveString
        case .ukuleleStandard, .ukuleleLowG, .ukuleleBaritone, .ukuleleD: .ukulele
        case .mandolinStandard: .mandolin
        case .banjoOpenG, .banjoDoubleC, .banjoOpenD, .banjoC: .banjo
        case .bassStandard, .bassDropD, .bassHalfStepDown: .bass
        case .fiveBassStandard: .fiveStringBass
        case .sixBassStandard: .sixStringBass
        }
    }

    var name: String {
        switch self {
        case .standard, .sevenStandard, .twelveStandard, .ukuleleStandard, .mandolinStandard, .bassStandard, .fiveBassStandard,
            .sixBassStandard:
            "Standard"
        case .halfStepDown, .sevenHalfStepDown, .twelveHalfStepDown, .bassHalfStepDown: "Half step down"
        case .wholeStepDown: "Whole step down"
        case .cStandard: "C Standard"
        case .dropD, .twelveDropD, .bassDropD: "Drop D"
        case .dropCSharp: "Drop C♯"
        case .dropC: "Drop C"
        case .doubleDropD: "Double Drop D"
        case .openD, .banjoOpenD: "Open D"
        case .openE: "Open E"
        case .openG, .banjoOpenG: "Open G"
        case .openA: "Open A"
        case .openC: "Open C"
        case .dadgad: "DADGAD"
        case .sevenDropA: "Drop A"
        case .ukuleleLowG: "Low G"
        case .ukuleleBaritone: "Baritone"
        case .ukuleleD: "D tuning"
        case .banjoDoubleC: "Double C"
        case .banjoC: "C tuning"
        }
    }

    /// The strings as MIDI note numbers, in the order they're shown: low to high, except that a ukulele's high G
    /// and a banjo's short drone string keep their place on the neck. A 12-string or mandolin lists one note per pair.
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
        case .sevenStandard: [35, 40, 45, 50, 55, 59, 64]  // B E A D G B E
        case .sevenDropA: [33, 40, 45, 50, 55, 59, 64]  // A E A D G B E
        case .sevenHalfStepDown: [34, 39, 44, 49, 54, 58, 63]  // B♭ E♭ A♭ D♭ G♭ B♭ E♭
        case .twelveStandard: [40, 45, 50, 55, 59, 64]  // E A D G B E
        case .twelveDropD: [38, 45, 50, 55, 59, 64]  // D A D G B E
        case .twelveHalfStepDown: [39, 44, 49, 54, 58, 63]  // E♭ A♭ D♭ G♭ B♭ E♭
        case .ukuleleStandard: [67, 60, 64, 69]  // G C E A, high G
        case .ukuleleLowG: [55, 60, 64, 69]  // G C E A, low G
        case .ukuleleBaritone: [50, 55, 59, 64]  // D G B E
        case .ukuleleD: [69, 62, 66, 71]  // A D F♯ B
        case .mandolinStandard: [55, 62, 69, 76]  // G D A E
        case .banjoOpenG: [67, 50, 55, 59, 62]  // G D G B D
        case .banjoDoubleC: [67, 48, 55, 60, 62]  // G C G C D
        case .banjoOpenD: [66, 50, 54, 57, 62]  // F♯ D F♯ A D
        case .banjoC: [67, 48, 55, 59, 62]  // G C G B D
        case .bassStandard: [28, 33, 38, 43]  // E A D G
        case .bassDropD: [26, 33, 38, 43]  // D A D G
        case .bassHalfStepDown: [27, 32, 37, 42]  // E♭ A♭ D♭ G♭
        case .fiveBassStandard: [23, 28, 33, 38, 43]  // B E A D G
        case .sixBassStandard: [23, 28, 33, 38, 43, 48]  // B E A D G C
        }
    }

    /// The octave string paired with `string` on a 12-string: the four lowest pairs have one; the top two are in unison.
    func octaveString(of string: Int) -> Int? {
        guard instrument == .twelveString, let index = strings.firstIndex(of: string), index < 4 else { return nil }
        return string + 12
    }

    /// The lowest pitch worth listening for: just below the lowest string, so a slack string still registers,
    /// but never above 60 Hz, so guitars keep ignoring 50 Hz mains hum. A bass listens down to ~25 Hz (low B at A4=415).
    func detectionFloor(a4: Double) -> Double {
        min(60, Note(midi: strings.min()!, a4: a4).frequency * 0.85)
    }
}
