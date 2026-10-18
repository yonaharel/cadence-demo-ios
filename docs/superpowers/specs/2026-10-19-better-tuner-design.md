# Twang — better tuner: noise handling, A4 selection, pitch history strip

Design (piece 1 of 4). After approval this file is saved as
`docs/superpowers/specs/2026-10-19-better-tuner-design.md`, committed, and turned into an
implementation plan via superpowers:writing-plans.

## Context

The tuner today falls apart in a noisy room: the phone mic hears talking, other instruments,
fans, and the needle jumps because the pitch detector reports *any* pitch it finds. The user
also wants to tune to other reference pitches (A4 ≠ 440) and wants Tunable-style
"how steady is my note" feedback.

Agreed roadmap (one piece at a time, in this order):
1. **Better tuner** (this doc): noise handling, A4 selection, pitch history strip.
2. Themes (real amp / vintage / analog looks) — next brainstorm.
3. Tone & chord player (sustained notes, drones, chords).
4. Metronome.
Navigation between tools (likely tabs) gets decided when piece 3 starts.

## Goals

- **Steady in noise.** In a loud room the needle holds still on the last confident reading
  instead of jumping. The user picked "hold last good reading" over "show best guess" or a
  sensitivity setting.
- **A4 selection.** User sets the reference pitch; the tuner *and* the reference tone follow it;
  it's remembered across launches.
- **Pitch history strip** (layout A, chosen from mockups): today's needle stays; under it a strip
  scrolls the last ~5 s of pitch, new on the right, on the same ±50 ¢ scale with the same
  green ±5 ¢ band. Steady note = flat line in the green.

## Non-goals (this piece)

- Themes, metronome, tone/chord player, tabs — later pieces.
- Temperaments (Tunable's ~20) — not requested.
- A user-facing sensitivity setting — explicitly not chosen.
- A tap-to-lock "string lock" mode — skipped for now; automatic outlier rejection (below) covers
  the noise goal without new UI. Revisit if noise is still a problem in real use.
- Recorder / practice score — not chosen.

## Anti-goals

- A needle or line that wanders while a string is ringing cleanly in a quiet room (no regression
  in quiet-room accuracy: the existing ±1 ¢ checks must still pass).
- Laggy response when actually retuning a string.
- Turning on iOS voice processing (`.voiceChat` / `setVoiceProcessingEnabled`): it's built for
  speech and would colour the signal. Keep `.measurement` mode.

## Current state (verified in code)

- App is three files: `Tuner/Pitch.swift` (`Note`, `Tuning`, `detectPitch` YIN),
  `Tuner/Tuner.swift` (`Tuner` mic engine, `ReferenceTone` sampler),
  `Tuner/TunerApp.swift` (`ContentView`, `Strings`, `Reading`, `Needle`, `Unavailable`).
- A4 = 440 is hardcoded in `Note.init(frequency:)` (`Pitch.swift:12`) and
  `Note.init(midi:)` (`Pitch.swift:18`); `ReferenceTone` plays MIDI notes through
  `AVAudioUnitSampler`, which has its own 440 baseline.
- `detectPitch` (`Pitch.swift:76`): RMS gate 0.01, YIN threshold 0.15, search 60–1200 Hz, returns
  only `Double?` — the CMND value at the chosen lag (a natural confidence) is discarded. No
  band filtering.
- `Tuner.heard` (`Tuner.swift:64`): median of last 5 readings; >10 empty buffers → `hearing = false`
  and history cleared; last note stays on screen dimmed. Buffer 4096 at hardware rate (~85 ms).
- Only persisted setting: `@AppStorage("tuning")`. No settings screen.
- Tests: no XCTest target; `scripts/check-pitch/main.swift` is a `precondition` script run with
  `swiftc -O Tuner/Pitch.swift scripts/check-pitch/main.swift`. CI doesn't run it.
- No dependencies; iOS 17+.

## Decided by the user

- Hold last good reading when unsure.
- History strip under the needle (layout A).
- A4 shown as a small "A4 440 Hz" chip in the top area; tapping it opens a −/+ control.

## Decided by Claude (user can override)

**A4 selection**
- Range 415–466 Hz, 1 Hz steps, default 440. Quick picks 432 / 440 / 442, plus Reset to 440.
  (Industry norm is 1 Hz steps with −/+ and reset; 415–466 covers baroque through a semitone up.)
- Stored as `@AppStorage("a4")` (Int or Double, builder's call).
- `Note` takes the reference: `init(frequency:a4:)` / `init(midi:a4:)` with `a4` defaulting
  to 440 so existing callers and the check script keep compiling.
- `ReferenceTone` follows via `sampler.globalTuning = 1200 * log2(a4 / 440)` (cents).
- Note names on the string buttons don't change with A4; only frequency/cents do.
- Chip opens a small popover (or compact sheet) with a `Stepper` and the quick picks.

**Noise handling** — goal: reject what isn't a confident guitar fundamental, then hold.
1. `detectPitch` also returns its confidence (CMND minimum at the chosen lag); readings below a
   confidence bar are treated as "no reading".
2. Band-limit the samples to roughly 55 Hz–1.3 kHz before YIN (simple high-pass + low-pass).
   The high-pass must sit below C2 at A4 = 415 (~61.7 Hz) because C Standard / Drop C / Open C
   tune the low string to C2; so mains hum at 60 Hz is not filtered — the confidence bar and
   outlier rejection have to cover it.
   Builder's choice of method; if using an `AVAudioUnitEQ` node, mic audio must not reach the
   speaker (feedback).
3. Raise the RMS floor modestly from 0.01.
4. Outlier rejection in `Tuner.heard`: a reading far from the current note (e.g. more than about a
   semitone) only moves the needle after it persists for a few consecutive buffers; isolated
   jumps are dropped. Real retunes and string changes still come through within ~0.3 s.
5. "No reading" keeps today's behaviour: needle holds, dims after ~10 empty buffers.
- Exact thresholds are the builder's to tune, guided by new check-script cases (below).

**History strip**
- ~5 s window, scrolling right→left, same ±50 ¢ clamp and ±5 ¢ green band as `Needle`.
- Plots the same smoothed cents the needle shows; only confident readings.
- Gaps when nothing is heard (line breaks, doesn't drop to zero).
- Clears when the detected note (MIDI number) changes.
- `accessibilityHidden(true)`, like `Needle`; dims with the rest of `Reading`.
- Demo mode (`-demoFrequency`) should show a flat line so App Store screenshots look right.

## Left to the builder

- Where history lives (likely an array of optional cents with timestamps on `Tuner`) and how it's
  drawn (`Canvas`/`Path`, optionally `TimelineView` for smooth scroll).
- Exact confidence bar, RMS floor, filter design, outlier window size.
- Whether noise/outlier logic is a pure function in `Pitch.swift` (preferred: testable by the
  check script) or inside `Tuner`.

## Verification

- Extend `scripts/check-pitch/main.swift`:
  - existing cases still pass (±1 ¢ at 440);
  - A4 = 432 and 442: each string's own frequency reads ~0 ¢; a 440-tuned A reads ≈ +31.8 ¢ at 432;
  - a string tone with added white noise at a moderate level still detects within a few cents;
  - pure noise / speech-like noise (random) returns nil;
  - if outlier logic is a pure function: a single wild reading in a steady run doesn't move the
    output; a sustained new pitch does within N readings.
- Run: `swiftc -O Tuner/Pitch.swift scripts/check-pitch/main.swift -o /tmp/check && /tmp/check`.
- Build and run in the iOS Simulator (mic via Mac): set A4 to 432, play reference tone → tuner reads
  ~0 ¢ on it; history strip scrolls and gaps; chip persists after relaunch.
- Real-device check by the user in a noisy room (simulator can't prove noise behaviour).
- After code changes: `graphify update .`.
