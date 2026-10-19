# Twang

A guitar tuner for iPhone. Play a string and Twang shows the note, how many cents sharp or flat it is, and which way to turn the peg.

- 14 tunings, picked from swipeable cards that show each tuning's strings
- Reference pitch (A4) from 415 to 466 Hz on a snapping ruler, with a reset to 440
- Holds steady in noisy rooms: the mic is filtered to guitar range, unclear readings are ignored, and stray jumps are held back
- Adjustable sensitivity, with a live mic meter, from "loud room" to "quiet strings"
- A pitch history strip under the needle shows whether a note is holding or drifting
- Tap a string to hear a plucked reference tone
- Works offline; audio is analysed on the device and never recorded or sent anywhere

## Requirements

- Xcode 26 or later
- iOS 17 or later; Liquid Glass styling on iOS 26
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) is only needed if you change `project.yml`: `brew install xcodegen`

## Build and run

Open `Tuner.xcodeproj` in Xcode and run the **Tuner** scheme. The first time, Xcode asks you to trust the macros from swift-sharing; choose *Trust & Enable*.

From the command line:

```bash
xcodebuild -project Tuner.xcodeproj -scheme Tuner -destination 'generic/platform=iOS Simulator' -skipMacroValidation build
```

`-skipMacroValidation` is needed on the command line because swift-sharing uses macros.

The project file is generated from `project.yml`. After changing `project.yml`, regenerate it:

```bash
xcodegen generate
```

The `Tuner` folder is a buildable (synchronized) folder, so new Swift files are picked up without regenerating.

### Demo mode

Launch with `-demoFrequency <Hz>` to show a fixed reading without the microphone, for example `-demoFrequency 108.9` for a slightly flat A string. The App Store screenshots use this.

## Project layout

The app follows MVVM.

```
Tuner/
  App/          TunerApp: entry point; owns the one TunerViewModel
  Models/       Note, Tuning
  Services/     PitchListener (mic → note), ReferenceTone (plucked tone)
    Pitch/      PitchDetection (YIN), BandPass, Smoother: pure signal processing
  ViewModels/   TunerViewModel: saved settings, live reading, actions
  Views/        TunerScreen
    Tuner/      Strings, Reading, Needle, History, Unavailable
    Settings/   SettingsSheet, TuningCards, A4Ruler, LevelMeter
    Components/ SelectionHighlight, PressScale, GlassPill
  Resources/    Assets.xcassets
```

Settings (tuning, A4, sensitivity) are stored with [swift-sharing](https://github.com/pointfreeco/swift-sharing)'s `@Shared(.appStorage)` under the keys `tuning`, `a4` and `sensitivity`.

## Checks

Pitch detection, filtering and smoothing are covered by a self-check script on synthetic guitar tones:

```bash
swiftc -O Tuner/Models/*.swift Tuner/Services/Pitch/*.swift scripts/check-pitch/main.swift -o /tmp/check-pitch && /tmp/check-pitch
```

It prints `pitch detection ok`, or stops at the first failing check.

## Lint and format

Formatting uses the swift-format that ships with Xcode, configured in `.swift-format`:

```bash
make lint
```

```bash
make format
```

Pull requests run `make lint` (`.github/workflows/lint.yml`), and so does the release build.

## Knowledge graph

`graphify-out/graph.json` and `GRAPH_REPORT.md` are committed so Claude can query the codebase. Set up once per clone, so the hooks keep the graph fresh and merges don't conflict on it:

```bash
graphify hook install
```

```bash
git config merge.graphify-report.driver true
```

`.gitattributes` sends `graph.json` through graphify's union merge driver and keeps one side of `GRAPH_REPORT.md`, which the post-merge hook then regenerates. GitHub's own conflict check doesn't run custom merge drivers, so merge `develop` into a branch locally if a PR shows a conflict on these files.

## Releasing

- The version lives in `Config/Version.xcconfig` (`MARKETING_VERSION`).
- `.github/workflows/build.yml` is started by Cadence with a version and build number. It checks the version, lints, then archives and uploads to App Store Connect through `scripts/ci.sh`.
- `scripts/screenshots.sh` retakes the App Store screenshots in `metadata/screenshots/en-US` on the 6.9" and 6.3" simulators.
- App Store text lives in `metadata/en-US`, and App Review notes in `metadata/review_information`.
- The privacy and support pages are `docs/privacy.html` and `docs/support.html`, served by GitHub Pages.

Design notes and plans are in `docs/superpowers`.
