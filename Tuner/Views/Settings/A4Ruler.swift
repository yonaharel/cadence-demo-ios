import SwiftUI

/// A ruler you drag to set A4, snapping to each hertz; 432 and 442 are dotted. Double-tap the value for 440.
struct A4Ruler: View {
    @Binding var a4: Int
    @State private var position: Int?
    private let step: CGFloat = 12

    var body: some View {
        VStack(spacing: 6) {
            Text("\(a4) Hz").font(.title.weight(.semibold).monospacedDigit())
                .contentTransition(.numericText(value: Double(a4)))
                .animation(.snappy(duration: 0.25), value: a4) // numericText only rolls inside an animation; dragging changes a4 without one
                .onTapGesture(count: 2) { a4 = 440 }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) { // beside the value, so the number stays centred over the ruler
                    if a4 != 440 {
                        Button { withAnimation { a4 = 440 } } label: {
                            Label("440", systemImage: "arrow.counterclockwise").font(.footnote.weight(.semibold))
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .accessibilityLabel("Reset to 440 hertz")
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: a4 == 440)
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(415...466, id: \.self) { hz in
                            VStack(spacing: 3) {
                                Capsule().fill(Color.secondary.opacity(hz % 10 == 0 ? 0.8 : 0.4)).frame(width: 1.5, height: hz % 10 == 0 ? 20 : 12)
                                Circle().fill(Color.secondary).frame(width: 4, height: 4).opacity(hz == 432 || hz == 442 ? 1 : 0)
                                Text(hz % 10 == 0 ? "\(hz)" : " ").font(.caption2).foregroundStyle(.secondary).fixedSize()
                            }
                            .frame(width: step, height: 46, alignment: .top)
                            .id(hz)
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(.horizontal, (geo.size.width - step) / 2)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $position, anchor: .center)
                .overlay(alignment: .top) { Capsule().fill(Color.accentColor).frame(width: 3, height: 26).offset(y: -3).allowsHitTesting(false) }
            }
            .frame(height: 46)
        }
        .padding(.vertical, 4)
        .onAppear { position = a4 }
        .onChange(of: position) { if let position, position != a4 { a4 = position } }
        .onChange(of: a4) { if position != a4 { withAnimation { position = a4 } } }
        .sensoryFeedback(.selection, trigger: a4)
        .accessibilityElement()
        .accessibilityLabel("Reference pitch")
        .accessibilityValue("A4 \(a4) hertz")
        .accessibilityAdjustableAction { direction in a4 = min(max(a4 + (direction == .increment ? 1 : -1), 415), 466) }
        .accessibilityAction(named: "Reset to 440") { a4 = 440 }
    }
}
