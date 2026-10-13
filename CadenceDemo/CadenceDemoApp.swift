import SwiftUI

@main
struct CadenceDemoApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @State private var count = 0
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "metronome.fill")
                .font(.system(size: 72))
                .foregroundStyle(.indigo)
            Text("Cadence Demo")
                .font(.largeTitle.bold())
            Text("Taps: \(count)")
                .font(.title2.monospacedDigit())
            Button("Tap") { count += 1 }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Text("Version \(version) (\(build))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
