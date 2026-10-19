# Twang for Android — plan

Port of the iOS app in this repository (version 2.1.0).
Same features, same behaviour, same numbers; native Android look (Material 3, Jetpack Compose).

## Goal

Feature parity with iOS 2.1.0:

- Guitar, 7-string, 12-string, ukulele, mandolin and banjo: the same 29 tunings, the same saved names.
- Note, cents needle (±50 ¢, green ±5 ¢ band) and "Flat · tune up" / "Sharp · tune down" / "In tune" advice.
- Pitch history strip: ~5 s of cents under the needle, gaps where nothing confident was heard, cleared on a note change.
- The string being tuned is highlighted; tapping a string plays a plucked reference tone at the current A4.
- Settings sheet: instrument chips, swipeable tuning cards, A4 ruler 415–466 Hz (snapping, 432/442 dotted, reset to 440),
  sensitivity slider with a live mic level meter.
- Settings persist (`tuning`, `a4`, `sensitivity`), the tuner stops listening in the background.
- Holds steady in noise: band-pass 55 Hz–1.3 kHz, YIN with a confidence bar, RMS gate from sensitivity, outlier smoother.
- Offline, no analytics; audio is analysed on the device and never recorded.
- Demo mode for screenshots: a fixed frequency without the microphone.

Non-goals for this first version: themes, tone/chord player, metronome (the iOS roadmap's later pieces), tablets/landscape
layouts, Play Store release automation.

## Mapping iOS → Android

| iOS                                       | Android                                                         |
|-------------------------------------------|-----------------------------------------------------------------|
| `Models/Note, Tuning, Instrument`         | `:core` `Note.kt`, `Tuning.kt`, `Instrument.kt` (pure Kotlin)    |
| `Services/Pitch/PitchDetection, BandPass, Smoother` | `:core` `PitchDetection.kt`, `BandPass.kt`, `Smoother.kt` |
| `scripts/check-pitch/main.swift`          | `:core` JUnit tests, the same cases (`./gradlew :core:test`)     |
| `PitchListener` (AVAudioEngine tap)       | `:app` `audio/PitchListener.kt`: `AudioRecord`, 4096-sample buffers on a background thread |
| `ReferenceTone` (AVAudioSourceNode)       | `:app` `audio/ReferenceTone.kt`: streaming `AudioTrack`, same 6-harmonic pluck |
| `@Shared(.appStorage)`                    | `:app` `data/SettingsStore.kt`: DataStore Preferences, same keys  |
| `TunerViewModel` (@Observable)            | `:app` `TunerViewModel` (AndroidX ViewModel + StateFlow)          |
| SwiftUI views                             | Compose: `ui/tuner/*`, `ui/settings/*`, `ui/components/*`         |
| `.sheet` with detents                     | `ModalBottomSheet`                                                |
| `sensoryFeedback(.selection)`             | `HapticFeedbackType.SegmentFrequentTick` / `TextHandleMove`      |
| Microphone usage description / settings   | `RECORD_AUDIO` runtime permission; "Open settings" when denied   |
| `-demoFrequency 108.9` launch argument    | `adb shell am start -n …/.MainActivity --ef demoFrequency 108.9` |
| `Config/Version.xcconfig`                 | `versionName` / `versionCode` in `app/build.gradle.kts`           |
| `make lint` (swift-format)                | `./gradlew :app:lintDebug` (Android Lint)                         |

## Architecture

Two Gradle modules:

- **`:core`** — plain Kotlin/JVM, no Android dependency. Everything that's maths: notes, tunings, YIN, filter,
  smoother. Unit-tested on the JVM, so it runs anywhere (and in CI) in seconds. A straight port of the Swift so the two
  apps hear the same thing; thresholds are copied, not re-tuned.
- **`:app`** — Android application (min SDK 26, target 36), Jetpack Compose + Material 3, single activity, MVVM like
  iOS: `PitchListener` and `ReferenceTone` are services, `TunerViewModel` owns them plus the saved settings, the
  composables are stateless and take what they show.

Audio:

- Input: `AudioRecord(MediaRecorder.AudioSource.UNPROCESSED → fallback MIC, 48 kHz mono float)`. `UNPROCESSED`
  (or `VOICE_RECOGNITION`) avoids AGC/noise suppression, the Android equivalent of iOS `.measurement` mode.
  One `BandPass` per stream, keeps state across buffers; buffers of 4096 samples (~85 ms at 48 kHz) as on iOS.
- Analysis runs on the reader thread; results go to the main thread through a `StateFlow`.
- Output: a `AudioTrack` in streaming mode fed by a small render thread; tapping a string restarts the pluck
  (5 ms attack, ~0.8 s decay, 6 harmonics at 1/h).
- Lifecycle: listen while the activity is started (`LifecycleResumeEffect` / `onStart`-`onStop`), stop otherwise.

## Steps

1. Repository, Gradle wrapper, version catalog, `.gitignore`, README.
2. `:core` port + tests (all cases from `check-pitch/main.swift`).
3. `:app` scaffold: manifest, theme, adaptive icon (dark navy dial with green needle, like iOS), MainActivity.
4. Settings store + `TunerViewModel`.
5. Audio: `PitchListener`, `ReferenceTone`.
6. UI: tuner screen (strings, reading, needle, history, unavailable), settings sheet (instrument picker, tuning cards,
   A4 ruler, level meter + sensitivity), components (selection highlight, press scale, staggered appear).
7. CI on GitHub Actions (`.github/workflows/android.yml`): `:core:test`, `:app:assembleDebug`, `:app:lintDebug`; upload the debug APK.

## Verification

- `./gradlew :core:test` — the ported pitch checks (±1 ¢ on every string of every tuning, A4 432/442, noise, filter,
  smoother, sensitivity).
- CI builds the APK and runs Android Lint.
- On a device/emulator: grant the mic, play/hum a note → reading moves; tap a string → tone plays and the tuner hears it at
  ~0 ¢; change A4 to 432 → tone and reading follow; relaunch → settings kept; deny the mic → "Open settings".
- Demo mode: `--ef demoFrequency 108.9` shows a flat A2 with a flat history line.

## Later

Play Store listing (reuse `metadata/` text and the privacy page), release signing + upload workflow (the iOS repo's
Cadence build flow), screenshot tests, then the iOS roadmap's themes / tone player / metronome on both platforms.
