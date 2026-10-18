import SwiftUI

/// The mic level on a log scale, with a line where the tuner starts listening.
struct LevelMeter: View {
    let level: Float
    let threshold: Float

    var body: some View {
        GeometryReader { geo in
            let x = { (v: Float) in geo.size.width * CGFloat(min(max((log10(max(v, 1e-4)) + 3) / 2.5, 0), 1)) } // 0.001 to ~0.3
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.2))
                Capsule().fill(level > threshold ? Color.green : Color.secondary).frame(width: x(level))
                Rectangle().fill(Color.primary).frame(width: 2, height: 16).offset(x: x(threshold) - 1)
            }
        }
        .frame(height: 8)
        .padding(.vertical, 4)
        .animation(.linear(duration: 0.08), value: level)
        .accessibilityElement()
        .accessibilityLabel(level > threshold ? "Mic level: hearing you" : "Mic level: too quiet to hear")
    }
}
