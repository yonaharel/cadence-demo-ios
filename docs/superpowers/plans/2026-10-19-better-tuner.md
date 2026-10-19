# Better Tuner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Twang hold steady in noisy rooms, let the user pick the A4 reference pitch, and show a pitch history strip under the needle.

**Architecture:** All signal logic stays pure and lives in `Tuner/Pitch.swift` so the existing `scripts/check-pitch` precondition script can test it: `Note` gains an `a4` parameter, a stateful `BandPass` filter cleans mic buffers before YIN, `detectPitch` gets a clarity bar and higher RMS floor, and a `Smoother` struct replaces the median logic in `Tuner.heard` and adds outlier rejection. `Tuner` keeps a short cents history; `TunerApp.swift` gets a `History` strip and an `A4Control` chip.

**Tech Stack:** Swift 5 mode, SwiftUI, AVFoundation, iOS 17+. No dependencies, no XCTest target.

**Spec:** `docs/superpowers/specs/2026-10-19-better-tuner-design.md`

## Global Constraints

- iOS 17+, no new dependencies, no new targets.
- Keep `AVAudioSession` mode `.measurement`; never enable voice processing.
- A4 range 415–466 Hz, 1 Hz steps, default 440, persisted as `@AppStorage("a4")` (Int).
- High-pass cutoff below C2 at A4 = 415 (~61.7 Hz): use 55 Hz. Low-pass 1300 Hz.
- Existing check-script cases must keep passing (every string within ±1 ¢ at A4 = 440).
- Retunes and string changes reach the needle within ~0.3 s (≤ 3 buffers of 4096 at 48 kHz).
- History: ~5 s window, ±50 ¢ clamp, green ±5 ¢ band, gaps for no reading, clears on note change, `accessibilityHidden(true)`.
- Tests run with: `swiftc -O Tuner/Pitch.swift scripts/check-pitch/main.swift -o /tmp/check-pitch && /tmp/check-pitch` → prints `pitch detection ok`.
- App build: `xcodebuild -project Tuner.xcodeproj -scheme Tuner -destination 'generic/platform=iOS Simulator' -quiet build` → exits 0.
- After code changes: `graphify update .` (skip silently if `graphify` isn't installed).

## Review Focus

1. **Lowest strings after filtering** — C2 (Drop C / C Standard / Open C) with A4 = 415 must still be detected; the 55 Hz high-pass is the risk. Test in Task 2.
2. **Slow retune is not "an outlier"** — turning a peg slides pitch gradually; the needle must follow every buffer, never freeze. Test in Task 3.
3. **String change comes through** — going from the A string to the D string (5 semitones) must move the needle by the 3rd buffer. Test in Task 3.
4. **Flicker between two outliers** — noise alternating between two wild pitches must never be accepted. Test in Task 3.
5. **Filter warm-up** — the first buffer after `start()` has a filter transient; detection on a long tone must be accurate from the 2nd buffer on. Test in Task 2.

---

### Task 1: A4 reference in `Note`

**Files:**
- Modify: `Tuner/Pitch.swift:3-18`
- Test: `scripts/check-pitch/main.swift`

**Interfaces:**
- Produces: `Note.init(frequency: Double, a4: Double = 440)`, `Note.init(midi: Int, a4: Double = 440)`. Existing callers compile unchanged.

- [ ] **Step 1: Add failing checks** (append before `print`):

```swift
for a4 in [432.0, 442.0] {
    for midi in Tuning.standard.strings {
        let f = Note(midi: midi, a4: a4).frequency
        let note = Note(frequency: detectPitch(tone(f), sampleRate: rate)!, a4: a4)
        precondition(note.midi == midi && abs(note.cents) < 1, "A4=\(a4) string \(midi): \(note)")
    }
}
precondition(abs(Note(frequency: 110, a4: 432).cents - 31.8) < 0.2, "440-tuned A2 is sharp at 432")
```

- [ ] **Step 2: Run** the check command. Expected: compile error, extra argument `a4`.
- [ ] **Step 3: Implement** — replace both `440` literals with `a4`; update the doc comment to "relative to `a4` (440 Hz unless set)".
- [ ] **Step 4: Run** the check command. Expected: `pitch detection ok`.
- [ ] **Step 5: Commit** `git add Tuner/Pitch.swift scripts/check-pitch/main.swift && git commit -m "Let Note take the A4 reference pitch"`

---

### Task 2: Band-pass filter, clarity bar and RMS floor

**Files:**
- Modify: `Tuner/Pitch.swift` (add `BandPass`, tighten `detectPitch`)
- Modify: `Tuner/Tuner.swift:38-62` (filter in the tap)
- Test: `scripts/check-pitch/main.swift`

**Interfaces:**
- Produces: `struct BandPass { init(sampleRate: Double, low: Double = 55, high: Double = 1300); mutating func process(_ samples: inout [Float]) }` — keeps state between calls (one per audio stream).
- `detectPitch` signature unchanged.

- [ ] **Step 1: Add failing checks.** Add a deterministic noise helper and these checks:

```swift
var seed: UInt64 = 0x9E3779B97F4A7C15
func noise(_ count: Int, amplitude: Float) -> [Float] {
    (0..<count).map { _ in
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return amplitude * (Float(seed >> 40) / Float(1 << 24) * 2 - 1)
    }
}
func filtered(_ f: Double, buffers: Int = 3, noiseAmp: Float = 0) -> [Float] {
    // Several buffers through one filter, like the live tap; analyse the last.
    var filter = BandPass(sampleRate: rate)
    var last: [Float] = []
    for b in 0..<buffers {
        var x = (0..<4096).map { i in
            let t = Double(b * 4096 + i) / rate
            return Float(0.5 * sin(2 * .pi * f * t) + 0.3 * sin(4 * .pi * f * t) + 0.15 * sin(6 * .pi * f * t))
        }
        if noiseAmp > 0 { x = zip(x, noise(4096, amplitude: noiseAmp)).map(+) }
        filter.process(&x)
        last = x
    }
    return last
}
for midi in Set(Tuning.allCases.flatMap(\.strings)).sorted() {
    let f = Note(midi: midi).frequency
    let note = Note(frequency: detectPitch(filtered(f, buffers: 2), sampleRate: rate)!)
    precondition(note.midi == midi && abs(note.cents) < 1, "filtered string \(midi): \(note)")
}
let lowC = Note(midi: 36, a4: 415)
precondition(Note(frequency: detectPitch(filtered(lowC.frequency), sampleRate: rate)!, a4: 415).midi == 36, "C2 at A4=415 survives the high-pass")
let noisyA = Note(frequency: detectPitch(filtered(110, noiseAmp: 0.3), sampleRate: rate)!)
precondition(noisyA.midi == 45 && abs(noisyA.cents) < 3, "A2 in noise: \(noisyA)")
var hiss = noise(4096 * 3, amplitude: 0.3), hissFilter = BandPass(sampleRate: rate)
hissFilter.process(&hiss)
precondition(detectPitch(Array(hiss.suffix(4096)), sampleRate: rate) == nil, "filtered noise has no pitch")
precondition(detectPitch(noise(4096, amplitude: 0.3), sampleRate: rate) == nil, "raw noise has no pitch")
var high = filtered(3000, buffers: 2)
precondition(sqrt(high.map { $0 * $0 }.reduce(0, +) / 4096) < 0.1, "3 kHz is attenuated")
```

- [ ] **Step 2: Run** the check command. Expected: compile error, `BandPass` not found.
- [ ] **Step 3: Implement `BandPass`** in `Pitch.swift`: two RBJ-cookbook biquads in series (high-pass at `low`, low-pass at `high`, Q = 0.7071), direct form I, state stored per biquad. One-line doc comment: why it exists (mic hiss and rumble outside guitar range confuse YIN).
- [ ] **Step 4: Tighten `detectPitch`**: raise the RMS gate from `0.01` to `0.02`; after walking to the local minimum add `guard cmnd[lag] < 0.1 else { return nil } // not periodic enough to trust`. Both values are starting points: if Step 5 fails on the noise checks, tune them (stay within RMS 0.01–0.05, clarity 0.05–0.15) — never loosen the ±1 ¢ checks.
- [ ] **Step 5: Run** the check command. Expected: `pitch detection ok`.
- [ ] **Step 6: Wire into the tap** in `Tuner.analyser`: create `var filter = BandPass(sampleRate: sampleRate)` inside `analyser` before returning the block; in the block copy the channel into `var samples`, `filter.process(&samples)`, then `detectPitch(samples, …)`. A new tap (each `start()`) gets a fresh filter.
- [ ] **Step 7: Build** the app (command in Global Constraints). Expected: exit 0.
- [ ] **Step 8: Commit** `git commit -am "Filter the mic to guitar range and only trust clear pitches"`

---

### Task 3: `Smoother` — median plus outlier rejection

**Files:**
- Modify: `Tuner/Pitch.swift` (add `Smoother`)
- Modify: `Tuner/Tuner.swift:15,64-75` (replace `recent` with a `Smoother`)
- Test: `scripts/check-pitch/main.swift`

**Interfaces:**
- Produces: `struct Smoother { mutating func add(_ frequency: Double) -> Double?; mutating func reset() }`. `add` returns the smoothed frequency to show, or `nil` when the reading is being held back as a possible outlier (caller keeps showing the last note).

Behaviour (the plan fixes this, tests pin it):
- Keeps the last 5 accepted readings; output is their median (as today).
- A reading more than 1 semitone (100 ¢) from the current median goes to a pending list and `add` returns `nil`.
- If the pending list reaches 3 readings all within 1 semitone of the first pending one, they replace the history and their median is returned. A pending reading that isn't within 1 semitone of the first pending one restarts the pending list with itself.
- Any in-range reading clears the pending list.
- `reset()` empties both (called after ~10 quiet buffers, as today).

- [ ] **Step 1: Add failing checks:**

```swift
var s = Smoother()
for _ in 0..<5 { _ = s.add(110) }
precondition(s.add(220) == nil, "a single octave jump is held")
precondition(abs(s.add(110)! - 110) < 0.01, "steady note continues after a blip")
var slide = Smoother(), out: Double? = nil
for i in 0..<20 { out = slide.add(105 + Double(i) * 0.5); precondition(out != nil, "slow retune is never held") }
var change = Smoother()
for _ in 0..<5 { _ = change.add(110) }
precondition(change.add(146.8) == nil && change.add(146.8) == nil, "first two of a new string held")
precondition(abs(change.add(146.8)! - 146.8) < 0.01, "new string accepted on the 3rd buffer")
var flicker = Smoother()
for _ in 0..<5 { _ = flicker.add(110) }
for f in [300.0, 500, 300, 500, 300, 500] { precondition(flicker.add(f) == nil, "alternating outliers never accepted") }
var fresh = Smoother()
precondition(fresh.add(82.4) != nil, "first reading after reset is shown")
```

- [ ] **Step 2: Run** the check command. Expected: compile error, `Smoother` not found.
- [ ] **Step 3: Implement `Smoother`** in `Pitch.swift` per the behaviour above; distance in cents is `1200 * log2(a / b)`.
- [ ] **Step 4: Run** the check command. Expected: `pitch detection ok`.
- [ ] **Step 5: Use it in `Tuner.heard`**: replace `recent` with `private var smoother = Smoother()`; `recent.removeAll()` → `smoother.reset()`; on a pitch: `quietFrames = 0; hearing = true; guard let f = smoother.add(pitch) else { return }` then set `note`. A held reading counts as heard, not quiet.
- [ ] **Step 6: Build** the app. Expected: exit 0.
- [ ] **Step 7: Commit** `git commit -am "Hold the needle through stray readings"`

---

### Task 4: Pitch history strip

**Files:**
- Modify: `Tuner/Tuner.swift` (`history` on `Tuner`)
- Modify: `Tuner/TunerApp.swift:38,82-114` (pass history to `Reading`; add `History` view)

**Interfaces:**
- Consumes: `Smoother.add` from Task 3 (accepted readings).
- Produces: `Tuner.history: [Double?]` (`private(set)`), cents per buffer, oldest first, at most `Tuner.historyLength = 60` entries (~5 s at 4096/48 kHz). `struct History: View { let cents: [Double?] }`. `Reading` gains `let history: [Double?]`.

- [ ] **Step 1: Record history in `Tuner.heard`:**
  - accepted reading → if its MIDI differs from the previous `note?.midi`, clear history first; append its cents;
  - no pitch, or held reading → append `nil`;
  - trim to the last 60. Comment: `// shortcut: one entry per buffer, so the strip steps ~12×/s; move to timestamps + TimelineView if it looks choppy`.
  - Demo mode in `init`: `history = Array(repeating: note!.cents, count: Self.historyLength)`.
- [ ] **Step 2: Add `History`** under `Needle` in `TunerApp.swift`: height 56; `Canvas` drawing a green `Color.green.opacity(0.25)` band for ±5 ¢, a centre line `Color.secondary.opacity(0.4)`, and the line (`Color.accentColor`, 2 pt) with x = index spaced over the full width (newest at the right edge, so a short history sits on the right), y from cents clamped to ±50 (sharp up). Break the path at every `nil`. `.accessibilityHidden(true)`.
- [ ] **Step 3: Show it**: in `Reading` insert `History(cents: history)` directly after `Needle`; pass `tuner.history` from `ContentView`. It dims with `Reading`'s existing opacity.
- [ ] **Step 4: Build** the app. Expected: exit 0.
- [ ] **Step 5: Check in the Simulator** with `-demoFrequency 108.9`: strip shows a flat line at about −17 ¢, below the green band. Screenshot.
- [ ] **Step 6: Commit** `git commit -am "Show the last few seconds of pitch under the needle"`

---

### Task 5: A4 control, wired to tuner and reference tone

**Files:**
- Modify: `Tuner/Tuner.swift` (`Tuner.a4`, `ReferenceTone.a4`)
- Modify: `Tuner/TunerApp.swift:10-52` (`@AppStorage("a4")`, top bar, `A4Control`)

**Interfaces:**
- Consumes: `Note.init(frequency:a4:)` (Task 1).
- Produces: `Tuner.a4: Double` (default 440, used in `heard` and demo `init`); `ReferenceTone.a4: Double` whose `didSet` sets `sampler.globalTuning = Float(1200 * log2(a4 / 440))`; `struct A4Control: View { @Binding var a4: Int }`.

- [ ] **Step 1: Model**: add `var a4 = 440.0` to `Tuner` and use it in `Note(frequency:a4:)`; add `var a4 = 440.0 { didSet { … } }` to `ReferenceTone`.
- [ ] **Step 2: Persist and sync** in `ContentView`: `@AppStorage("a4") private var a4 = 440`; in `.task` (before `tuner.start()`) and `.onChange(of: a4)`, set `tuner.a4` and `tone.a4` to `Double(a4)`.
- [ ] **Step 3: `A4Control`**: a bordered button labelled `"A4 \(a4) Hz"` (`.font(.subheadline.monospacedDigit())`) that opens a `.popover` with `.presentationCompactAdaptation(.popover)` containing `Stepper("\(a4) Hz", value: $a4, in: 415...466)` and a row of buttons 432 / 440 / 442 (440 doubles as reset; the selected one is `.borderedProminent`). Accessibility label "Reference pitch, A4 \(a4) hertz".
- [ ] **Step 4: Top bar**: wrap the tuning `Picker` in `HStack { Picker…; Spacer(); A4Control(a4: $a4) }`.
- [ ] **Step 5: Build** the app. Expected: exit 0.
- [ ] **Step 6: Check in the Simulator**: set A4 to 432, relaunch → chip still shows 432. Tap the A string → tone plays; tuner reading of it is ~0 ¢ (if the Mac mic hears the tone). Screenshot the popover.
- [ ] **Step 7: Run** the check command once more. Expected: `pitch detection ok`.
- [ ] **Step 8: Commit** `git commit -am "Let you choose the A4 reference pitch"`, then run `graphify update .`.

---

## Not covered here

Real noisy-room behaviour can only be judged on a device; the user tests that after Task 5. App Store metadata/screenshots are not updated by this plan.
