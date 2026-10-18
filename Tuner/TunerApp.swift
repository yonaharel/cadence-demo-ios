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

private extension View {
    /// Liquid Glass on iOS 26; a bordered capsule before it.
    @ViewBuilder func glassPill() -> some View {
        if #available(iOS 26, *) { buttonStyle(.glass) } else { buttonStyle(.bordered).buttonBorderShape(.capsule) }
    }
}

/// Tuning, reference pitch and sensitivity, in a sheet the tuner keeps listening behind (glass on iOS 26).
struct SettingsSheet: View {
    @Binding var tuning: Tuning
    @Binding var a4: Int
    @Binding var sensitivity: Double
    let tuner: Tuner

    var body: some View {
        Form {
            Section("Tuning") {
                TuningCards(tuning: $tuning).listRowInsets(EdgeInsets())
            }
            Section("Reference pitch") {
                A4Ruler(a4: $a4)
            }
            Section {
                VStack(spacing: 6) {
                    LevelMeter(level: tuner.level, threshold: minimumLevel(sensitivity: Float(sensitivity)))
                    Slider(value: $sensitivity, in: 0...1).accessibilityLabel("Sensitivity")
                    HStack { Text("Loud room"); Spacer(); Text("Quiet strings") }.font(.caption).foregroundStyle(.secondary)
                }
            } header: {
                Text("Sensitivity")
            } footer: {
                Text("Pluck a string: the bar should pass the line. Turn it down if the room keeps setting it off.")
            }
        }
        .scrollContentBackground(.hidden) // let the sheet's glass show through
    }
}

/// Tuning cards to swipe through; each shows its strings so you can see what you're picking.
struct TuningCards: View {
    @Binding var tuning: Tuning

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Tuning.allCases) { t in
                        let notes = t.strings.map { Note(midi: $0).name }.joined(separator: " ")
                        Button { tuning = t } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.name).font(.subheadline.weight(.semibold))
                                Text(notes).font(.caption.monospaced()).foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.secondary.opacity(0.1)))
                            .selectionHighlight(t == tuning, cornerRadius: 14)
                            .foregroundStyle(t == tuning ? Color.accentColor : Color.primary)
                        }
                        .buttonStyle(.pressScale)
                        .id(t)
                        .accessibilityLabel("\(t.name), \(notes)")
                        .accessibilityAddTraits(t == tuning ? .isSelected : [])
                    }
                }
                .padding(12)
            }
            .onAppear { proxy.scrollTo(tuning, anchor: .center) }
        }
        .sensoryFeedback(.selection, trigger: tuning)
    }
}

/// A ruler you drag to set A4, snapping to each hertz; 432 and 442 are dotted. Double-tap the value for 440.
struct A4Ruler: View {
    @Binding var a4: Int
    @State private var position: Int?
    private let step: CGFloat = 12

    var body: some View {
        VStack(spacing: 6) {
            Text("\(a4) Hz").font(.title.weight(.semibold).monospacedDigit())
                .contentTransition(.numericText(value: Double(a4)))
                .onTapGesture(count: 2) { a4 = 440 }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) { // beside the value, so the number stays centred over the ruler
                    if a4 != 440 {
                        Button { withAnimation { a4 = 440 } } label: {
                            Label("440", systemImage: "arrow.counterclockwise").font(.footnote.weight(.semibold))
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .accessibilityLabel("Reset to 440 hertz")
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: a4 == 440)
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(415...466, id: \.self) { hz in
                            VStack(spacing: 3) {
                                Capsule().fill(Color.secondary.opacity(hz % 10 == 0 ? 0.8 : 0.4)).frame(width: 1.5, height: hz % 10 == 0 ? 20 : 12)
                                Circle().fill(Color.secondary).frame(width: 4, height: 4).opacity(hz == 432 || hz == 442 ? 1 : 0)
                                Text(hz % 10 == 0 ? "\(hz)" : " ").font(.caption2).foregroundStyle(.secondary).fixedSize()
                            }
                            .frame(width: step, height: 46, alignment: .top)
                            .id(hz)
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(.horizontal, (geo.size.width - step) / 2)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $position, anchor: .center)
                .overlay(alignment: .top) { Capsule().fill(Color.accentColor).frame(width: 3, height: 26).offset(y: -3).allowsHitTesting(false) }
            }
            .frame(height: 46)
        }
        .padding(.vertical, 4)
        .onAppear { position = a4 }
        .onChange(of: position) { if let position, position != a4 { a4 = position } }
        .onChange(of: a4) { if position != a4 { withAnimation { position = a4 } } }
        .sensoryFeedback(.selection, trigger: a4)
        .accessibilityElement()
        .accessibilityLabel("Reference pitch")
        .accessibilityValue("A4 \(a4) hertz")
        .accessibilityAdjustableAction { direction in a4 = min(max(a4 + (direction == .increment ? 1 : -1), 415), 466) }
        .accessibilityAction(named: "Reset to 440") { a4 = 440 }
    }
}

/// Selection that grows in: a tinted circle expands from the centre to fill the shape, and the border fades in as it lands.
struct SelectionHighlight: ViewModifier {
    let isSelected: Bool
    let cornerRadius: CGFloat
    @State private var fill: CGFloat = 0
    @State private var border = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        content
            .background {
                GeometryReader { geo in
                    let diameter = hypot(geo.size.width, geo.size.height) // just covers the corners
                    Circle().fill(Color.accentColor.opacity(0.15))
                        .frame(width: diameter, height: diameter)
                        .scaleEffect(fill)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .clipShape(shape)
            }
            .overlay(shape.strokeBorder(Color.accentColor, lineWidth: 2).opacity(border))
            .onAppear { fill = isSelected ? 1 : 0; border = fill }
            .onChange(of: isSelected) { _, selected in
                if reduceMotion {
                    withAnimation(.easeOut(duration: 0.2)) { fill = selected ? 1 : 0; border = fill }
                } else if selected {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { fill = 1 }
                    withAnimation(.easeOut(duration: 0.15).delay(0.2)) { border = 1 } // as the fill lands
                } else {
                    withAnimation(.easeOut(duration: 0.2)) { fill = 0; border = 0 }
                }
            }
    }
}

/// Shrinks a little while pressed, so a tap feels physical.
struct PressScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressScale {
    static var pressScale: PressScale { PressScale() }
}

extension View {
    /// See `SelectionHighlight`.
    func selectionHighlight(_ isSelected: Bool, cornerRadius: CGFloat) -> some View {
        modifier(SelectionHighlight(isSelected: isSelected, cornerRadius: cornerRadius))
    }
}

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
                        .background(Circle().fill(Color.secondary.opacity(0.15)))
                        .selectionHighlight(midi == active, cornerRadius: 23)
                        .foregroundStyle(midi == active ? Color.accentColor : Color.primary)
                }
                .buttonStyle(.pressScale)
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
                if gap { line.move(to: p); line.addLine(to: p) } else { line.addLine(to: p) } // a lone point draws as a dot
                gap = false
            }
            ctx.stroke(line, with: .color(.accentColor), style: StrokeStyle(lineWidth: 2, lineCap: .round))
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
