import SwiftUI

/// The six strings of the tuning; the one being tuned is filled. Tap one to hear its note.
struct Strings: View {
    let tuning: Tuning
    let active: Int?
    let play: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(tuning.strings, id: \.self) { midi in
                let note = Note(midi: midi)
                Button {
                    play(midi)
                } label: {
                    Text("\(note.name)\(Text("\(note.octave)").font(.caption2))")
                        .font(.headline)
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(Color.secondary.opacity(0.15)))
                        .selectionHighlight(midi == active, cornerRadius: 23)
                        .foregroundStyle(midi == active ? Color.accentColor : Color.primary)
                }
                .buttonStyle(.pressScale)
                .accessibilityLabel("\(note.name) \(note.octave) string\(midi == active ? ", tuning" : "")")
                .accessibilityHint("Plays the note")
            }
        }
        .animation(.easeOut(duration: 0.15), value: active)
        .animation(.easeOut(duration: 0.15), value: tuning)
    }
}
