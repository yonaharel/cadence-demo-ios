import SwiftUI

/// Selection that grows in: a tinted circle expands from the centre to fill the shape, and the border fades in as it lands.
struct SelectionHighlight: ViewModifier {
    let isSelected: Bool
    let cornerRadius: CGFloat
    @State private var fill: CGFloat = 0
    @State private var border = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        content
            .background {
                GeometryReader { geo in
                    let diameter = hypot(geo.size.width, geo.size.height)  // just covers the corners
                    Circle().fill(Color.accentColor.opacity(0.15))
                        .frame(width: diameter, height: diameter)
                        .scaleEffect(fill)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .clipShape(shape)
            }
            .overlay(shape.strokeBorder(Color.accentColor, lineWidth: 2).opacity(border))
            .onAppear {
                fill = isSelected ? 1 : 0
                border = fill
            }
            .onChange(of: isSelected) { _, selected in
                if reduceMotion {
                    withAnimation(.easeOut(duration: 0.2)) {
                        fill = selected ? 1 : 0
                        border = fill
                    }
                } else if selected {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { fill = 1 }
                    withAnimation(.easeOut(duration: 0.15).delay(0.2)) { border = 1 }  // as the fill lands
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        fill = 0
                        border = 0
                    }
                }
            }
    }
}

extension View {
    /// See `SelectionHighlight`.
    func selectionHighlight(_ isSelected: Bool, cornerRadius: CGFloat) -> some View {
        modifier(SelectionHighlight(isSelected: isSelected, cornerRadius: cornerRadius))
    }
}
