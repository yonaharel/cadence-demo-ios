import SwiftUI

/// Instrument chips above the tuning cards. Picking another instrument switches to its standard tuning.
struct InstrumentPicker: View {
    @Binding var tuning: Tuning

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Instrument.allCases) { instrument in
                        let selected = instrument == tuning.instrument
                        Button {
                            if !selected { tuning = instrument.tunings[0] }
                        } label: {
                            Text(instrument.name)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.secondary.opacity(0.1)))
                                .selectionHighlight(selected, cornerRadius: 20)
                                .foregroundStyle(selected ? Color.accentColor : Color.primary)
                        }
                        .buttonStyle(.pressScale)
                        .id(instrument)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                .padding(12)
            }
            .onAppear { proxy.scrollTo(tuning.instrument, anchor: .center) }
        }
        .sensoryFeedback(.selection, trigger: tuning.instrument)
    }
}
