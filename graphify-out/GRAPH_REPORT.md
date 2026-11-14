# Graph Report - cadence-demo-ios  (2026-11-14)

## Corpus Check
- 123 files · ~944,742 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 16 file(s) not represented in the graph (top: (none) 10, .xcconfig 1, .pbxproj 1)

## Summary
- 1134 nodes · 2762 edges · 58 communities (49 shown, 9 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 91 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cdb2969e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Tuning
- TunerViewModel
- BandPass
- Foundation
- SelectionHighlight
- Better Tuner Implementation Plan
- Twang — better tuner: noise handling, A4 selection, pitch history strip
- Note
- View
- ci.sh
- screenshots.sh
- PressScale
- Strings
- Twang
- Instrument
- inspector.tsx
- slide-canvas.tsx
- resolve-graph-conflicts.sh
- Current state (verified in code)
- upload-font/route.ts
- ElementTransformControls
- style-lab.tsx
- App Store Screenshots — Editor Template
- png-encode.ts
- layouts.ts
- PitchListener
- package.json
- project-schema.ts
- dependencies
- TunerScreen
- Decided by Claude (user can override)
- Reading
- compilerOptions
- components.json
- scene-style-lab.e2e.ts
- scripts
- detectPitch
- targets.e2e.ts
- server.cjs
- SwiftUI
- migration-fixture.cjs
- bug-bash.cjs
- screenshot-editor.tsx
- api-bug-bash.cjs
- devDependencies
- ui-bug-bash.cjs
- frames/route.ts
- drawText
- State
- filtered
- .label
- FoldSplit
- TunerApp
- next.config.mjs
- tailwind.config.ts
- engines
- overrides

## God Nodes (most connected - your core abstractions)
1. `Tuning` - 53 edges
2. `cn()` - 53 edges
3. `ScreenshotEditor()` - 38 edges
4. `ElementTransformControls()` - 31 edges
5. `Inspector()` - 30 edges
6. `Toolbar()` - 30 edges
7. `react` - 29 edges
8. `StyleLab()` - 29 edges
9. `TunerViewModel` - 27 edges
10. `Button` - 27 edges

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

## Communities (58 total, 9 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.05
Nodes (39): Tuning, banjoC, banjoDoubleC, banjoOpenD, banjoOpenG, bassDropD, bassHalfStepDown, bassStandard (+31 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.16
Nodes (8): TunerViewModel, .hearing, .history, .level, .note, .state, .summary, .tuningDescription

### Community 2 - "BandPass"
Cohesion: 0.44
Nodes (3): BandPass, .low, Biquad

### Community 3 - "Foundation"
Cohesion: 0.20
Nodes (4): Combine, Foundation, Observation, Sharing

### Community 4 - "SelectionHighlight"
Cohesion: 0.14
Nodes (4): SelectionHighlight, View, StaggeredAppear, View

### Community 5 - "Better Tuner Implementation Plan"
Cohesion: 0.20
Nodes (9): Better Tuner Implementation Plan, Global Constraints, Not covered here, Review Focus, Task 1: A4 reference in `Note`, Task 2: Band-pass filter, clarity bar and RMS floor, Task 3: `Smoother` — median plus outlier rejection, Task 4: Pitch history strip (+1 more)

### Community 6 - "Twang — better tuner: noise handling, A4 selection, pitch history strip"
Cohesion: 0.22
Nodes (8): Anti-goals, Context, Decided by the user, Goals, Left to the builder, Non-goals (this piece), Twang — better tuner: noise handling, A4 selection, pitch history strip, Verification

### Community 7 - "Note"
Cohesion: 0.24
Nodes (4): Note, .name, .octave, .activeString

### Community 8 - "View"
Cohesion: 0.14
Nodes (9): A4Ruler, .body, InstrumentPicker, .body, LevelMeter, .body, .body, TuningCards (+1 more)

### Community 10 - "screenshots.sh"
Cohesion: 0.67
Nodes (3): CLANG_MODULE_CACHE_PATH, screenshots.sh script, shoot()

### Community 11 - "PressScale"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 12 - "Strings"
Cohesion: 0.29
Nodes (3): Strings, .size, .tuner

### Community 13 - "Twang"
Cohesion: 0.20
Nodes (9): Build and run, Checks, Demo mode, Knowledge graph, Lint and format, Project layout, Releasing, Requirements (+1 more)

### Community 14 - "Instrument"
Cohesion: 0.11
Nodes (14): Instrument, banjo, bass, fiveStringBass, guitar, .id, mandolin, .name (+6 more)

### Community 15 - "inspector.tsx"
Cohesion: 0.06
Nodes (73): BackgroundControls(), Props, CalloutControls(), FocusPicker(), ActiveElementPanel(), CopyIdeasMenu(), ELEMENT_LABEL, setImageSource() (+65 more)

### Community 16 - "slide-canvas.tsx"
Cohesion: 0.08
Nodes (62): createImageMask(), ImageElementCanvas(), Props, addImageElement(), addTextElement(), PlacementPreviews(), PreviewStage(), alpha() (+54 more)

### Community 18 - "Current state (verified in code)"
Cohesion: 0.18
Nodes (5): Current state (verified in code), Needle, .body, Unavailable, .body

### Community 19 - "upload-font/route.ts"
Cohesion: 0.08
Nodes (41): dynamic, filePath(), GET(), POST(), revision(), writeProject(), writes, dynamic (+33 more)

### Community 20 - "ElementTransformControls"
Cohesion: 0.24
Nodes (17): elementLabel(), ElementTransformControls(), getTransform(), patchElement(), patchTextElement(), reorder(), setTextElementValue(), withElementTransform() (+9 more)

### Community 21 - "style-lab.tsx"
Cohesion: 0.06
Nodes (67): ScenePlayground(), patch(), surprise(), Section(), Segmented(), Slider(), Swatch(), Tile() (+59 more)

### Community 22 - "App Store Screenshots — Editor Template"
Cohesion: 0.06
Nodes (31): Apple bezels (7 October 2026), Bugs fixed and evidence, Duo capture checks and bezel measurement (9 October 2026), Editor end-to-end verification, Flow matrix, Honest limits, iPhone Duo, App Store creatives and issue 41 (2026-10-07), iPhone Duo design pass (7 October 2026) (+23 more)

### Community 23 - "png-encode.ts"
Cohesion: 0.17
Nodes (17): encodeCanvasPng(), encodeInline(), Job, jobs, Result, retireWorker(), workers(), applyFilter() (+9 more)

### Community 24 - "layouts.ts"
Cohesion: 0.06
Nodes (73): AndroidPhone(), AndroidTabletL(), AndroidTabletP(), AppleTV(), AppleWatch(), BezelFrame(), bezelFrameFor(), bezelFrames (+65 more)

### Community 25 - "PitchListener"
Cohesion: 0.22
Nodes (4): PitchListener, .a4, .detectionFloor, .sensitivity

### Community 26 - "package.json"
Cohesion: 0.08
Nodes (23): name, private, version, autoprefixer, clsx, @dnd-kit/core, @dnd-kit/utilities, postcss (+15 more)

### Community 27 - "project-schema.ts"
Cohesion: 0.07
Nodes (61): DEFAULT_SCREENSHOT_FONT_ID, DEFAULT_THEME_ID, fontAvailable(), IMPORTED_FONT_FAMILY, PROJECT_SCHEMA_VERSION, SCREENSHOT_FONTS, STORAGE_KEY, carplayStarter() (+53 more)

### Community 28 - "dependencies"
Cohesion: 0.09
Nodes (23): dependencies, class-variance-authority, clsx, @dnd-kit/core, @dnd-kit/sortable, @dnd-kit/utilities, html-to-image, lucide-react (+15 more)

### Community 29 - "TunerScreen"
Cohesion: 0.20
Nodes (6): SettingsSheet, TunerScreen, .body, .open, .reading, .settingsButton

### Community 30 - "Decided by Claude (user can override)"
Cohesion: 0.22
Nodes (5): AVFoundation, Task 5: A4 control, wired to tuner and reference tone, Decided by Claude (user can override), os, ReferenceTone

### Community 31 - "Reading"
Cohesion: 0.22
Nodes (4): Reading, .advice, .body, .inTune

### Community 32 - "compilerOptions"
Cohesion: 0.11
Nodes (18): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+10 more)

### Community 33 - "components.json"
Cohesion: 0.11
Nodes (17): aliases, components, hooks, lib, ui, utils, iconLibrary, rsc (+9 more)

### Community 34 - "scene-style-lab.e2e.ts"
Cohesion: 0.15
Nodes (8): googleChrome(), run, deck(), screen(), State, e2e, @e2e-dev/web, playwright

### Community 35 - "scripts"
Cohesion: 0.25
Nodes (8): scripts, build, dev, start, test:e2e, test:e2e:list, test:regression, typecheck

### Community 36 - "detectPitch"
Cohesion: 0.39
Nodes (4): detectPitch(), minimumLevel(), rms(), .listeningLevel

### Community 37 - "targets.e2e.ts"
Cohesion: 0.16
Nodes (8): jszip, fixture(), slide(), EXACT, State, zipFrom(), jszip, sharp

### Community 38 - "server.cjs"
Cohesion: 0.15
Nodes (9): child, { cpSync, mkdtempSync, symlinkSync, rmSync }, path, source, { spawn }, { tmpdir }, workspace, path (+1 more)

### Community 39 - "SwiftUI"
Cohesion: 0.25
Nodes (4): SwiftUI, View, History, .body

### Community 40 - "migration-fixture.cjs"
Cohesion: 0.19
Nodes (10): cleanTransform(), DEVICE_KEYS, firstString(), fs, LAYOUTS, localized(), migrateSlide(), path (+2 more)

### Community 41 - "bug-bash.cjs"
Cohesion: 0.17
Nodes (6): assert, baseURL, { chromium }, fixture(), fs, slide()

### Community 42 - "screenshot-editor.tsx"
Cohesion: 0.06
Nodes (73): react, Page(), fileToBase64(), FontImporter, FontImporterHandle, Props, Props, isTextEditable() (+65 more)

### Community 43 - "api-bug-bash.cjs"
Cohesion: 0.17
Nodes (8): assert, base, {execFileSync}, fs, os, path, {randomBytes}, sharp

### Community 44 - "devDependencies"
Cohesion: 0.18
Nodes (11): devDependencies, autoprefixer, e2e, @e2e-dev/web, playwright, postcss, tailwindcss, @types/node (+3 more)

### Community 45 - "ui-bug-bash.cjs"
Cohesion: 0.20
Nodes (6): assert, baseURL, { chromium }, fixture(), rect, slide()

### Community 46 - "frames/route.ts"
Cohesion: 0.29
Nodes (8): cache, dynamic, FRAMES_DIR, GET(), FRAME_FILES, FrameFile, MeasuredFrame, measureFrame()

### Community 47 - "drawText"
Cohesion: 0.24
Nodes (4): AppKit, CoreText, color(), drawText()

### Community 48 - "State"
Cohesion: 0.29
Nodes (5): State, denied, failed, idle, listening

### Community 49 - "filtered"
Cohesion: 0.39
Nodes (3): filtered(), noise(), tone()

### Community 54 - "tailwind.config.ts"
Cohesion: 0.50
Nodes (3): config, tailwindcss, tailwindcss-animate

## Knowledge Gaps
- **86 isolated node(s):** `guitar`, `sevenString`, `twelveString`, `ukulele`, `mandolin` (+81 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 412 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `inspector.tsx` to `screenshot-editor.tsx`, `slide-canvas.tsx`, `style-lab.tsx`, `layouts.ts`, `package.json`, `project-schema.ts`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Tuning` (e.g. with `Current state (verified in code)` and `.body`) actually correct?**
  _`Tuning` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `guitar`, `sevenString`, `twelveString` to the rest of the system?**
  _86 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._
- **Why does `dependencies` connect `dependencies` to `package.json`, `screenshot-editor.tsx`, `targets.e2e.ts`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Should `SelectionHighlight` be split into smaller, more focused modules?**
  _Cohesion score 0.1437908496732026 - nodes in this community are weakly interconnected._
- **Why does `DeviceDepth()` connect `slide-canvas.tsx` to `App Store Screenshots — Editor Template`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._