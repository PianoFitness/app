# PianoKeyboard Component Specification

## Overview

The PianoKeyboard component is a custom Flutter widget that renders an interactive piano keyboard, replacing the third-party `piano` pub package currently in use. The existing package can only highlight one key state at a time and has no way to annotate a key (e.g. with a finger number), which blocks features like showing "press this key" and "this is what you just pressed" and "use finger 2" simultaneously. The new component models each key's visual state as a set of independently composable indicators, so any combination of guidance can render on a single key at once.

## Goals

- **Composable indicators**: fill, outline, dot, and label can each be set independently on the same key, with no fixed meaning baked into the widget.
- **Configurable range**: support any key range (25/37/49/61/76/88-key layouts, or an arbitrary `NoteRange`), not just a hardcoded 49-key layout.
- **Independent annotation**: finger-number labels and static note-name labels are separate concerns and can both be shown at once.
- **No regression**: preserve existing MIDI integration, dynamic-range calculation (`PianoRangeUtils`), and accessibility wrappers (`PianoSemanticsService`, `AccessiblePiano`) built around the current widget.

## Requirements

### Functional Requirements

- Renders a piano keyboard for an arbitrary `NoteRange` (from/to MIDI bounds), not a fixed key count.
- Accepts a `ValueListenable<Map<int, PianoKeyVisual>>` keyed by MIDI note number; notes absent from the map render with default/neutral appearance.
- `PianoKeyVisual` independently supports:
  - `fill`: `Color?` — background tint of the key.
  - `outline`: `Color?` — border stroke around the key.
  - `dot`: `Color?` — small circular indicator on the key.
  - `label`: `String?` — short annotation, e.g. a finger number (`"1"`, `"R2"`, `"L1"`).
- Any subset of these fields may be set simultaneously — a key can show fill + outline + dot + label all at once.
- A widget-level note-label mode (none / note name / MIDI number) renders a static per-key label independent of the per-key `label` field, so both a note name and a finger number can appear on the same key.
- Optional on-screen play input via `onKeyDown(int midiNote)` / `onKeyUp(int midiNote)` callbacks, tied to real pointer press/release rather than a synthetic timer-based release (replacing the fixed-duration `Timer` hack in today's `virtual_piano_utils.dart`). Display-only usages (pure MIDI listening) can omit both.
  - **Multi-touch**: each pointer is tracked independently by id, so multiple simultaneous touches produce concurrent `onKeyDown` calls (chords).
  - **Glissando**: a single-finger drag across keys emits `onKeyUp` for the key being left and `onKeyDown` for the key being entered as the pointer crosses key boundaries; lifting the pointer (or a `PointerCancelEvent`) emits a final `onKeyUp` — cancellation must never leave a note stuck on, which is exactly the class of bug the old `Timer` hack was papering over.
  - **Gesture arbitration**: single-finger drag on the key surface is always glissando, never scroll — the widget does not attempt to disambiguate a horizontal drag by distance or velocity. Manual scrolling (when the range doesn't fit the viewport) is a two-finger pan, or mouse-wheel/trackpad horizontal scroll on desktop/web. `enableGlissando: bool` (default `true`) lets a caller disable retrigger-on-drag in favor of slide-off-to-cancel behavior.
  - A `PianoKeyboardController` exposes `ensureVisible(int midiNote)` so callers (e.g. an exercise engine) can programmatically scroll a target key into view without fighting the widget's internal scroll ownership.
- Updating the `keyVisuals` value alone must be sufficient to repaint the dynamic layer — no full keyboard widget rebuild and no repaint of the static layer per state change. MIDI notes present in `keyVisuals` but outside the current `NoteRange` are silently ignored (not rendered, not an error).

### Technical Requirements

- Key identity is the MIDI note number (`int`), matching the existing `PianoNoteBridge` boundary conversions. The widget does not need to know about `NotePosition` internally.
- No dependency on the `piano` pub package; implemented with `CustomPainter`/widgets directly in this codebase.
- Fixed rendering z-order per key: base key shape → `fill` → `outline` → `dot` → text labels (static note/MIDI label, then per-key `label`).
- Must consume `NoteRange` values produced by the existing `PianoRangeUtils` helpers without requiring changes to that class's public API.
- Rendering is split into two layers: a static layer (key shapes, static note/MIDI labels) painted once and cached whenever the `NoteRange` changes, and a dynamic layer (`fill`/`outline`/`dot`/per-key `label`) repainted whenever the `keyVisuals` listenable fires. Per-key `RepaintBoundary`s are not used by default; revisit only if profiling shows the dynamic layer itself is the bottleneck.
- The widget owns its own horizontal scrolling with a minimum comfortable key width (≥44dp per white key). If the available width can't fit the configured range at that minimum, the widget scrolls internally rather than shrinking keys below the floor or overflowing.
- **`keyVisuals` change detection**: the widget relies on `ValueListenable` notification, which fires on reference/`==` change, not deep content diffing. Callers must publish a new `Map` instance (ideally unmodifiable) on every update rather than mutating an existing instance in place and reassigning the same reference — the latter will not notify and is a documented anti-pattern, not a widget bug.
- **Key geometry and hit testing**: black keys are visually and hit-test layered on top of white keys, sized per the existing design-system tokens (`ComponentDimensions.blackKeyWidth` / `whiteKeyWidth` ≈ 0.6 ratio, `blackKeyHeight` / `whiteKeyHeight` ≈ 0.67 ratio), positioned per the standard chromatic octave (black keys between C–D, D–E, F–G, G–A, A–B; no black key between E–F or B–C). Hit testing checks black-key bounding boxes first (the flush-top region where they overlap white keys); a miss falls through to the white key beneath. A `NoteRange` that starts or ends mid-octave is expanded outward (never truncated inward) to the nearest white-key boundary internally by the widget, so no requested note is ever clipped and `PianoRangeUtils` needs no changes to guarantee this.

### Performance Requirements

- 60fps rendering during active MIDI input with multiple simultaneous key states.
- Visual response to a MIDI note-on/off event within one frame (~16ms) of the corresponding `keyVisuals` update.
- Verified via an `integration_test` timeline benchmark: a scripted stream of MIDI-driven `keyVisuals` updates (≥20 events/sec) is fed to the widget while `IntegrationTestWidgetsFlutterBinding.instance.watchPerformance` (or equivalent) asserts p90 frame build+raster time stays under the 16ms budget. A documented manual DevTools profiling procedure is the fallback if an automated timeline benchmark proves impractical, but the criterion is not satisfied by visual inspection alone.

## Accessibility

- **Screen reader**: preserve integration with `PianoSemanticsService` / `AccessiblePiano`; each key's semantic label describes note name, target/pressed state, and finger annotation when present. Because the keyboard is a single `CustomPainter` rather than per-key widgets, semantics are supplied via `CustomPainter.semanticsBuilder` (a `SemanticsBuilderCallback` producing one `SemanticsNode` per key) rather than an overlay of invisible `Semantics` widgets — the overlay approach would silently reintroduce the per-key widget cost the static/dynamic layer split was designed to avoid. Each key's semantics exposes a tap action (`SemanticsAction.tap`) that fires the same `onKeyDown`/`onKeyUp` pair as a physical touch, so on-screen play is not gesture-only and remains usable via a screen reader's activate action.
- **Contrast**: `fill`, `outline`, and `dot` colors must meet WCAG AA contrast against both white- and black-key backgrounds, in light and dark themes. Base key colors (white/black, light/dark) come from the existing `ColorSystem`/`ComponentDimensions` tokens in `design-system.md` (e.g. `whiteKey`, `blackKey`, `whiteKeyDark`, `blackKeyDark`). Contrast itself is enforced through those design-system color tokens plus a widget/golden test validating them, not a runtime `assert()` inside the widget — the widget accepts whatever colors it's given and cannot itself judge whether an arbitrary injected `Color` passes contrast.
- **Color is never the sole cue**: outline and dot indicators must be distinguishable by shape/position, not hue alone, so colorblind users can still tell indicators apart; `label` text (e.g. finger number) provides a redundant cue where relevant.
- **Text scaling**: finger-number and note labels stay legible at enlarged system font sizes. Label badges are fixed-size and anchored to a normative position (see Design Notes); at large text scale the text shrinks to fit its fixed badge rather than growing the badge and disturbing key layout. Finger labels are capped at 2–3 characters (e.g. `"R1"`, `"L5"`); anything longer is truncated with an ellipsis.
- **Reduced motion**: any transition animation between visual states is skippable/instant when the system's reduced-motion setting is enabled.

## Design Notes

**`PianoKeyVisual`** (per-key, immutable)

- Holds `fill`, `outline`, `dot` (all `Color?`) and `label` (`String?`).
- No field carries inherent meaning — "this is the target key" or "this was pressed correctly" is a decision the caller/view-model makes, not the widget. The caller resolves any overlapping meanings (target + pressed + correctness + finger number) into a single `PianoKeyVisual` per note before handing it to the widget.
- Collected into `Map<int, PianoKeyVisual>`, keyed by MIDI note number, passed to the widget on each build.

**`PianoKeyboard` widget**

- Takes a `NoteRange` instead of assuming 49 keys; `PianoRangeUtils.standard49KeyRange`, `calculateOptimalRange`, `calculateRangeForExercise`, etc. continue to produce this input unchanged. The widget expands any mid-octave range outward to the nearest white-key boundary internally (see Technical Requirements) rather than requiring callers to pre-snap it.
- Takes `keyVisuals` (a `ValueListenable`), a note-label display mode, `enableGlissando`, and optional `onKeyDown`/`onKeyUp`.
- Computes white/black key geometry once per range change; per-frame updates touch only the dynamic paint layer driven by `keyVisuals`, avoiding layout recalculation on every MIDI event.
- Owns a single pointer-tracking `Listener` spanning the whole keyboard (not one gesture detector per key) so it can resolve multi-touch chords and glissando drags against key geometry itself. One-finger drags always resolve to glissando; two-finger drags (or mouse-wheel/trackpad input) pan the internal scroll view.
- A `PianoKeyboardController` wraps the internal `ScrollController` and exposes `ensureVisible(int midiNote)` for callers that need to bring a specific key into view programmatically (e.g. an exercise engine scrolling to the next target note).

```text
PianoKeyboard(
  range: NoteRange,
  keyVisuals: ValueListenable<Map<int, PianoKeyVisual>>,
  noteLabelMode: NoteLabelMode.none | .name | .midiNumber,
  enableGlissando: bool, // default true
  onKeyDown: void Function(int midiNote)?,
  onKeyUp: void Function(int midiNote)?,
  controller: PianoKeyboardController?,
)
```

Example composition at a call site (practice mode): the view-model resolves target/pressed/correctness/finger-number into one `PianoKeyVisual` per note before the widget ever sees it — target notes get `outline`, the currently pressed note gets `dot`, a wrong press swaps the `dot` color to an error color, and `label` carries the finger number. The widget itself has no concept of "target" or "correct"; it only draws the four channels it's given.

**Label layout** (normative anchor positions, so "distinguishable by shape/position" is verifiable rather than left to the implementer):

- Static note/MIDI-number label: bottom third of the key (white keys always; black keys only if legible at their width, otherwise omitted at that label mode).
- Per-key `label` (finger number): fixed-size badge anchored to the upper third of the key, matching the conventional placement of fingering numbers above a note in sheet music.
- `dot`: centered in the middle third of the key, clear of both label zones.
- `outline`: full key border. `fill`: full key background tint.

## Integration Points

- **`PianoRangeUtils`**: supplies the `NoteRange` input; no changes needed to its public API.
- **`PianoNoteBridge`**: continues converting between MIDI note numbers and `NotePosition`-style data at the boundary of MIDI services.
- **`design-system.md`**: base key colors and key dimensions (`whiteKey`, `blackKey`, `whiteKeyDark`, `blackKeyDark`, `whiteKeyWidth`/`Height`, `blackKeyWidth`/`Height`) are sourced from its existing `ColorSystem`/`ComponentDimensions` tokens rather than redefined here.
- **Accessibility architecture** (`lib/shared/accessibility/`): `PianoSemanticsService` and `AccessiblePiano` wrap this widget the same way they wrapped the previous `InteractivePiano`; semantic descriptions gain finger-number and multi-indicator phrasing.
- **Visual Feedback System spec**: this component is the rendering target for that spec's key-state model. The "one `Set<int>` per state" model described there is superseded by the `PianoKeyVisual` map. Updating that spec is part of this component's definition of done, not a deferred follow-up — shipping this component without it leaves two contradictory sources of truth.
- **`virtual_piano_utils.dart`**: its `Timer`-based synthetic note-off (used to fake key release with the old tap-only API) becomes unnecessary once real `onKeyDown`/`onKeyUp` events exist, and should be removed as part of the migration.

## Testing Requirements

### Unit Tests

- MIDI note number ↔ key-position mapping for arbitrary ranges (25/49/61/88 keys).
- Correct z-order composition when a key has `fill` + `outline` + `dot` + `label` all set.
- Default/neutral rendering for notes absent from `keyVisuals`; notes present in `keyVisuals` but outside the current `NoteRange` are ignored without error.
- Black-key vs. white-key hit testing across the full octave, including the overlap region.
- A `NoteRange` starting/ending mid-octave is expanded outward to the nearest white-key boundary, never truncated.
- Mutating an existing `keyVisuals` map instance in place and reassigning the same reference does **not** notify listeners — a regression test documenting this as a caller contract, not a widget bug.

### Widget Tests

- Visual rendering of each indicator (`fill`, `outline`, `dot`, `label`) in isolation and in combination.
- Note-label mode toggle behaves independently of the per-key `label` field.
- `onKeyDown`/`onKeyUp` fire with the correct MIDI note number on press and release.
- Dragging a pointer across multiple keys emits the correct sequence of `onKeyUp`/`onKeyDown` pairs as key boundaries are crossed.
- Multiple simultaneous pointers produce independent, concurrent `onKeyDown`/`onKeyUp` pairs (chords).
- A `PointerCancelEvent` mid-press still emits `onKeyUp` (no stuck notes).
- One-finger drag always resolves to glissando; two-finger drag (or mouse-wheel/trackpad) pans the view instead of retriggering notes.
- `enableGlissando: false` suppresses retrigger-on-drag.
- `PianoKeyboardController.ensureVisible(midiNote)` scrolls the target key into view.
- Updating the `keyVisuals` listenable (via a new `Map` instance) does not trigger a `PianoKeyboard.build()` call (rebuild-avoidance check).
- Keyboard falls back to internal horizontal scrolling rather than shrinking keys below the minimum width when constrained.
- Each key's semantics node exposes a working tap action that fires `onKeyDown`/`onKeyUp` (screen-reader playability).
- Design-system color tokens used for `fill`/`outline`/`dot` meet WCAG AA contrast (golden/contrast-check test).

### Integration Tests

- Real-time MIDI input driving `keyVisuals` updates end-to-end.
- Range changes (dynamic range recalculation) reflow the keyboard without losing in-flight key state.

## Acceptance Criteria

- [ ] Renders any configured `NoteRange`, not just a fixed 49-key layout.
- [ ] A single key can display `fill`, `outline`, `dot`, and `label` simultaneously, each independently controlled.
- [ ] Note-label display is togglable independent of per-key finger-number labels.
- [ ] No dependency on the `piano` pub package remains.
- [ ] Updating `keyVisuals` repaints only the dynamic layer, without rebuilding the `PianoKeyboard` widget or repainting the static layer.
- [ ] On-screen play supports true press/release (`onKeyDown`/`onKeyUp`), multi-touch chords, glissando drag across keys, and correct behavior on pointer cancellation — no synthetic timer-based release, no stuck notes.
- [ ] One-finger drag is unambiguously glissando; two-finger/wheel/trackpad input pans the view — no gesture ambiguity between playing and scrolling.
- [ ] `PianoKeyboardController.ensureVisible(midiNote)` lets a caller scroll a specific key into view.
- [ ] Keyboard scrolls internally rather than shrinking keys below the minimum touch-target width when space-constrained; ranges starting/ending mid-octave are expanded to white-key boundaries, never truncated.
- [ ] Each key is playable via a screen reader's activation action, not touch-gesture-only.
- [ ] Maintains 60fps during active MIDI input with multiple simultaneous key states, verified by an automated timeline benchmark.
- [ ] Integrates with existing `PianoRangeUtils`, `PianoNoteBridge`, `design-system.md` tokens, and accessibility wrappers without changes to their public APIs.
- [ ] Meets WCAG AA contrast for all indicator colors in light and dark themes, verified via design-system token tests rather than runtime asserts.
- [ ] `visual-feedback-system.md` is updated to reflect the `PianoKeyVisual` model as part of this component's definition of done.
- [ ] Comprehensive unit/widget/integration test coverage per above.

## Future Enhancements

- Stackable indicators of the same kind (e.g. more than one dot), if a real use case needs it beyond the current single-slot-per-channel design.
- Dual-hand finger annotation (simultaneous left/right labels on one key) if a concrete exercise needs it.
- Velocity-based intensity variation on `fill`/`dot`.
- Animated transitions between visual states (respecting reduced motion).
