# Graph Report - cadence-demo-ios  (2026-10-19)

## Corpus Check
- 34 files · ~39,664 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 9 file(s) not represented in the graph (top: (none) 4, .xcconfig 1, .pbxproj 1)

## Summary
- 278 nodes · 421 edges · 18 communities (13 shown, 5 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 69 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `29151537`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Tuning
- TunerViewModel
- Foundation
- TunerViewModel.swift
- SelectionHighlight
- PitchListener
- Reading
- Note
- SwiftUI
- ci.sh
- screenshots.sh
- PressScale
- Strings
- Twang
- Instrument
- .body
- detectPitch
- resolve-graph-conflicts.sh

## God Nodes (most connected - your core abstractions)
1. `Tuning` - 48 edges
2. `TunerViewModel` - 27 edges
3. `Note` - 20 edges
4. `Instrument` - 16 edges
5. `PitchListener` - 16 edges
6. `Reading` - 13 edges
7. `detectPitch()` - 11 edges
8. `Strings` - 11 edges
9. `Better Tuner Implementation Plan` - 10 edges
10. `Twang — better tuner: noise handling, A4 selection, pitch history strip` - 10 edges

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

## Communities (18 total, 5 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.06
Nodes (34): Tuning, banjoC, banjoDoubleC, banjoOpenD, banjoOpenG, cStandard, dadgad, doubleDropD (+26 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.10
Nodes (12): TunerApp, .body, TunerViewModel, .hearing, .history, .level, .note, .state (+4 more)

### Community 2 - "Foundation"
Cohesion: 0.14
Nodes (6): Foundation, filtered(), noise(), tone(), BandPass, Biquad

### Community 3 - "TunerViewModel.swift"
Cohesion: 0.25
Nodes (5): AVFoundation, Combine, Observation, os, Sharing

### Community 4 - "SelectionHighlight"
Cohesion: 0.14
Nodes (4): SelectionHighlight, View, StaggeredAppear, View

### Community 5 - "PitchListener"
Cohesion: 0.12
Nodes (14): Better Tuner Implementation Plan, Global Constraints, Not covered here, Review Focus, Task 1: A4 reference in `Note`, Task 2: Band-pass filter, clarity bar and RMS floor, Task 3: `Smoother` — median plus outlier rejection, Task 4: Pitch history strip (+6 more)

### Community 6 - "Reading"
Cohesion: 0.09
Nodes (16): Anti-goals, Context, Current state (verified in code), Decided by Claude (user can override), Decided by the user, Goals, Left to the builder, Non-goals (this piece) (+8 more)

### Community 7 - "Note"
Cohesion: 0.12
Nodes (9): Note, .name, .octave, State, denied, failed, idle, listening (+1 more)

### Community 8 - "SwiftUI"
Cohesion: 0.08
Nodes (17): SwiftUI, View, A4Ruler, .body, InstrumentPicker, .body, LevelMeter, .body (+9 more)

### Community 11 - "PressScale"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 13 - "Twang"
Cohesion: 0.20
Nodes (9): Build and run, Checks, Demo mode, Knowledge graph, Lint and format, Project layout, Releasing, Requirements (+1 more)

### Community 14 - "Instrument"
Cohesion: 0.13
Nodes (11): Instrument, banjo, guitar, .id, mandolin, .name, sevenString, .stringCount (+3 more)

### Community 16 - "detectPitch"
Cohesion: 0.39
Nodes (4): detectPitch(), minimumLevel(), rms(), .listeningLevel

## Knowledge Gaps
- **68 isolated node(s):** `guitar`, `sevenString`, `twelveString`, `ukulele`, `mandolin` (+63 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 131 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Tuning` connect `Tuning` to `Foundation`, `Reading`, `Note`, `SwiftUI`, `Strings`, `Instrument`, `.body`?**
  _High betweenness centrality (0.314) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Tuning` (e.g. with `Current state (verified in code)` and `.body`) actually correct?**
  _`Tuning` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `guitar`, `sevenString`, `twelveString` to the rest of the system?**
  _68 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `SwiftUI` connect `SwiftUI` to `TunerViewModel`, `TunerViewModel.swift`, `SelectionHighlight`, `PressScale`, `Strings`?**
  _High betweenness centrality (0.194) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `TunerViewModel` (e.g. with `TunerApp` and `ReferenceTone`) actually correct?**
  _`TunerViewModel` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Should `TunerViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.09971509971509972 - nodes in this community are weakly interconnected._