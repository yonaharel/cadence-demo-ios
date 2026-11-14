# Graph Report - cadence-demo-ios  (2026-11-13)

## Corpus Check
- 123 files · ~944,372 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 16 file(s) not represented in the graph (top: (none) 10, .xcconfig 1, .pbxproj 1)

## Summary
- 1124 nodes · 2747 edges · 54 communities (49 shown, 5 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 91 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2a5aa809`
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
- SwiftUI
- ci.sh
- screenshots.sh
- PressScale
- Strings
- Twang
- Instrument
- inspector.tsx
- slide-canvas.tsx
- resolve-graph-conflicts.sh
- Reading
- image-cache.ts
- ElementTransformControls
- screenshot-editor.tsx
- scene-layers.tsx
- png-encode.ts
- frame-assets.ts
- react
- package.json
- project-schema.ts
- dependencies
- background-controls.tsx
- scene-playground.tsx
- layouts.ts
- compilerOptions
- components.json
- scene-style-lab.e2e.ts
- cn
- SlideElements
- targets.e2e.ts
- server.cjs
- types.ts
- migration-fixture.cjs
- bug-bash.cjs
- toolbar.tsx
- api-bug-bash.cjs
- devDependencies
- ui-bug-bash.cjs
- frames/route.ts
- drawText
- contrast.ts
- filtered
- copy-ideas.ts
- FoldSplit
- next.config.mjs

## God Nodes (most connected - your core abstractions)
1. `cn()` - 53 edges
2. `Tuning` - 48 edges
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

## Communities (54 total, 5 thin omitted)

### Community 0 - "Tuning"
Cohesion: 0.06
Nodes (34): Tuning, banjoC, banjoDoubleC, banjoOpenD, banjoOpenG, cStandard, dadgad, doubleDropD (+26 more)

### Community 1 - "TunerViewModel"
Cohesion: 0.08
Nodes (16): TunerApp, .body, TunerViewModel, .hearing, .history, .level, .note, .state (+8 more)

### Community 2 - ".analyser"
Cohesion: 0.12
Nodes (7): Task 2: Band-pass filter, clarity bar and RMS floor, BandPass, Biquad, detectPitch(), minimumLevel(), rms(), .listeningLevel

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

### Community 8 - "SwiftUI"
Cohesion: 0.10
Nodes (11): SwiftUI, View, A4Ruler, .body, InstrumentPicker, .body, LevelMeter, .body (+3 more)

### Community 10 - "screenshots.sh"
Cohesion: 0.67
Nodes (3): CLANG_MODULE_CACHE_PATH, screenshots.sh script, shoot()

### Community 11 - "PressScale"
Cohesion: 0.38
Nodes (3): ButtonStyle, .pressScale, PressScale

### Community 12 - "Strings"
Cohesion: 0.18
Nodes (3): Strings, .body, .size

### Community 13 - "Twang"
Cohesion: 0.20
Nodes (9): Build and run, Checks, Demo mode, Knowledge graph, Lint and format, Project layout, Releasing, Requirements (+1 more)

### Community 14 - "Instrument"
Cohesion: 0.13
Nodes (11): Instrument, banjo, guitar, .id, mandolin, .name, sevenString, .stringCount (+3 more)

### Community 15 - "inspector.tsx"
Cohesion: 0.13
Nodes (26): CalloutControls(), FocusPicker(), ActiveElementPanel(), ELEMENT_LABEL, setImageSource(), fitToAspect(), FontScaleSlider(), LayerButton() (+18 more)

### Community 16 - "slide-canvas.tsx"
Cohesion: 0.14
Nodes (33): PlacementPreviews(), PreviewStage(), Props, Props, Caption(), clampRect(), CreativeGuide(), DeckCanvas() (+25 more)

### Community 18 - "Reading"
Cohesion: 0.10
Nodes (14): Current state (verified in code), Decided by Claude (user can override), ReferenceTone, History, .body, Needle, .body, Reading (+6 more)

### Community 19 - "image-cache.ts"
Cohesion: 0.06
Nodes (59): dynamic, filePath(), GET(), POST(), revision(), writeProject(), writes, dynamic (+51 more)

### Community 20 - "ElementTransformControls"
Cohesion: 0.21
Nodes (19): elementLabel(), ElementTransformControls(), getTransform(), patchElement(), patchTextElement(), reorder(), setTextElementValue(), withElementTransform() (+11 more)

### Community 21 - "screenshot-editor.tsx"
Cohesion: 0.06
Nodes (75): Page(), isTextEditable(), NON_TEXT_INPUT_TYPES, ScreenshotEditor(), captureSlide(), exportAll(), generateBundle(), onKey() (+67 more)

### Community 22 - "scene-layers.tsx"
Cohesion: 0.06
Nodes (40): Apple bezels (7 October 2026), Bugs fixed and evidence, Duo capture checks and bezel measurement (9 October 2026), Editor end-to-end verification, Flow matrix, Honest limits, iPhone Duo, App Store creatives and issue 41 (2026-10-07), iPhone Duo design pass (7 October 2026) (+32 more)

### Community 23 - "png-encode.ts"
Cohesion: 0.17
Nodes (17): encodeCanvasPng(), encodeInline(), Job, jobs, Result, retireWorker(), workers(), applyFilter() (+9 more)

### Community 24 - "frame-assets.ts"
Cohesion: 0.06
Nodes (67): AndroidPhone(), AndroidTabletL(), AndroidTabletP(), AppleTV(), AppleWatch(), BezelFrame(), bezelFrameFor(), bezelFrames (+59 more)

### Community 25 - "react"
Cohesion: 0.16
Nodes (11): ButtonProps, buttonVariants, labelVariants, TooltipContent, class-variance-authority, clsx, @radix-ui/react-label, @radix-ui/react-slot (+3 more)

### Community 26 - "package.json"
Cohesion: 0.09
Nodes (22): engines, node, name, overrides, nanoid, private, version, config (+14 more)

### Community 27 - "project-schema.ts"
Cohesion: 0.07
Nodes (64): cleanHexColor(), DEFAULT_SCREENSHOT_FONT_ID, DEFAULT_THEME_ID, IMPORTED_FONT_FAMILY, PROJECT_SCHEMA_VERSION, SCREENSHOT_FONTS, STORAGE_KEY, THEMES (+56 more)

### Community 28 - "dependencies"
Cohesion: 0.09
Nodes (23): dependencies, class-variance-authority, clsx, @dnd-kit/core, @dnd-kit/sortable, @dnd-kit/utilities, html-to-image, lucide-react (+15 more)

### Community 29 - "background-controls.tsx"
Cohesion: 0.32
Nodes (7): BackgroundControls(), Props, ImageElementPanel(), Input, SelectContent, SelectItem, SelectTrigger

### Community 30 - "scene-playground.tsx"
Cohesion: 0.23
Nodes (12): ScenePlayground(), patch(), surprise(), Section(), Segmented(), Slider(), Tile(), TileGroup() (+4 more)

### Community 31 - "layouts.ts"
Cohesion: 0.15
Nodes (21): Inspector(), setLocaleField(), Textarea, ALL_LAYOUTS, defaultCalloutRect(), defaultElementZ(), DUO_PAIR, elementRects() (+13 more)

### Community 32 - "compilerOptions"
Cohesion: 0.11
Nodes (18): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+10 more)

### Community 33 - "components.json"
Cohesion: 0.11
Nodes (17): aliases, components, hooks, lib, ui, utils, iconLibrary, rsc (+9 more)

### Community 34 - "scene-style-lab.e2e.ts"
Cohesion: 0.15
Nodes (8): googleChrome(), run, deck(), screen(), State, e2e, @e2e-dev/web, playwright

### Community 35 - "cn"
Cohesion: 0.19
Nodes (16): CopyIdeasMenu(), Card, CardContent, CardHeader, CardTitle, DropdownMenuCheckboxItem, DropdownMenuContent, DropdownMenuItem (+8 more)

### Community 36 - "SlideElements"
Cohesion: 0.27
Nodes (18): addImageElement(), addTextElement(), Movable(), startRotate(), normalizeRotation(), pointerAngle(), SlideElements(), renderCallout() (+10 more)

### Community 37 - "targets.e2e.ts"
Cohesion: 0.16
Nodes (8): jszip, fixture(), slide(), EXACT, State, zipFrom(), jszip, sharp

### Community 38 - "server.cjs"
Cohesion: 0.15
Nodes (9): child, { cpSync, mkdtempSync, symlinkSync, rmSync }, path, source, { spawn }, { tmpdir }, workspace, path (+1 more)

### Community 39 - "types.ts"
Cohesion: 0.21
Nodes (10): createImageMask(), ImageElementCanvas(), Props, Callout, ElementTransform, ImageElement, LocalizedText, SelectedElement (+2 more)

### Community 40 - "migration-fixture.cjs"
Cohesion: 0.19
Nodes (10): cleanTransform(), DEVICE_KEYS, firstString(), fs, LAYOUTS, localized(), migrateSlide(), path (+2 more)

### Community 41 - "bug-bash.cjs"
Cohesion: 0.17
Nodes (6): assert, baseURL, { chromium }, fixture(), fs, slide()

### Community 42 - "toolbar.tsx"
Cohesion: 0.21
Nodes (17): react, FontImporter, Props, SaveStatus(), ThemeOption(), Toolbar(), DialogContent, DialogDescription (+9 more)

### Community 43 - "api-bug-bash.cjs"
Cohesion: 0.17
Nodes (8): assert, base, {execFileSync}, fs, os, path, {randomBytes}, sharp

### Community 44 - "devDependencies"
Cohesion: 0.10
Nodes (19): devDependencies, autoprefixer, e2e, @e2e-dev/web, playwright, postcss, tailwindcss, @types/node (+11 more)

### Community 45 - "ui-bug-bash.cjs"
Cohesion: 0.20
Nodes (6): assert, baseURL, { chromium }, fixture(), rect, slide()

### Community 46 - "frames/route.ts"
Cohesion: 0.29
Nodes (8): cache, dynamic, FRAMES_DIR, GET(), FRAME_FILES, FrameFile, MeasuredFrame, measureFrame()

### Community 47 - "drawText"
Cohesion: 0.24
Nodes (4): AppKit, CoreText, color(), drawText()

### Community 48 - "contrast.ts"
Cohesion: 0.47
Nodes (8): Swatch(), SlideBackground(), contrastRatio(), firstReadable(), isDarkColor(), parseHex(), relativeLuminance(), slideColors

### Community 49 - "filtered"
Cohesion: 0.57
Nodes (3): filtered(), noise(), tone()

### Community 50 - "copy-ideas.ts"
Cohesion: 0.50
Nodes (3): COPY_IDEA_SLOTS, CopyIdea, CopyIdeaSlot

## Knowledge Gaps
- **78 isolated node(s):** `guitar`, `sevenString`, `twelveString`, `ukulele`, `mandolin` (+73 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 405 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `dependencies` connect `dependencies` to `package.json`, `toolbar.tsx`, `targets.e2e.ts`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Tuning` (e.g. with `Current state (verified in code)` and `.body`) actually correct?**
  _`Tuning` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `guitar`, `sevenString`, `twelveString` to the rest of the system?**
  _78 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Tuning` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `react` connect `react` to `cn`, `types.ts`, `toolbar.tsx`, `inspector.tsx`, `slide-canvas.tsx`, `image-cache.ts`, `screenshot-editor.tsx`, `scene-layers.tsx`, `frame-assets.ts`, `package.json`, `project-schema.ts`, `background-controls.tsx`, `scene-playground.tsx`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **Should `TunerViewModel` be split into smaller, more focused modules?**
  _Cohesion score 0.0846774193548387 - nodes in this community are weakly interconnected._
- **Why does `jszip` connect `targets.e2e.ts` to `bug-bash.cjs`, `package.json`, `scene-style-lab.e2e.ts`, `screenshot-editor.tsx`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._