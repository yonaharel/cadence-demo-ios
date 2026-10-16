import SwiftUI

@main
struct TunerApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @State private var tuner = Tuner()
    @AppStorage("tuning") private var tuning = Tuning.standard
    @Environment(\.scenePhase) private var phase
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

    var body: some View {
        VStack(spacing: 0) {
            Picker("Tuning", selection: $tuning) {
                ForEach(Tuning.allCases) { t in
                    Text(t.name).tag(t)
                }
            }
            .pickerStyle(.menu)
            .padding(.top, 8)
            Strings(tuning: tuning, active: tuner.hearing ? tuner.note?.nearestString(in: tuning) : nil)
                .padding(.top, 12)
            Spacer()
            switch tuner.state {
            case .denied:
                Unavailable(message: "Tuner needs the microphone to hear your guitar.", action: "Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                }
            case .failed(let reason):
                Unavailable(message: "The microphone couldn't start: \(reason)", action: nil, perform: {})
            default:
                Reading(note: tuner.note, hearing: tuner.hearing)
            }
            Spacer()
            Text("Version \(version) (\(build))")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
        .task { await tuner.start() }
        .onChange(of: phase) { _, phase in
            if phase == .active { Task { await tuner.start() } } else { tuner.stop() }
        }
    }
}

/// The six strings of the tuning; the one being tuned is filled.
struct Strings: View {
    let tuning: Tuning
    let active: Int?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(tuning.strings, id: \.self) { midi in
                let note = Note(midi: midi)
                Text("\(note.name)\(Text("\(note.octave)").font(.caption2))")
                    .font(.headline)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(midi == active ? Color.accentColor : Color.secondary.opacity(0.15)))
                    .foregroundStyle(midi == active ? Color.white : Color.primary)
                    .accessibilityLabel("\(note.name) \(note.octave) string\(midi == active ? ", tuning" : "")")
            }
        }
        .animation(.easeOut(duration: 0.15), value: active)
        .animation(.easeOut(duration: 0.15), value: tuning)
    }
}

/// The note, a cents needle, and what to do about it.
struct Reading: View {
    let note: Note?
    let hearing: Bool

    private var inTune: Bool { abs(note?.cents ?? 99) <= 5 }
    private var advice: String {
        guard let note, hearing else { return "Play a string" }
        if inTune { return "In tune" }
        return note.cents < 0 ? "Flat · tune up" : "Sharp · tune down"
    }

    var body: some View {
        VStack(spacing: 28) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(note?.name ?? "–").font(.system(size: 120, weight: .bold, design: .rounded))
                if let note { Text("\(note.octave)").font(.system(size: 36, weight: .semibold, design: .rounded)).foregroundStyle(.secondary) }
            }
            .contentTransition(.numericText())
            Needle(cents: hearing ? note?.cents : nil, inTune: inTune)
            VStack(spacing: 6) {
                Text(advice).font(.title2.weight(.semibold)).foregroundStyle(hearing && inTune ? Color.green : Color.primary)
                if let note {
                    Text(String(format: "%.1f Hz · %+.0f ¢", note.frequency, note.cents))
                        .font(.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .opacity(hearing ? 1 : 0.45)
        .animation(.easeOut(duration: 0.2), value: hearing)
        .accessibilityElement(children: .combine)
    }
}

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

#Preview {
    ContentView()
}
