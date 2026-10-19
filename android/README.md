# Twang for Android

A tuner for guitar and other string instruments on Android. Play a string and Twang shows the note, how many cents sharp or flat it is, and which way to turn the peg.

This is the Android version of the iOS app in this repository (it lives in `android/` until it moves to a repository of its own), with the same features and the same pitch detection. See [docs/plan.md](docs/plan.md) for how the iOS app maps onto this one.

- Guitar, 7-string, 12-string, ukulele, mandolin and banjo, with 29 tunings picked from swipeable cards that show each tuning's strings
- Reference pitch (A4) from 415 to 466 Hz on a snapping ruler, with a reset to 440
- Holds steady in noisy rooms: the mic is filtered to guitar range, unclear readings are ignored, and stray jumps are held back
- Adjustable sensitivity, with a live mic meter, from "loud room" to "quiet strings"
- A pitch history strip under the needle shows whether a note is holding or drifting
- Tap a string to hear a plucked reference tone
- Works offline; audio is analysed on the device and never recorded or sent anywhere

## Requirements

- Android 8.0 (API 26) or later
- To build: JDK 17 or later (21 recommended) and the Android SDK; Android Studio sets both up

## Build and run

Open the folder in Android Studio and run the **app** configuration, or from the command line:

```bash
./gradlew :app:installDebug
```

### In the emulator on a Mac, without Android Studio

```bash
android/scripts/emulator.sh
```

It installs Google's command-line tools with Homebrew (and Java if needed), creates an Android 16 emulator, builds the app, installs it and opens it. The first run downloads a few GB. Add `--demo` to open it with a fixed reading instead of the microphone.

### Demo mode

Start with a `demoFrequency` extra to show a fixed reading without the microphone, for example a slightly flat A string:

```bash
adb shell am start -n com.yonaharel.cadencedemo/.MainActivity --ef demoFrequency 108.9
```

## Project layout

Two modules, MVVM like the iOS app:

```
core/   Plain Kotlin, no Android: runs and tests on any JVM
          Note, Tuning, Instrument
          PitchDetection (YIN), BandPass, Smoother: pure signal processing
app/    The Android app (Jetpack Compose, Material 3)
          MainActivity, TunerViewModel: saved settings, live reading, actions
          audio/     PitchListener (AudioRecord → note), ReferenceTone (AudioTrack plucked tone)
          data/      SettingsStore (DataStore)
          ui/        TunerScreen
            tuner/      Strings, Reading, Needle, History, Unavailable
            settings/   SettingsSheet, InstrumentPicker, TuningCards, A4Ruler, LevelMeter
            components/ pressable, selectionHighlight, staggeredAppear
            theme/      TwangTheme and the tuner's colours
```

Settings (tuning, A4, sensitivity) are stored with DataStore Preferences under the same keys as the iOS app: `tuning`, `a4` and `sensitivity`. Tuning keys are the iOS case names (`standard`, `dropD`, …).

## Checks

The iOS app's pitch self-check is ported to JUnit, case for case:

```bash
./gradlew :core:test
```

Lint:

```bash
./gradlew :app:lintDebug
```

GitHub Actions (`.github/workflows/android.yml` at the repository root) runs both and builds the debug APK; the APK is attached to the run.

## Versioning

`versionName` in `app/build.gradle.kts` follows the iOS app's `MARKETING_VERSION` (currently 2.1.0); `versionCode` must grow with every Play upload.
