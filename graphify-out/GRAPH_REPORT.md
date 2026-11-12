# Graph Report - demo-ios  (2026-11-12)

## Corpus Check
- 35 files · ~40,067 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 101 file(s) not represented in the graph (top: .bin 69, .tmp 12, .lock 6)

## Summary
- 293 nodes · 441 edges · 21 communities (13 shown, 8 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 72 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5c5c87a1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Tuning
- TunerViewModel
- Foundation
- PitchListener.kt
- SelectionHighlight
- Tuner
- Reading
- Note
- View
- ci.sh
- screenshots.sh
- Twang
- Reading
- Twang
- Content
- CGFloat
- resolve-graph-conflicts.sh
- Reading

## God Nodes (most connected - your core abstractions)
1. `Tuning` - 48 edges
2. `TunerViewModel` - 27 edges
3. `Note` - 20 edges
4. `Instrument` - 16 edges
5. `PitchListener` - 16 edges
6. `Reading` - 14 edges
7. `Strings` - 11 edges
8. `detectPitch()` - 11 edges
9. `TunerScreen` - 10 edges
10. `Better Tuner Implementation Plan` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Task 1: A4 reference in `Note`` --references--> `Note`  [INFERRED]
  docs/superpowers/plans/2026-10-19-better-tuner.md → Tuner/Models/Note.swift
- `Task 4: Pitch history strip` --references--> `Reading`  [INFERRED]
  docs/superpowers/plans/2026-10-19-better-tuner.md → Tuner/Views/Tuner/Reading.swift
- `Current state (verified in code)` --references--> `Reading`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Views/Tuner/Reading.swift
- `Decided by Claude (user can override)` --references--> `Reading`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Views/Tuner/Reading.swift
- `Current state (verified in code)` --references--> `Tuning`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Models/Tuning.swift

## Import Cycles
- None detected.

## Communities (21 total, 8 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.06
Nodes (34): Tuning, banjoC, banjoDoubleC, banjoOpenD, banjoOpenG, cStandard, dadgad, doubleDropD (+26 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.14
Nodes (9): TunerViewModel, .hearing, .history, .level, .note, .state, .summary, .tuningDescription (+1 more)

### Community 2 - "Foundation"
Cohesion: 0.18
Nodes (6): Task 2: Band-pass filter, clarity bar and RMS floor, filtered(), noise(), tone(), BandPass, Biquad

### Community 3 - "PitchListener.kt"
Cohesion: 0.18
Nodes (5): AVFoundation, Combine, Foundation, Observation, os

### Community 4 - "SelectionHighlight"
Cohesion: 0.14
Nodes (4): SelectionHighlight, View, StaggeredAppear, View

### Community 5 - "Tuner"
Cohesion: 0.10
Nodes (15): Better Tuner Implementation Plan, Global Constraints, Not covered here, Review Focus, Task 1: A4 reference in `Note`, Task 3: `Smoother` — median plus outlier rejection, Task 4: Pitch history strip, Task 5: A4 control, wired to tuner and reference tone (+7 more)

### Community 6 - "Reading"
Cohesion: 0.10
Nodes (17): Anti-goals, Context, Current state (verified in code), Decided by Claude (user can override), Decided by the user, Goals, Left to the builder, Non-goals (this piece) (+9 more)

### Community 7 - "Note"
Cohesion: 0.12
Nodes (9): Note, .name, .octave, State, denied, failed, idle, listening (+1 more)

### Community 8 - "View"
Cohesion: 0.06
Nodes (22): Sharing, SwiftUI, TunerApp, .body, View, A4Ruler, .body, InstrumentPicker (+14 more)

### Community 11 - "Twang"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 13 - "Twang"
Cohesion: 0.20
Nodes (9): Build and run, Checks, Demo mode, Knowledge graph, Lint and format, Project layout, Releasing, Requirements (+1 more)

### Community 14 - "Content"
Cohesion: 0.14
Nodes (11): Instrument, banjo, guitar, .id, mandolin, .name, sevenString, .stringCount (+3 more)

### Community 18 - "Reading"
Cohesion: 0.15
Nodes (6): FoldSplit, .body, Reading, .advice, .body, .inTune

## Knowledge Gaps
- **69 isolated node(s):** `.inTune`, `.advice`, `.open`, `banjoC`, `banjoDoubleC` (+64 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 138 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Tuning` connect `Tuning` to `PitchListener.kt`, `Reading`, `Note`, `View`, `Reading`, `Content`, `CGFloat`, `Reading`?**
  _High betweenness centrality (0.283) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Tuning` (e.g. with `Current state (verified in code)` and `.body`) actually correct?**
  _`Tuning` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.inTune`, `.advice`, `.open` to the rest of the system?**
  _69 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `SwiftUI` connect `View` to `SelectionHighlight`, `Tuner`, `Reading`, `Twang`, `Reading`, `Reading`?**
  _High betweenness centrality (0.187) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `TunerViewModel` (e.g. with `TunerApp` and `ReferenceTone`) actually correct?**
  _`TunerViewModel` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Should `TunerViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.1368421052631579 - nodes in this community are weakly interconnected._