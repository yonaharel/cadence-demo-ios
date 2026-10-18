import SwiftUI

/// A scale from −50 to +50 cents with a needle; the centre band is in tune.
struct Needle: View {
    let cents: Double?
    let inTune: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let x = { (c: Double) in w / 2 + CGFloat(max(-50, min(50, c)) / 50) * (w / 2 - 6) }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3).fill(Color.green.opacity(0.25))
                    .frame(width: x(5) - x(-5), height: 56).offset(x: x(-5))
                ForEach(-5...5, id: \.self) { i in
                    Rectangle().fill(Color.secondary.opacity(i == 0 ? 0.9 : 0.4))
                        .frame(width: 2, height: i == 0 ? 56 : i % 5 == 0 ? 36 : 22)
                        .offset(x: x(Double(i * 10)) - 1)
                }
                if let cents {
                    Capsule().fill(inTune ? Color.green : Color.orange)
                        .frame(width: 6, height: 72)
                        .offset(x: x(cents) - 3)
                }
            }
            .frame(width: w, height: 72, alignment: .leading)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: cents)
        }
        .frame(height: 72)
        .accessibilityHidden(true)
    }
}
