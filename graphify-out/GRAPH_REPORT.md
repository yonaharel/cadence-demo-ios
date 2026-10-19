# Graph Report - bass  (2026-10-19)

## Corpus Check
- 32 files · ~39,263 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 9 file(s) not represented in the graph (top: (none) 4, .xcconfig 1, .pbxproj 1)

## Summary
- 277 nodes · 422 edges · 15 communities (12 shown, 3 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 68 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e6fd97ea`
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
- Strings
- Twang
- Instrument

## God Nodes (most connected - your core abstractions)
1. `Tuning` - 52 edges
2. `TunerViewModel` - 27 edges
3. `Note` - 20 edges
4. `Instrument` - 19 edges
5. `PitchListener` - 16 edges
6. `Reading` - 13 edges
7. `detectPitch()` - 11 edges
8. `Strings` - 11 edges
9. `BandPass` - 10 edges
10. `Better Tuner Implementation Plan` - 10 edges

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

## Communities (15 total, 3 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.05
Nodes (39): Tuning, banjoC, banjoDoubleC, banjoOpenD, banjoOpenG, bassDropD, bassHalfStepDown, bassStandard (+31 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.10
Nodes (12): TunerApp, .body, TunerViewModel, .hearing, .history, .level, .note, .state (+4 more)

### Community 2 - "BandPass"
Cohesion: 0.21
Nodes (6): filtered(), noise(), tone(), BandPass, .low, Biquad

### Community 3 - "Foundation"
Cohesion: 0.17
Nodes (5): AVFoundation, Combine, Foundation, Observation, os

### Community 5 - "PitchListener"
Cohesion: 0.12
Nodes (14): Better Tuner Implementation Plan, Global Constraints, Not covered here, Review Focus, Task 1: A4 reference in `Note`, Task 2: Band-pass filter, clarity bar and RMS floor, Task 3: `Smoother` — median plus outlier rejection, Task 4: Pitch history strip (+6 more)

### Community 6 - "detectPitch"
Cohesion: 0.09
Nodes (17): Anti-goals, Context, Current state (verified in code), Decided by Claude (user can override), Decided by the user, Goals, Left to the builder, Non-goals (this piece) (+9 more)

### Community 7 - "Note"
Cohesion: 0.13
Nodes (9): Note, .name, .octave, State, denied, failed, idle, listening (+1 more)

### Community 8 - "SwiftUI"
Cohesion: 0.06
Nodes (21): Sharing, SwiftUI, View, A4Ruler, .body, InstrumentPicker, .body, LevelMeter (+13 more)

### Community 11 - "PressScale"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 12 - "Strings"
Cohesion: 0.18
Nodes (3): Strings, .body, .size

### Community 13 - "Twang"
Cohesion: 0.22
Nodes (8): Build and run, Checks, Demo mode, Lint and format, Project layout, Releasing, Requirements, Twang

### Community 14 - "Instrument"
Cohesion: 0.11
Nodes (14): Instrument, banjo, bass, fiveStringBass, guitar, .id, mandolin, .name (+6 more)

## Knowledge Gaps
- **76 isolated node(s):** `guitar`, `sevenString`, `twelveString`, `ukulele`, `mandolin` (+71 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 134 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Tuning` connect `Tuning` to `Foundation`, `detectPitch`, `Note`, `SwiftUI`, `Strings`, `Instrument`?**
  _High betweenness centrality (0.356) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `TunerViewModel` (e.g. with `TunerApp` and `ReferenceTone`) actually correct?**
  _`TunerViewModel` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `guitar`, `sevenString`, `twelveString` to the rest of the system?**
  _76 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._
- **Why does `Current state (verified in code)` connect `detectPitch` to `Tuning`, `PitchListener`, `Note`, `SwiftUI`, `Strings`?**
  _High betweenness centrality (0.203) - this node is a cross-community bridge._
- **Are the 7 inferred relationships involving `Note` (e.g. with `Better Tuner Implementation Plan` and `Task 1: A4 reference in `Note``) actually correct?**
  _`Note` has 7 INFERRED edges - model-reasoned connections that need verification._
- **Should `TunerViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.09971509971509972 - nodes in this community are weakly interconnected._