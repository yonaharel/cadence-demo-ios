import SwiftUI

/// The tuner: your setup at the top, the strings, and the reading.
struct TunerScreen: View {
    let model: TunerViewModel
    @State private var settingsOpen = false
    @Environment(\.scenePhase) private var phase
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

    var body: some View {
        VStack(spacing: 0) {
            Button { settingsOpen = true } label: {
                Label(model.summary, systemImage: "slider.horizontal.3").font(.subheadline.monospacedDigit())
            }
            .glassPill()
            .accessibilityLabel("Settings: \(model.tuning.name), A4 \(model.a4) hertz")
            .padding(.top, 8)
            .sheet(isPresented: $settingsOpen) {
                SettingsSheet(model: model)
                    .presentationDetents([.medium, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium)) // keep tuning while adjusting
            }
            Strings(tuning: model.tuning, active: model.activeString, play: model.play)
                .padding(.top, 12)
            Spacer()
            switch model.state {
            case .denied:
                Unavailable(message: "Twang needs the microphone to hear your guitar.", action: "Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                }
            case .failed(let reason):
                Unavailable(message: "The microphone couldn't start: \(reason)", action: nil, perform: {})
            default:
                Reading(note: model.note, hearing: model.hearing, history: model.history)
            }
            Spacer()
            Text("Version \(version) (\(build))")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
        .task { await model.start() }
        .onChange(of: phase) { _, phase in
            if phase == .active { Task { await model.start() } } else { model.stop() }
        }
    }
}

#Preview {
    TunerScreen(model: TunerViewModel())
}
