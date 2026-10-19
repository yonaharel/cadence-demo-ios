import SwiftUI

/// Springs a view in when it appears, a beat after the item before it, so a row fills in one item after another.
/// Give the row a new identity (`.id(...)`) to replay it, as the string buttons and tuning cards do on an instrument change.
struct StaggeredAppear: ViewModifier {
    let index: Int
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(shown || reduceMotion ? 1 : 0.6)
            .opacity(shown || reduceMotion ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65).delay(Double(index) * 0.05)) {
                    shown = true
                }
            }
    }
}

extension View {
    /// See `StaggeredAppear`.
    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppear(index: index))
    }
}
