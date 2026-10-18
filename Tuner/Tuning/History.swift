import SwiftUI

/// The last few seconds of cents, newest at the right; gaps where nothing confident was heard.
struct History: View {
    let cents: [Double?]

    var body: some View {
        Canvas { ctx, size in
            let y = { (c: Double) in size.height / 2 - CGFloat(max(-50, min(50, c)) / 50) * (size.height / 2) }
            ctx.fill(Path(CGRect(x: 0, y: y(5), width: size.width, height: y(-5) - y(5))), with: .color(.green.opacity(0.25)))
            ctx.stroke(Path { $0.move(to: CGPoint(x: 0, y: y(0))); $0.addLine(to: CGPoint(x: size.width, y: y(0))) },
                       with: .color(.secondary.opacity(0.4)), lineWidth: 1)
            var line = Path()
            var gap = true
            for (i, c) in cents.enumerated() {
                guard let c else { gap = true; continue }
                let p = CGPoint(x: size.width * CGFloat(i + 1 + Tuner.historyLength - cents.count) / CGFloat(Tuner.historyLength), y: y(c))
                if gap { line.move(to: p); line.addLine(to: p) } else { line.addLine(to: p) } // a lone point draws as a dot
                gap = false
            }
            ctx.stroke(line, with: .color(.accentColor), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
        .frame(height: 56)
        .accessibilityHidden(true)
    }
}
