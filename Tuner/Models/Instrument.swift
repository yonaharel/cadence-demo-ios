import Foundation

/// What you're tuning. Each tuning belongs to one instrument; the raw value is never saved (the tuning is).
enum Instrument: String, CaseIterable, Identifiable {
    case guitar
    case sevenString
    case twelveString
    case ukulele
    case mandolin
    case banjo
    case bass
    case fiveStringBass
    case sixStringBass

    var id: Self { self }

    var name: String {
        switch self {
        case .guitar: "Guitar"
        case .sevenString: "7-string"
        case .twelveString: "12-string"
        case .ukulele: "Ukulele"
        case .mandolin: "Mandolin"
        case .banjo: "Banjo"
        case .bass: "Bass"
        case .fiveStringBass: "5-string bass"
        case .sixStringBass: "6-string bass"
        }
    }

    /// Its tunings, standard first.
    var tunings: [Tuning] { Tuning.allCases.filter { $0.instrument == self } }

    /// How many buttons its tunings have: one per string, or per pair of strings on a 12-string or mandolin.
    var stringCount: Int {
        switch self {
        case .guitar, .twelveString, .sixStringBass: 6
        case .sevenString: 7
        case .ukulele, .mandolin, .bass: 4
        case .banjo, .fiveStringBass: 5
        }
    }
}
