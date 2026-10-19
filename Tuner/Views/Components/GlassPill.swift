import SwiftUI

extension View {
    /// Liquid Glass on iOS 26; a bordered capsule before it.
    @ViewBuilder func glassPill() -> some View {
        if #available(iOS 26, *) { buttonStyle(.glass) } else { buttonStyle(.bordered).buttonBorderShape(.capsule) }
    }
}
