import SwiftUI

/// Two panes for the open iPhone Duo: split along the screen's long side, or at the fold while it's half-folded,
/// so neither pane sits across the crease (one above, one below when it stands like a laptop).
struct FoldSplit<Primary: View, Secondary: View>: View {
    @ViewBuilder let primary: Primary
    @ViewBuilder let secondary: Secondary

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let fold = Self.fold(in: proxy)
            // A tall fold splits left and right; a wide one splits top and bottom.
            let sideBySide = fold.map { $0.height > $0.width } ?? (size.width > size.height)
            let layout = sideBySide ? AnyLayout(HStackLayout(spacing: 0)) : AnyLayout(VStackLayout(spacing: 0))
            layout {
                primary
                    .frame(width: sideBySide ? fold?.minX ?? size.width / 2 : nil, height: sideBySide ? nil : fold?.minY)
                    // Stacked with no fold, the first pane takes the height it needs and the second scrolls in the rest.
                    .fixedSize(horizontal: false, vertical: !sideBySide && fold == nil)
                if let fold {
                    Color.clear.frame(width: sideBySide ? fold.width : nil, height: sideBySide ? nil : fold.height)
                } else {
                    Divider()
                }
                secondary
            }
            .animation(.smooth, value: fold)
        }
    }

    /// The crease, only while the hinge is partly open (the query skips inactive regions).
    private static func fold(in proxy: GeometryProxy) -> CGRect? {
        guard #available(iOS 27.1, *) else { return nil }
        return proxy.reservedRegions(kind: .division).first?.frame
    }
}
