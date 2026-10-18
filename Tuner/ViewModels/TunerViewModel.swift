import Foundation
import Observation

/// What the tuner screen and its settings show and do: the saved setup, the live reading, and playing a string.
@MainActor @Observable
final class TunerViewModel {
    var tuning: Tuning { didSet { defaults.set(tuning.rawValue, forKey: "tuning") } }
    /// The reference pitch, 415...466 Hz.
    var a4: Int { didSet { defaults.set(a4, forKey: "a4"); applyA4() } }
    /// 0 (loud room) to 1 (quiet strings).
    var sensitivity: Double { didSet { defaults.set(sensitivity, forKey: "sensitivity"); listener.sensitivity = Float(sensitivity) } }

    private let listener = PitchListener()
    private let tone = ReferenceTone()
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // The keys and values the app saved before this view model existed. Clamped so a corrupt value can't reach Note.
        tuning = defaults.string(forKey: "tuning").flatMap(Tuning.init(rawValue:)) ?? .standard
        a4 = min(max(defaults.object(forKey: "a4") as? Int ?? 440, 415), 466)
        sensitivity = min(max(defaults.object(forKey: "sensitivity") as? Double ?? 0.7, 0), 1)
        applyA4()
        listener.sensitivity = Float(sensitivity)
    }

    // The live reading, passed through from the listener.
    var state: PitchListener.State { listener.state }
    var note: Note? { listener.note }
    var hearing: Bool { listener.hearing }
    var history: [Double?] { listener.history }
    var level: Float { listener.level }

    /// The string being tuned, while one is ringing.
    var activeString: Int? { hearing ? note?.nearestString(in: tuning) : nil }
    var summary: String { "\(tuning.name) · A4 \(a4)" }
    /// The mic level the tuner starts listening at, for the sensitivity meter.
    var listeningLevel: Float { minimumLevel(sensitivity: Float(sensitivity)) }

    func start() async { await listener.start() }
    func stop() { listener.stop() }
    func play(_ string: Int) { tone.play(string) }

    private func applyA4() {
        listener.a4 = Double(a4)
        tone.a4 = Double(a4)
    }
}
