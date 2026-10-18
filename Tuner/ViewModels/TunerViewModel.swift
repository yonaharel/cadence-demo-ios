import Combine
import Foundation
import Observation
import Sharing

/// What the tuner screen and its settings show and do: the saved setup, the live reading, and playing a string.
@MainActor @Observable
final class TunerViewModel {
    // Saved in app storage under the keys the app has always used, so updating keeps your setup.
    @ObservationIgnored @Shared(.appStorage("tuning")) var tuning = Tuning.standard
    /// The reference pitch, 415...466 Hz.
    @ObservationIgnored @Shared(.appStorage("a4")) var a4 = 440
    /// 0 (loud room) to 1 (quiet strings).
    @ObservationIgnored @Shared(.appStorage("sensitivity")) var sensitivity = 0.7

    private let listener = PitchListener()
    private let tone = ReferenceTone()
    @ObservationIgnored private var subscriptions: Set<AnyCancellable> = []

    init() {
        // Publishers send the current value first, so these also apply the saved settings at launch.
        $a4.publisher.sink { [weak self] a4 in self?.apply(a4: a4) }.store(in: &subscriptions)
        $sensitivity.publisher.sink { [weak self] s in self?.listener.sensitivity = Float(min(max(s, 0), 1)) }.store(in: &subscriptions)
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

    /// Clamped so a corrupt saved value can't reach Note.
    private func apply(a4: Int) {
        let hz = Double(min(max(a4, 415), 466))
        listener.a4 = hz
        tone.a4 = hz
    }
}
