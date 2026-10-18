# Graph Report - demo-ios  (2026-10-19)

## Corpus Check
- 29 files · ~37,173 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 6 file(s) not represented in the graph (top: (none) 1, .xcconfig 1, .pbxproj 1)

## Summary
- 215 nodes · 341 edges · 14 communities (11 shown, 3 thin omitted)
- Extraction: 81% EXTRACTED · 19% INFERRED · 0% AMBIGUOUS · INFERRED: 65 edges (avg confidence: 0.91)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `172ed335`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Tuning
- TunerViewModel
- BandPass
- Foundation
- SelectionHighlight
- PitchListener
- detectPitch
- Note
- SwiftUI
- ci.sh
- screenshots.sh
- PressScale
- Reading
- detectPitch

## God Nodes (most connected - your core abstractions)
1. `Tuning` - 26 edges
2. `TunerViewModel` - 25 edges
3. `Note` - 19 edges
4. `PitchListener` - 15 edges
5. `Reading` - 13 edges
6. `detectPitch()` - 11 edges
7. `Better Tuner Implementation Plan` - 10 edges
8. `Twang — better tuner: noise handling, A4 selection, pitch history strip` - 10 edges
9. `Current state (verified in code)` - 10 edges
10. `Smoother` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Task 1: A4 reference in `Note`` --references--> `Note`  [INFERRED]
  docs/superpowers/plans/2026-10-19-better-tuner.md → Tuner/Models/Note.swift
- `Better Tuner Implementation Plan` --references--> `Note`  [INFERRED]
  docs/superpowers/plans/2026-10-19-better-tuner.md → Tuner/Models/Note.swift
- `Current state (verified in code)` --references--> `Note`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Models/Note.swift
- `Decided by Claude (user can override)` --references--> `Note`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Models/Note.swift
- `Current state (verified in code)` --references--> `Tuning`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Models/Tuning.swift

## Import Cycles
- None detected.

## Communities (14 total, 3 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.09
Nodes (18): Tuning, cStandard, dadgad, doubleDropD, dropC, dropCSharp, dropD, halfStepDown (+10 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.10
Nodes (11): TunerApp, .body, TunerViewModel, .hearing, .history, .level, .note, .state (+3 more)

### Community 2 - "BandPass"
Cohesion: 0.18
Nodes (6): Task 2: Band-pass filter, clarity bar and RMS floor, filtered(), noise(), tone(), BandPass, Biquad

### Community 3 - "Foundation"
Cohesion: 0.20
Nodes (5): AVFoundation, Combine, Foundation, Observation, os

### Community 5 - "PitchListener"
Cohesion: 0.13
Nodes (12): Better Tuner Implementation Plan, Global Constraints, Not covered here, Review Focus, Task 1: A4 reference in `Note`, Task 3: `Smoother` — median plus outlier rejection, Task 4: Pitch history strip, Task 5: A4 control, wired to tuner and reference tone (+4 more)

### Community 6 - "detectPitch"
Cohesion: 0.10
Nodes (15): Anti-goals, Context, Current state (verified in code), Decided by Claude (user can override), Decided by the user, Goals, Left to the builder, Non-goals (this piece) (+7 more)

### Community 7 - "Note"
Cohesion: 0.13
Nodes (9): Note, .name, .octave, State, denied, failed, idle, listening (+1 more)

### Community 8 - "SwiftUI"
Cohesion: 0.09
Nodes (13): Sharing, SwiftUI, View, A4Ruler, .body, LevelMeter, .body, SettingsSheet (+5 more)

### Community 11 - "PressScale"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 12 - "Reading"
Cohesion: 0.18
Nodes (6): History, .body, Reading, .advice, .body, .inTune

### Community 14 - "detectPitch"
Cohesion: 0.39
Nodes (4): detectPitch(), minimumLevel(), rms(), .listeningLevel

## Knowledge Gaps
- **39 isolated node(s):** `.name`, `.octave`, `standard`, `halfStepDown`, `wholeStepDown` (+34 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 90 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TunerViewModel` connect `TunerViewModel` to `Foundation`, `PitchListener`, `detectPitch`, `Note`, `SwiftUI`, `detectPitch`?**
  _High betweenness centrality (0.223) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `TunerViewModel` (e.g. with `TunerApp` and `ReferenceTone`) actually correct?**
  _`TunerViewModel` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.name`, `.octave`, `standard` to the rest of the system?**
  _39 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._
- **Why does `Note` connect `Note` to `TunerViewModel`, `Foundation`, `PitchListener`, `detectPitch`, `SwiftUI`, `Reading`?**
  _High betweenness centrality (0.197) - this node is a cross-community bridge._
- **Are the 7 inferred relationships involving `Note` (e.g. with `Better Tuner Implementation Plan` and `Task 1: A4 reference in `Note``) actually correct?**
  _`Note` has 7 INFERRED edges - model-reasoned connections that need verification._
- **Should `TunerViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.10333333333333333 - nodes in this community are weakly interconnected._