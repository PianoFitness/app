<!--
  Status: Draft
  Created: 2026-07-21
  Last updated: 2026-07-21
-->

# Exercise Accuracy Specification

## Overview

This is a **specification only** — it defines what an "accuracy" metric should
mean for Piano Fitness exercises, how it's measured and shown in real time
during practice, and where it hooks into the existing practice loop and
history schema. No implementation is included or assumed to follow
immediately, but every decision needed to start one has been made (see
**Decisions Log**).

Today, the practice page does not count errors. `PracticeSession` (see
`exercise-sequence.md`) evaluates each step by exact pitch-set equality only:
a step advances the moment the currently-held MIDI notes exactly match the
step's expected set, and there is no branch anywhere in that evaluation loop
that distinguishes "the student played a wrong note" from "the student hasn't
finished playing the right notes yet." Because nothing counts errors,
`ExerciseHistoryEntry` (see `exercise-history.md`) has no accuracy-related
field, and neither the practice page nor the History page (see
`practice-history-page.md`) can show one.

This matters pedagogically. Piano Fitness already logs practice **quantity**
generously — exercise-history.md's MVP completion criteria award a logged
"set" for simply playing all the notes in a sequence, "regardless of accuracy
or timing," specifically to keep the logging habit low-friction. Accuracy is
the complementary **quality** signal that quantity alone can't provide. A
student who repeatedly logs completions with a high error rate is very likely
either attempting material above their current level or playing faster than
their fingers or reading can reliably support — the two classic causes of
plateaus and bad-habit formation in instrumental practice. Surfacing accuracy
gives the app (and, later, the student or a teacher) the signal needed to
encourage a healthier, more sustainable pace rather than optimizing for raw
repetition count.

`progress-tracking.md` already gestures at this need in broad terms ("Accuracy
Rates: Note-level precision tracking" as a Core Metric, `averageAccuracy`
and `exerciseAccuracy` in its speculative data model), and `exercise-system.md`
lists a 90% "Accuracy Threshold" under its aspirational Mastery Criteria. Both
of those documents describe a much larger analytics and mastery vision than is
in scope here. This spec is narrower and more concrete: it defines the single
missing input — a real, per-completion accuracy number derived from actual
note-matching behavior — that any of that broader future work would need to
consume.

## Goals

- **Surface a pacing signal**: Give the app a concrete, per-completion measure
  it can eventually use to nudge students toward sustainable difficulty and
  tempo choices, rather than only ever encouraging more repetitions.
- **Stay consistent with existing completion philosophy**: Accuracy must be
  captured *alongside* the existing low-friction completion criteria, not
  replace or gate it. Every exercise still "completes" the moment the student
  presses all correct notes, exactly as documented today in
  exercise-history.md — accuracy is recorded, never a completion gate.
- **Give real-time feedback accessibly**: Wrong notes are highlighted on the
  on-screen keyboard as they're played, using a red/blue pairing (not
  red/green) so the distinction doesn't rely on red-green color
  discrimination.
- **Fit the existing schema-extension pattern**: Reuse the typed-column,
  configuration-mirroring approach exercise-history.md already established,
  rather than introducing a new storage mechanism.
- **Work uniformly across all practice modes**: Because `PracticeSession`
  already evaluates every step (single note, chord, hands-together) through
  one exact pitch-set rule (see exercise-sequence.md), accuracy measurement
  should hook into that single rule rather than needing per-mode logic.
- **Keep the formula simple and revisitable**: Accuracy is a plain
  correct-vs-wrong ratio (see What "Accuracy" Should Mean), with no per-chord
  weighting. Raw counts are persisted alongside the computed percentage so
  the formula can be revised later without another migration.

## Requirements

### Functional Requirements

- Every MIDI note-on event that occurs while an exercise step is active must
  be classifiable as either **expected** (its pitch is a member of the
  current step's expected pitch set) or **unexpected** (it is not).
- While a note is held, the corresponding on-screen piano key must reflect
  that classification with a distinct fill color: blue for an expected/
  correct press, red for an unexpected/wrong press. This is real-time,
  per-key feedback — distinct from, and in addition to, the existing static
  target-note highlight shown before a key is pressed (see Technical
  Requirements). The color reverts once the key is released, same as any
  other momentary pressed-state visual.
- Each completed exercise must accumulate a count of expected and unexpected
  note-on events over the course of that single completion.
- Each completed exercise must produce exactly one accuracy value, matching
  the existing one-row-per-completion granularity documented in
  exercise-history.md ("Multiple completions of the same exercise produce
  separate rows — each is an independent event"). When auto key progression
  (see exercise-sequence.md / `PracticeSession.setAutoKeyProgression`) chains
  several key completions together, each completion still gets its own
  accuracy value, consistent with how each already gets its own history row.
- Accuracy measurement must **not** change what counts as "complete." The
  existing MVP completion criteria in exercise-history.md — play all notes in
  the sequence, regardless of accuracy — remain unchanged. Accuracy is an
  additional captured metric, not a new bar to clear.
- The accuracy value for a completed exercise must be available at the same
  point `PracticePageViewModel` currently builds and saves an
  `ExerciseHistoryEntry`, so it can be attached to that entry before it is
  persisted.
- Once persisted, the accuracy value must be displayed on `HistoryEntryCard`
  (practice-history-page.md) next to each attempt, consistent with that
  component's existing per-entry summary. Exact textual format (bare
  percentage vs. "18/20 notes correct") is a minor implementation detail,
  not decided here.
- The post-completion confirmation shown to the student must include the
  accuracy value for that attempt. Today this is the static "Exercise
  completed! Well done!" overlay in `practice_page.dart`'s
  `_completeExercise` (see Technical Requirements); it currently carries no
  dynamic data. This is separate from, and in addition to, the real-time
  per-key coloring above — one is a live cue during play, the other is the
  end-of-attempt summary.

### Technical Requirements

- Detection must hook into `PracticeSession`'s existing note-input handling
  rather than duplicating MIDI parsing elsewhere. The natural hook points
  (see Design Notes) are the same methods that already own note matching:
  `handleNotePressed`, `_checkStepCompletion`, and `_completeExercise`.
- `PracticeSession` currently has no notion of a "wrong note" event to build
  on — see Design Notes for why. New counting state and logic are required;
  nothing existing can simply be turned on.
- Real-time key coloring hooks into the same classification, but the paint
  layer is `PianoKeyVisual` (`piano_key_visual.dart`), not the superseded
  `KeyState`/`incorrectColor` sketch in visual-feedback-system.md — that
  sketch doesn't exist in code. `PianoKeyVisual` is deliberately
  state-blind (plain `fill`/`outline`/`dot`/`label`, per its own doc
  comment); today `practice_page.dart` only ever populates it for
  `highlightedNotes` (target/expected keys, filled `colorScheme.primary`,
  built before anything is pressed). Wiring correct/wrong coloring means
  additionally keying `PianoKeyVisual`'s map by *currently-held* notes once
  `handleNotePressed` classifies them, not just by the static target set.
- Persistence requires extending `ExerciseHistoryEntry` and the corresponding
  Drift table (exercise-history.md) with new column(s), which is a schema
  migration (see ADR-0024 for this project's Drift migration conventions).
  This spec does not attempt to specify migration mechanics.
- `PracticePageViewModel._recordExerciseHistory` already snapshots the
  exercise configuration synchronously (before the `unawaited` async history
  save) specifically to avoid reading stale session state once
  `PracticeSession` resets its counters for the next repetition. Any
  accuracy value threaded into the saved entry needs the same
  snapshot-before-async-boundary treatment, since `_completeExercise`
  resets `PracticeSession`'s internal state immediately after firing
  `onExerciseCompleted`.
- Counting must apply uniformly to every `PracticeMode`; it should not
  special-case scales vs. chords vs. arpeggios, mirroring the way
  `_checkStepCompletion` already treats every step through one pitch-set
  equality rule regardless of step size.
- The completion confirmation overlay (`practice_page.dart`'s
  `_completeExercise`, lines ~104–157) is shown synchronously and
  independently of the async `_recordExerciseHistory` save — it does not
  wait for persistence today and shouldn't start waiting for it just to show
  accuracy. Since accuracy is computed in `PracticeSession._completeExercise`
  before `onExerciseCompleted` fires (i.e., before the overlay is built), the
  value is available in time to interpolate into the overlay's text without
  changing that synchronous timing.

### Performance Requirements

- Per-note-event classification must be O(1) relative to the current step's
  note count (a set-membership check), adding negligible overhead to
  `handleNotePressed`/`handleNoteReleased`.
- Attaching an accuracy value to the saved history entry must not push
  exercise-history writes past the existing < 100ms budget documented in
  exercise-history.md.

## Accessibility

This spec's surface area includes both a new data field and new real-time
visual feedback on the practice keyboard:

- **Screen reader**: The persisted accuracy value should be folded into
  `HistoryEntryCard`'s existing combined `Semantics` label (see
  practice-history-page.md, which already composes mode, parameters, hand
  selection, and timestamp into one announcement per card) rather than added
  as a separate, unlabeled number. Exact wording (e.g., appending
  "92% accuracy") is left to the eventual UI-implementation spec. Real-time
  key coloring is a visual channel with no discrete screen-reader event
  planned here — a student relying on a screen reader isn't the target
  audience for a momentary key-color flash.
- **Color choice**: Correct/wrong key coloring uses blue (correct) and red
  (wrong), not the more conventional red/green, specifically because
  red-green is the most common form of color vision deficiency — this pairing
  is this spec's own accessibility requirement, not a documented convention
  carried over from `accessibility.md` (which doesn't currently state a
  color-contrast rule for this case).
- **Not color-only**: The persisted accuracy percentage is always shown as
  text (see Functional Requirements), independent of the real-time key
  color — a student who can't distinguish the live red/blue cue still gets
  the same accuracy information after the fact.
- **Touch targets**: Not applicable — key coloring changes the fill of
  existing piano keys; no new interactive controls are introduced.
- **Text scaling**: Any new percentage/count text must use plain `Text`
  widgets without fixed-height containers that would clip at large system
  font sizes, consistent with `HistoryEntryCard`'s existing layout.
- **Reduced motion**: The correct/wrong fill is a static color swap tied
  directly to press/release state, not an animation or flash — so it needs
  no separate reduced-motion handling. If a future pass adds a transition
  (e.g., a fade), it should honor the system's reduced-motion setting like
  any other animated UI in the app.

## Design Notes

### Why This Doesn't Exist Today

`PracticeSession.handleNotePressed` adds every incoming MIDI note to
`_currentlyHeldNotes` unconditionally, then calls `_checkStepCompletion`,
which advances the step only when `setEquals(_currentlyHeldNotes,
currentStep.expectedMidiNotes)` is true. If the student holds a wrong note —
alone, or alongside otherwise-correct notes — nothing happens: the step
simply doesn't advance until the mismatched note is released or corrected.
No counter increments, no callback fires, and no data survives past the next
`setEquals` check. This is intentional under the current self-paced,
untimed transport design (exercise-sequence.md): the transport waits
indefinitely for the right pitch set rather than working against a clock.

Two adjacent pieces of scaffolding already exist in the codebase but are not
wired to any real correctness data today:

- `PianoAccessibilityUtils.getPracticeContextDescription` accepts an
  `incorrectMidiNotes` parameter for building a semantic description, but no
  caller in the app currently passes it — the practice page's accessible
  piano wrapper only ever describes highlighted/target notes. This spec does
  not require wiring it up (see Accessibility — key coloring isn't paired
  with a screen-reader event), but once this spec's classification data
  exists, feeding it into this parameter would be a small follow-on, not a
  new investigation.
- `visual-feedback-system.md` sketches a `KeyState.incorrect` /
  `incorrectColor` concept, but that document explicitly marks the sketch as
  superseded by the current `PianoKeyVisual` model. This spec's real-time
  coloring requirement (see Technical Requirements) is built on
  `PianoKeyVisual` directly, not a revival of that superseded sketch.

Both are consistent with the same underlying gap this spec addresses: nothing
in the current codebase computes "was this note expected right now."
`exercise-history.md` itself already anticipates the gap, listing "Capture
tempo (BPM) and accuracy percentage" under its Phase 3 future work and
"Performance metrics: … accuracy percentage, error count" under its Future
Enhancements. This document is the detailed design for that previously-flagged
but undesigned gap.

### What "Accuracy" Should Mean

Accuracy is scoped to **note-pitch correctness** only. Timing/rhythm accuracy
is out of scope, not merely deferred: `PracticeSession` has no note-timing
data to measure against today, and every exercise is free-form and
self-paced by design (exercise-sequence.md) — there's no clock or expected
onset time to compare a press against. For a single completed exercise:

- **Correct note event**: an incoming MIDI note-on whose pitch is a member of
  the *current* step's expected pitch set (`PracticeStep.expectedMidiNotes`,
  exercise-sequence.md / `exercise.dart`) at the moment it is pressed.
- **Wrong (unexpected) note event**: an incoming MIDI note-on whose pitch is
  *not* a member of the current step's expected set at the moment it is
  pressed — this covers both a flatly wrong pitch and an extra note added on
  top of an otherwise-correct chord, since the current step-completion rule
  already treats both cases identically (neither can produce the required
  exact pitch-set match).
- **Missed notes**: not a well-defined concept under the current transport.
  Because `PracticeSession` is self-paced with no deadline, it waits
  indefinitely for the correct set rather than timing out — there is no
  natural moment at which a note becomes "missed" the way a rhythm game would
  detect it. exercise-sequence.md's "Future Semantics" section already defers
  duration, tempo, and timeout handling past V1; this spec follows that same
  boundary and does not attempt to define a missed-note concept without a
  timing model to hang it on.
- Each wrong note-on event counts as its own error, with no deduplication —
  even repeated presses of the same wrong pitch within one step each count
  individually. For example, if a step expects `C, E, G` and the student
  plays `C, D, D, E, G`, that step contributes 2 errors (two separate
  presses of `D`), not 1.

Accuracy for one completed exercise is a simple ratio of the accumulated
counts, expressed as a percentage:

```
accuracyPercentage = correctNoteCount / (correctNoteCount + errorCount) * 100
```

No per-chord weighting or partial credit — every note-on event counts
equally, whether it belongs to a single-note step or one note of a
five-note chord.

### Where Accuracy Would Be Measured (Hook Points)

The existing note-matching loop already visits every point this needs, so
measurement is a matter of adding classification and counting at points that
already exist, not building a new loop:

1. **`PracticeSession.handleNotePressed`** — the natural point to classify an
   incoming note against `currentStep.expectedMidiNotes` before it is added
   to `_currentlyHeldNotes`, since this is already where every note-on event
   arrives during an active exercise.
2. **`PracticeSession._checkStepCompletion`** — the natural point to finalize
   a step's own tally once that step actually completes (exact set match),
   since this is already the single place all step-size cases converge.
3. **`PracticeSession._completeExercise`** — the natural point to compute the
   exercise-level accuracy percentage from accumulated counts, since this
   already runs immediately before `onExerciseCompleted` fires and before
   counters reset for the next repetition.
4. **`PracticePageViewModel`'s `onExerciseCompleted` callback /
   `_recordExerciseHistory`** — the natural point to thread the computed
   accuracy value into the `ExerciseHistoryEntry` being built, alongside the
   existing synchronous `config` snapshot (see Technical Requirements above).
5. **`practice_page.dart`'s `keyVisuals` builder** — the natural point to
   turn the same per-note classification from (1) into a `PianoKeyVisual`
   fill color for currently-held notes, alongside the existing target-note
   `keyVisuals` entries it already builds from `highlightedNotes` (see
   Technical Requirements).

### Where Accuracy Would Be Persisted

Accuracy would extend `ExerciseHistoryEntry` and `ExerciseHistoryTable`
(exercise-history.md), following the same typed-column, no-JSON-blob pattern
ADR-0028 already established for that schema. Both the computed percentage
and the raw counts it's derived from are persisted side by side, so the
formula above can be recomputed from raw data if it's ever revised, without
another migration:

| Field (proposed)     | Type      | Nullable | Notes                                                                                                                                        |
| -------------------- | --------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `accuracyPercentage` | `double?` | Yes      | Top-line metric, 0–100. Nullable so existing rows and any future non-scored modes remain valid without backfilling.                          |
| `correctNoteCount`   | `int?`    | Yes      | Optional raw counter; keeping raw counts alongside the percentage would let a future formula change be recomputed without another migration. |
| `errorCount`         | `int?`    | Yes      | Optional raw counter for unexpected note-on events, same rationale as above.                                                                 |

This is additive to the existing schema — no existing column changes — and
follows exercise-history.md's own stated extensibility requirement ("Adding
new metrics or configuration fields requires a schema migration; each new
field maps to a new typed column"). No session-level aggregation is needed at
this stage — only the per-attempt raw log described above; rollups are
deferred (see Future Enhancements). Once persisted, `practice-history-page.md`'s
`HistoryEntryCard` displays the value next to each attempt, consistent with
that component's existing per-entry summary layout; the exact textual format
remains a minor implementation detail.

## Integration Points

- **exercise-sequence.md**: Owns the `PracticeSession` / `PracticeStep` /
  `PracticeNote` note-matching loop this feature hooks into. Accuracy
  measurement must respect that model's exact-pitch-set-equality rule and its
  explicit V1 boundary excluding timing/duration/tempo.
- **exercise-history.md**: Owns the `ExerciseHistoryEntry` domain model and
  `ExerciseHistoryTable` schema this feature would extend with new column(s).
  Also documents the existing "play all notes, regardless of accuracy"
  completion criteria that this spec deliberately leaves unchanged.
- **practice-history-page.md**: Owns `HistoryEntryCard`, the natural UI
  surface for displaying a persisted accuracy value, and its existing
  Semantics-label-per-card accessibility pattern.
- **progress-tracking.md**: Describes a much broader, largely aspirational
  analytics vision that already assumes an accuracy signal exists (e.g.,
  `averageAccuracy`, `exerciseAccuracy`). This spec is the concrete,
  near-term design for the single real input that vision would need.
- **exercise-system.md**: Its "Mastery Criteria" section already names a 90%
  "Accuracy Threshold" as an aspirational concept; this spec supplies the
  measurement this threshold would eventually be evaluated against, without
  committing to using it for mastery gating now.
- **visual-feedback-system.md**: Sketches a dormant `KeyState.incorrect` /
  `incorrectColor` concept for real-time wrong-key visual feedback, explicitly
  marked superseded. This spec's real-time coloring requirement supersedes
  that sketch too — it's built on `PianoKeyVisual` directly (see Design
  Notes), not a revival of the `KeyState` enum.

## Decisions Log

Everything that was originally open in this spec has since been settled:
scoring formula (simple ratio), timing scope (out, permanently, not just
deferred — the app has no note-timing data and exercises are free-form),
duplicate-press counting (each counts individually), note-on-only scope,
persisted shape (raw counts + computed percentage), session-aggregation
(deferred to Future Enhancements), UI placement (next to each attempt, bare
percentage), completion gating (accuracy is recorded, never gates
completion), and real-time feedback (in scope — red/blue key coloring, see
Requirements and Accessibility). No open questions remain.

## Future Enhancements

- **Accuracy-aware mastery/adaptive difficulty**: Use accumulated accuracy
  trends to power the "Automatic Advancement" / "Remedial Practice" concepts
  already sketched in exercise-system.md's Exercise Progression section, or
  to gently suggest a slower tempo or an easier variation when accuracy is
  persistently low — directly serving this spec's core pedagogical
  rationale.
- **Session-level rollups**: Once exercise-history.md's speculative
  `sessionId` grouping exists, aggregate per-completion accuracy into a
  session-level figure.
- **Timing/rhythm accuracy**: Extend accuracy to include timing precision
  once (if) `PracticeSession` grows a clocked/timed transport mode, per
  exercise-sequence.md's "Future Semantics."
- **Historical trend surfacing**: Feed persisted accuracy values into the
  broader analytics vision in progress-tracking.md (accuracy trend lines,
  plateau detection, etc.) once enough history data exists.
