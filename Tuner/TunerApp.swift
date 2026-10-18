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
    @Environment(\.scenePhase) private var phase
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Tuning", selection: $tuning) {
                    ForEach(Tuning.allCases) { t in
                        Text(t.name).tag(t)
                    }
                }
                .pickerStyle(.menu)
                Spacer()
                A4Control(a4: $a4)
            }
            .padding(.top, 8)
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
        .task { syncA4(); await tuner.start() }
        .onChange(of: a4) { syncA4() }
        .onChange(of: phase) { _, phase in
            if phase == .active { Task { await tuner.start() } } else { tuner.stop() }
        }
    }

    /// Clamped so a corrupt saved value can't reach Note.
    private func syncA4() {
        tuner.a4 = Double(min(max(a4, 415), 466))
        tone.a4 = tuner.a4
    }
}

/// The reference pitch chip; tap for a stepper and the usual picks (440 doubles as the reset).
struct A4Control: View {
    @Binding var a4: Int
    @State private var open = false

    var body: some View {
        Button("A4 \(a4) Hz") { open = true }
            .buttonStyle(.bordered)
            .font(.subheadline.monospacedDigit())
            .accessibilityLabel("Reference pitch, A4 \(a4) hertz")
            .popover(isPresented: $open) {
                VStack(spacing: 16) {
                    Stepper("\(a4) Hz", value: $a4, in: 415...466)
                    HStack {
                        ForEach([432, 440, 442], id: \.self) { hz in
                            if hz == a4 {
                                Button("\(hz)") { a4 = hz }.buttonStyle(.borderedProminent)
                            } else {
                                Button("\(hz)") { a4 = hz }.buttonStyle(.bordered)
                            }
                        }
                    }
                }
                .padding()
                .frame(minWidth: 220)
                .presentationCompactAdaptation(.popover)
            }
    }
}

/// The six strings of the tuning; the one being tuned is filled. Tap one to hear its note.
struct Strings: View {
    let tuning: Tuning
    let active: Int?
    let play: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(tuning.strings, id: \.self) { midi in
                let note = Note(midi: midi)
                Button { play(midi) } label: {
                    Text("\(note.name)\(Text("\(note.octave)").font(.caption2))")
                        .font(.headline)
                        .frame(width: 46, height: 46)
                        .background(Circle().fill(midi == active ? Color.accentColor : Color.secondary.opacity(0.15)))
                        .foregroundStyle(midi == active ? Color.white : Color.primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(note.name) \(note.octave) string\(midi == active ? ", tuning" : "")")
                .accessibilityHint("Plays the note")
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
    let history: [Double?]

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
            History(cents: history)
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
                if gap { line.move(to: p) } else { line.addLine(to: p) }
                gap = false
            }
            ctx.stroke(line, with: .color(.accentColor), lineWidth: 2)
        }
        .frame(height: 56)
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
