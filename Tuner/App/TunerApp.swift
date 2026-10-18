import SwiftUI

@main
struct TunerApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @State private var tuner = Tuner()
    @State private var tone = ReferenceTone()
    @AppStorage("tuning") private var tuning = Tuning.standard
    @AppStorage("a4") private var a4 = 440
    @AppStorage("sensitivity") private var sensitivity = 0.7
    @State private var settingsOpen = false
    @Environment(\.scenePhase) private var phase
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

    var body: some View {
        VStack(spacing: 0) {
            Button { settingsOpen = true } label: {
                Label("\(tuning.name) · A4 \(a4)", systemImage: "slider.horizontal.3").font(.subheadline.monospacedDigit())
            }
            .glassPill()
            .accessibilityLabel("Settings: \(tuning.name), A4 \(a4) hertz")
            .padding(.top, 8)
            .sheet(isPresented: $settingsOpen) {
                SettingsSheet(tuning: $tuning, a4: $a4, sensitivity: $sensitivity, tuner: tuner)
                    .presentationDetents([.medium, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium)) // keep tuning while adjusting
            }
            Strings(tuning: tuning, active: tuner.hearing ? tuner.note?.nearestString(in: tuning) : nil, play: tone.play)
                .padding(.top, 12)
            Spacer()
            switch tuner.state {
            case .denied:
                Unavailable(message: "Twang needs the microphone to hear your guitar.", action: "Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                }
            case .failed(let reason):
                Unavailable(message: "The microphone couldn't start: \(reason)", action: nil, perform: {})
            default:
                Reading(note: tuner.note, hearing: tuner.hearing, history: tuner.history)
            }
            Spacer()
            Text("Version \(version) (\(build))")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
        .task { syncA4(); syncSensitivity(); await tuner.start() }
        .onChange(of: a4) { syncA4() }
        .onChange(of: sensitivity) { syncSensitivity() }
        .onChange(of: phase) { _, phase in
            if phase == .active { Task { await tuner.start() } } else { tuner.stop() }
        }
    }

    /// Clamped so a corrupt saved value can't reach Note.
    private func syncA4() {
        tuner.a4 = Double(min(max(a4, 415), 466))
        tone.a4 = tuner.a4
    }

    private func syncSensitivity() { tuner.sensitivity = Float(min(max(sensitivity, 0), 1)) }
}

#Preview {
    ContentView()
}
