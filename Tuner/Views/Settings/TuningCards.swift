import SwiftUI

/// The current instrument's tunings as cards to swipe through; each shows its strings so you can see what you're picking.
struct TuningCards: View {
    @Binding var tuning: Tuning

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tuning.instrument.tunings) { t in
                        let notes = t.strings.map { Note(midi: $0).name }.joined(separator: " ")
                        Button {
                            tuning = t
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.name).font(.subheadline.weight(.semibold))
                                Text(notes).font(.caption.monospaced()).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(0.1)))
                            .selectionHighlight(t == tuning, cornerRadius: 14)
                            .foregroundStyle(t == tuning ? Color.accentColor : Color.primary)
                        }
                        .buttonStyle(.pressScale)
                        .id(t)
                        .accessibilityLabel("\(t.name), \(notes)")
                        .accessibilityAddTraits(t == tuning ? .isSelected : [])
                    }
                }
                .padding(12)
            }
            .onAppear { proxy.scrollTo(tuning, anchor: .center) }
            .onChange(of: tuning.instrument) { proxy.scrollTo(tuning, anchor: .leading) }
        }
        .sensoryFeedback(.selection, trigger: tuning)
    }
}
