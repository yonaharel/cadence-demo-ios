import SwiftUI

/// The tuning's strings; the one being tuned is highlighted. Tap one to hear its note.
/// A 12-string shows one button per pair, with the pair's octave string underneath.
struct Strings: View {
    let tuning: Tuning
    let active: Int?
    let play: (Int) -> Void

    /// Seven strings need smaller buttons to fit across a phone.
    private var size: CGFloat { tuning.strings.count > 6 ? 40 : 46 }

    var body: some View {
        HStack(spacing: tuning.strings.count > 6 ? 8 : 12) {
            ForEach(tuning.strings, id: \.self) { midi in
                let note = Note(midi: midi)
                let octave = tuning.octaveString(of: midi).map { Note(midi: $0) }
                Button {
                    play(midi)
                } label: {
                    VStack(spacing: -2) {
                        Text("\(note.name)\(Text("\(note.octave)").font(.caption2))")
                            .font(.headline)
                        if let octave {
                            Text("\(octave.name)\(octave.octave)").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: size, height: size)
                    .background(Circle().fill(Color.secondary.opacity(0.15)))
                    .selectionHighlight(midi == active, cornerRadius: size / 2)
                    .foregroundStyle(midi == active ? Color.accentColor : Color.primary)
                }
                .buttonStyle(.pressScale)
                .accessibilityLabel(label(note: note, octave: octave, active: midi == active))
                .accessibilityHint("Plays the note")
            }
        }
        .animation(.easeOut(duration: 0.15), value: active)
        .animation(.easeOut(duration: 0.15), value: tuning)
    }

    private func label(note: Note, octave: Note?, active: Bool) -> String {
        let strings = octave.map { "\(note.name) \(note.octave) and \($0.name) \($0.octave) strings" } ?? "\(note.name) \(note.octave) string"
        return active ? "\(strings), tuning" : strings
    }
}
