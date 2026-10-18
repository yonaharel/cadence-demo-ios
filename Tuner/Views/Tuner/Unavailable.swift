import SwiftUI

struct Unavailable: View {
    let message: String
    let action: String?
    let perform: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash").font(.system(size: 48)).foregroundStyle(.secondary)
            Text(message).multilineTextAlignment(.center)
            if let action { Button(action, action: perform).buttonStyle(.borderedProminent) }
        }
    }
}
