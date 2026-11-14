import SwiftUI

/// The tuner: your setup at the top, the strings, and the reading.
/// On the open iPhone Duo (regular in both directions) the settings sit beside it instead of in a sheet.
struct TunerScreen: View {
    let model: TunerViewModel
    // App Store screenshots: launch with `-demoSettings YES` to open on the settings sheet.
    @State private var settingsOpen = UserDefaults.standard.bool(forKey: "demoSettings")
    @Environment(\.scenePhase) private var phase
    @Environment(\.horizontalSizeClass) private var horizontal
    @Environment(\.verticalSizeClass) private var vertical
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

    private var open: Bool { horizontal == .regular && vertical == .regular }

    var body: some View {
        Group {
            if open {
                FoldSplit {
                    tuner
                } secondary: {
                    SettingsSheet(model: model)
                }
            } else {
                tuner
            }
        }
        .task { await model.start() }
        .onChange(of: phase) { _, phase in
            if phase == .active { Task { await model.start() } } else { model.stop() }
        }
    }

    private var tuner: some View {
        VStack(spacing: 0) {
            if !open { settingsButton }
            Strings(tuning: model.tuning, active: model.activeString, play: model.play)
                .padding(.top, 12)
            Spacer()
            reading
            Spacer()
            Text("Version \(version) (\(build))")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder private var reading: some View {
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
    }

    private var settingsButton: some View {
        Button {
            settingsOpen = true
        } label: {
            Label(model.summary, systemImage: "slider.horizontal.3").font(.subheadline.monospacedDigit())
        }
        .glassPill()
        .accessibilityLabel("Settings: \(model.tuningDescription), A4 \(model.a4) hertz")
        .padding(.top, 8)
        .sheet(isPresented: $settingsOpen) {
            SettingsSheet(model: model)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    TunerScreen(model: TunerViewModel())
}

// The open iPhone Duo's inner screen, held tall and wide.
#Preview("Duo open", traits: .fixedLayout(width: 626, height: 890)) {
    TunerScreen(model: TunerViewModel())
        .environment(\.horizontalSizeClass, .regular)
        .environment(\.verticalSizeClass, .regular)
}

#Preview("Duo open wide", traits: .fixedLayout(width: 890, height: 626)) {
    TunerScreen(model: TunerViewModel())
        .environment(\.horizontalSizeClass, .regular)
        .environment(\.verticalSizeClass, .regular)
}
