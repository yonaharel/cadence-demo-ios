# Graph Report - cadence-demo-ios  (2026-11-13)

## Corpus Check
- 36 files · ~97,782 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 9 file(s) not represented in the graph (top: (none) 4, .xcconfig 1, .pbxproj 1)

## Summary
- 302 nodes · 453 edges · 26 communities (18 shown, 8 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 72 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `fd5d46f0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Tuning
- TunerViewModel
- .analyser
- Foundation
- SelectionHighlight
- PitchListener
- Twang — better tuner: noise handling, A4 selection, pitch history strip
- Note
- View
- ci.sh
- screenshots.sh
- PressScale
- Strings
- Twang
- Instrument
- .body
- Reading
- resolve-graph-conflicts.sh
- drawText
- Current state (verified in code)
- filtered
- FoldSplit
- SwiftUI
- Unavailable
- LevelMeter
- History

## God Nodes (most connected - your core abstractions)
1. `Tuning` - 48 edges
2. `TunerViewModel` - 27 edges
3. `Note` - 20 edges
4. `Instrument` - 16 edges
5. `PitchListener` - 16 edges
6. `Reading` - 14 edges
7. `detectPitch()` - 11 edges
8. `Strings` - 11 edges
9. `TunerScreen` - 10 edges
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

## Communities (26 total, 8 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.06
Nodes (34): Tuning, banjoC, banjoDoubleC, banjoOpenD, banjoOpenG, cStandard, dadgad, doubleDropD (+26 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.08
Nodes (16): TunerApp, .body, TunerViewModel, .hearing, .history, .level, .note, .state (+8 more)

### Community 2 - ".analyser"
Cohesion: 0.12
Nodes (8): Task 2: Band-pass filter, clarity bar and RMS floor, Decided by Claude (user can override), BandPass, Biquad, detectPitch(), minimumLevel(), rms(), .listeningLevel

### Community 3 - "Foundation"
Cohesion: 0.15
Nodes (6): AVFoundation, Combine, Foundation, Observation, os, Sharing

### Community 4 - "SelectionHighlight"
Cohesion: 0.14
Nodes (4): SelectionHighlight, View, StaggeredAppear, View

### Community 5 - "PitchListener"
Cohesion: 0.15
Nodes (13): Better Tuner Implementation Plan, Global Constraints, Not covered here, Review Focus, Task 1: A4 reference in `Note`, Task 3: `Smoother` — median plus outlier rejection, Task 4: Pitch history strip, Task 5: A4 control, wired to tuner and reference tone (+5 more)

### Community 6 - "Twang — better tuner: noise handling, A4 selection, pitch history strip"
Cohesion: 0.22
Nodes (8): Anti-goals, Context, Decided by the user, Goals, Left to the builder, Non-goals (this piece), Twang — better tuner: noise handling, A4 selection, pitch history strip, Verification

### Community 7 - "Note"
Cohesion: 0.12
Nodes (9): Note, .name, .octave, State, denied, failed, idle, listening (+1 more)

### Community 8 - "View"
Cohesion: 0.20
Nodes (7): A4Ruler, .body, InstrumentPicker, .body, .body, TuningCards, .body

### Community 10 - "screenshots.sh"
Cohesion: 0.67
Nodes (3): CLANG_MODULE_CACHE_PATH, screenshots.sh script, shoot()

### Community 11 - "PressScale"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 13 - "Twang"
Cohesion: 0.20
Nodes (9): Build and run, Checks, Demo mode, Knowledge graph, Lint and format, Project layout, Releasing, Requirements (+1 more)

### Community 14 - "Instrument"
Cohesion: 0.13
Nodes (11): Instrument, banjo, guitar, .id, mandolin, .name, sevenString, .stringCount (+3 more)

### Community 16 - "Reading"
Cohesion: 0.25
Nodes (4): Reading, .advice, .body, .inTune

### Community 18 - "drawText"
Cohesion: 0.24
Nodes (4): AppKit, CoreText, color(), drawText()

### Community 19 - "Current state (verified in code)"
Cohesion: 0.25
Nodes (4): Current state (verified in code), ReferenceTone, Needle, .body

### Community 20 - "filtered"
Cohesion: 0.57
Nodes (3): filtered(), noise(), tone()

### Community 23 - "Unavailable"
Cohesion: 0.33
Nodes (3): Unavailable, .body, .reading

## Knowledge Gaps
- **72 isolated node(s):** `guitar`, `sevenString`, `twelveString`, `ukulele`, `mandolin` (+67 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 142 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Tuning` connect `Tuning` to `Foundation`, `Note`, `View`, `Strings`, `Instrument`, `.body`, `Current state (verified in code)`?**
  _High betweenness centrality (0.281) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Tuning` (e.g. with `Current state (verified in code)` and `.body`) actually correct?**
  _`Tuning` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `guitar`, `sevenString`, `twelveString` to the rest of the system?**
  _72 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `SwiftUI` connect `SwiftUI` to `TunerViewModel`, `SelectionHighlight`, `View`, `PressScale`, `Strings`, `Current state (verified in code)`, `FoldSplit`, `Unavailable`, `LevelMeter`, `History`?**
  _High betweenness centrality (0.177) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `TunerViewModel` (e.g. with `TunerApp` and `ReferenceTone`) actually correct?**
  _`TunerViewModel` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Should `TunerViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.08143939393939394 - nodes in this community are weakly interconnected._