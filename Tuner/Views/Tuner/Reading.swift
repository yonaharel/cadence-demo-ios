import SwiftUI

/// The note, a cents needle, and what to do about it.
struct Reading: View {
    let note: Note?
    let hearing: Bool
    let history: [Double?]

    private var inTune: Bool { abs(note?.cents ?? 99) <= 5 }
    private var advice: String {
        guard let note, hearing else { return "Play a string" }
        if inTune { return "In tune" }
        return note.cents < 0 ? "Flat · tune up" : "Sharp · tune down"
    }

    var body: some View {
        VStack(spacing: 28) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(note?.name ?? "–").font(.system(size: 120, weight: .bold, design: .rounded))
                if let note { Text("\(note.octave)").font(.system(size: 36, weight: .semibold, design: .rounded)).foregroundStyle(.secondary) }
            }
            .contentTransition(.numericText())
            Needle(cents: hearing ? note?.cents : nil, inTune: inTune)
            History(cents: history)
            VStack(spacing: 6) {
                Text(advice).font(.title2.weight(.semibold)).foregroundStyle(hearing && inTune ? Color.green : Color.primary)
                if let note {
                    Text(String(format: "%.1f Hz · %+.0f ¢", note.frequency, note.cents))
                        .font(.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .opacity(hearing ? 1 : 0.45)
        .animation(.easeOut(duration: 0.2), value: hearing)
        .accessibilityElement(children: .combine)
    }
}
