# Graph Report - demo-ios  (2026-11-14)

## Corpus Check
- 123 files · ~886,680 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 108 file(s) not represented in the graph (top: .bin 69, .tmp 12, (none) 10)

## Summary
- 1113 nodes · 2698 edges · 53 communities (44 shown, 9 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 91 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f958cac9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Tuning
- TunerViewModel
- .analyser
- PitchListener.kt
- SelectionHighlight
- Tuner
- Twang — better tuner: noise handling, A4 selection, pitch history strip
- Note
- SwiftUI
- ci.sh
- screenshots.sh
- Twang
- Reading
- Twang
- Content
- inspector.tsx
- slide-canvas.tsx
- resolve-graph-conflicts.sh
- Reading
- upload-font/route.ts
- ElementTransformControls
- screenshot-editor.tsx
- App Store Screenshots — Editor Template
- export-render.ts
- frame-assets.ts
- cn
- package.json
- project-schema.ts
- dependencies
- background-controls.tsx
- scene-playground.tsx
- Label
- compilerOptions
- components.json
- scene-style-lab.e2e.ts
- editor.e2e.ts
- targets.e2e.ts
- server.cjs
- migration-fixture.cjs
- bug-bash.cjs
- toolbar.tsx
- api-bug-bash.cjs
- devDependencies
- ui-bug-bash.cjs
- frames/route.ts
- scripts
- filtered
- FoldSplit
- tailwind.config.ts
- next.config.mjs
- engines
- overrides

## God Nodes (most connected - your core abstractions)
1. `cn()` - 53 edges
2. `Tuning` - 48 edges
3. `ScreenshotEditor()` - 37 edges
4. `Inspector()` - 30 edges
5. `ElementTransformControls()` - 30 edges
6. `react` - 29 edges
7. `StyleLab()` - 28 edges
8. `Toolbar()` - 28 edges
9. `Button` - 27 edges
10. `TunerViewModel` - 27 edges

## Surprising Connections (you probably didn't know these)
- `Task 1: A4 reference in `Note`` --references--> `Note`  [INFERRED]
  docs/superpowers/plans/2026-10-19-better-tuner.md → Tuner/Models/Note.swift
- `Current state (verified in code)` --references--> `Tuning`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Models/Tuning.swift
- `Current state (verified in code)` --references--> `Strings`  [INFERRED]
  docs/superpowers/specs/2026-10-19-better-tuner-design.md → Tuner/Views/Tuner/Strings.swift
- `Task 5: A4 control, wired to tuner and reference tone` --references--> `ReferenceTone`  [INFERRED]
  docs/superpowers/plans/2026-10-19-better-tuner.md → Tuner/Services/ReferenceTone.swift
- `Better Tuner Implementation Plan` --references--> `History`  [INFERRED]
  docs/superpowers/plans/2026-10-19-better-tuner.md → Tuner/Views/Tuner/History.swift

## Import Cycles
- None detected.

## Communities (53 total, 9 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.06
Nodes (34): Tuning, banjoC, banjoDoubleC, banjoOpenD, banjoOpenG, cStandard, dadgad, doubleDropD (+26 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.08
Nodes (16): TunerApp, .body, TunerViewModel, .hearing, .history, .level, .note, .state (+8 more)

### Community 2 - ".analyser"
Cohesion: 0.12
Nodes (7): Task 2: Band-pass filter, clarity bar and RMS floor, BandPass, Biquad, detectPitch(), minimumLevel(), rms(), .listeningLevel

### Community 3 - "PitchListener.kt"
Cohesion: 0.15
Nodes (6): AVFoundation, Combine, Foundation, Observation, os, Sharing

### Community 4 - "SelectionHighlight"
Cohesion: 0.14
Nodes (4): SelectionHighlight, View, StaggeredAppear, View

### Community 5 - "Tuner"
Cohesion: 0.15
Nodes (13): Better Tuner Implementation Plan, Global Constraints, Not covered here, Review Focus, Task 1: A4 reference in `Note`, Task 3: `Smoother` — median plus outlier rejection, Task 4: Pitch history strip, Task 5: A4 control, wired to tuner and reference tone (+5 more)

### Community 6 - "Twang — better tuner: noise handling, A4 selection, pitch history strip"
Cohesion: 0.22
Nodes (8): Anti-goals, Context, Decided by the user, Goals, Left to the builder, Non-goals (this piece), Twang — better tuner: noise handling, A4 selection, pitch history strip, Verification

### Community 7 - "Note"
Cohesion: 0.12
Nodes (9): Note, .name, .octave, State, denied, failed, idle, listening (+1 more)

### Community 8 - "SwiftUI"
Cohesion: 0.10
Nodes (11): SwiftUI, View, A4Ruler, .body, InstrumentPicker, .body, LevelMeter, .body (+3 more)

### Community 11 - "Twang"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 12 - "Reading"
Cohesion: 0.18
Nodes (3): Strings, .body, .size

### Community 13 - "Twang"
Cohesion: 0.20
Nodes (9): Build and run, Checks, Demo mode, Knowledge graph, Lint and format, Project layout, Releasing, Requirements (+1 more)

### Community 14 - "Content"
Cohesion: 0.13
Nodes (11): Instrument, banjo, guitar, .id, mandolin, .name, sevenString, .stringCount (+3 more)

### Community 15 - "inspector.tsx"
Cohesion: 0.11
Nodes (25): CopyIdeasMenu(), ELEMENT_LABEL, setImageSource(), fitToAspect(), naturalSize(), Props, TypographySection(), patchTypography() (+17 more)

### Community 16 - "slide-canvas.tsx"
Cohesion: 0.06
Nodes (82): createImageMask(), ImageElementCanvas(), Props, PlacementPreviews(), PreviewStage(), Props, alpha(), backdropArt() (+74 more)

### Community 18 - "Reading"
Cohesion: 0.10
Nodes (14): Current state (verified in code), Decided by Claude (user can override), ReferenceTone, History, .body, Needle, .body, Reading (+6 more)

### Community 19 - "upload-font/route.ts"
Cohesion: 0.07
Nodes (47): dynamic, filePath(), GET(), POST(), revision(), writeProject(), writes, dynamic (+39 more)

### Community 20 - "ElementTransformControls"
Cohesion: 0.13
Nodes (38): elementLabel(), ElementTransformControls(), addImageElement(), addTextElement(), getTransform(), patchElement(), patchTextElement(), reorder() (+30 more)

### Community 21 - "screenshot-editor.tsx"
Cohesion: 0.05
Nodes (76): Page(), setLocaleField(), isTextEditable(), NON_TEXT_INPUT_TYPES, ScreenshotEditor(), captureSlide(), exportAll(), generateBundle() (+68 more)

### Community 22 - "App Store Screenshots — Editor Template"
Cohesion: 0.06
Nodes (31): Apple bezels (7 October 2026), Bugs fixed and evidence, Duo capture checks and bezel measurement (9 October 2026), Editor end-to-end verification, Flow matrix, Honest limits, iPhone Duo, App Store creatives and issue 41 (2026-10-07), iPhone Duo design pass (7 October 2026) (+23 more)

### Community 23 - "export-render.ts"
Cohesion: 0.17
Nodes (17): encodeCanvasPng(), encodeInline(), Job, jobs, Result, retireWorker(), workers(), applyFilter() (+9 more)

### Community 24 - "frame-assets.ts"
Cohesion: 0.06
Nodes (77): CalloutControls(), AndroidPhone(), AndroidTabletL(), AndroidTabletP(), AppleTV(), AppleWatch(), BezelFrame(), bezelFrameFor() (+69 more)

### Community 25 - "cn"
Cohesion: 0.20
Nodes (12): ButtonProps, buttonVariants, Card, CardContent, CardHeader, CardTitle, Textarea, TooltipContent (+4 more)

### Community 26 - "package.json"
Cohesion: 0.09
Nodes (22): name, private, version, autoprefixer, clsx, @dnd-kit/core, @dnd-kit/utilities, postcss (+14 more)

### Community 27 - "project-schema.ts"
Cohesion: 0.07
Nodes (66): DEFAULT_SCREENSHOT_FONT_ID, DEFAULT_THEME_ID, fontAvailable(), IMPORTED_FONT_FAMILY, PROJECT_SCHEMA_VERSION, SCREENSHOT_FONTS, STORAGE_KEY, carplayStarter() (+58 more)

### Community 28 - "dependencies"
Cohesion: 0.08
Nodes (25): dependencies, class-variance-authority, clsx, @dnd-kit/core, @dnd-kit/sortable, @dnd-kit/utilities, html-to-image, jszip (+17 more)

### Community 29 - "background-controls.tsx"
Cohesion: 0.29
Nodes (8): BackgroundControls(), Props, ImageElementPanel(), Input, SelectContent, SelectItem, SelectTrigger, cleanHexColor()

### Community 30 - "scene-playground.tsx"
Cohesion: 0.25
Nodes (12): ScenePlayground(), patch(), surprise(), Section(), Segmented(), Slider(), Swatch(), Tile() (+4 more)

### Community 31 - "Label"
Cohesion: 0.23
Nodes (9): FocusPicker(), ActiveElementPanel(), FontScaleSlider(), LayerButton(), ResetButton(), TextElementPanel(), Label, labelVariants (+1 more)

### Community 32 - "compilerOptions"
Cohesion: 0.11
Nodes (18): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+10 more)

### Community 33 - "components.json"
Cohesion: 0.11
Nodes (17): aliases, components, hooks, lib, ui, utils, iconLibrary, rsc (+9 more)

### Community 34 - "scene-style-lab.e2e.ts"
Cohesion: 0.19
Nodes (7): googleChrome(), deck(), screen(), State, e2e, @e2e-dev/web, playwright

### Community 35 - "editor.e2e.ts"
Cohesion: 0.50
Nodes (3): fixture(), slide(), jszip

### Community 38 - "server.cjs"
Cohesion: 0.13
Nodes (10): child, { cpSync, mkdtempSync, symlinkSync, rmSync }, path, source, { spawn }, { tmpdir }, workspace, path (+2 more)

### Community 40 - "migration-fixture.cjs"
Cohesion: 0.19
Nodes (10): cleanTransform(), DEVICE_KEYS, firstString(), fs, LAYOUTS, localized(), migrateSlide(), path (+2 more)

### Community 41 - "bug-bash.cjs"
Cohesion: 0.17
Nodes (6): assert, baseURL, { chromium }, fixture(), fs, slide()

### Community 42 - "toolbar.tsx"
Cohesion: 0.20
Nodes (16): Props, SaveStatus(), ThemeOption(), Toolbar(), DialogContent, DialogDescription, DialogHeader(), DialogOverlay (+8 more)

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
Cohesion: 0.27
Nodes (8): cache, dynamic, FRAMES_DIR, GET(), FrameFile, MeasuredFrame, measureFrame(), sharp

### Community 48 - "scripts"
Cohesion: 0.25
Nodes (8): scripts, build, dev, start, test:e2e, test:e2e:list, test:regression, typecheck

### Community 49 - "filtered"
Cohesion: 0.57
Nodes (3): filtered(), noise(), tone()

### Community 52 - "tailwind.config.ts"
Cohesion: 0.50
Nodes (3): config, tailwindcss, tailwindcss-animate

## Knowledge Gaps
- **75 isolated node(s):** `@types/node`, `@types/react`, `@types/react-dom`, `autoprefixer`, `postcss` (+70 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 407 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `jszip` connect `editor.e2e.ts` to `scene-style-lab.e2e.ts`, `targets.e2e.ts`, `bug-bash.cjs`, `screenshot-editor.tsx`, `package.json`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Tuning` (e.g. with `Current state (verified in code)` and `.body`) actually correct?**
  _`Tuning` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `@types/node`, `@types/react`, `@types/react-dom` to the rest of the system?**
  _75 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `react` connect `cn` to `toolbar.tsx`, `inspector.tsx`, `slide-canvas.tsx`, `upload-font/route.ts`, `screenshot-editor.tsx`, `frame-assets.ts`, `package.json`, `project-schema.ts`, `background-controls.tsx`, `scene-playground.tsx`, `Label`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **Should `TunerViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.0846774193548387 - nodes in this community are weakly interconnected._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._