<!--
  Status: Draft
  Created: 2026-07-19
  Last updated: 2026-07-19
-->

# Exercise Sequence Specification

## Overview

`PracticeExercise` is the immutable musical material consumed by the practice
transport. It is analogous to a MIDI clip in a DAW: the exercise contains the
ordered score, while `PracticeSession` owns the playhead, held-note state, and
advancement behavior.

The existing model names already fit this purpose:

```text
PracticeExercise
└── ordered PracticeStep values
    └── simultaneous PracticeNote targets
```

```text
PracticeExercise = (S1, S2, …, Sk)
Si               = {n1, n2, …, nr}
n                = (pitch, hand, finger?, annotations)
```

Order belongs to `PracticeExercise`. Simultaneity belongs to `PracticeStep`.
Pitch and note-level guidance belong together in `PracticeNote`.

This is a focused internal refactor, not a replacement exercise system.
`PracticeExercise`, `PracticeStep`, `PracticeStrategy`, and `PracticeSession`
remain in their current architectural roles. The principal model change is that
a step owns complete note-target values instead of storing pitch, hand, and
finger in parallel structures.

## Goals

- **Consolidated model**: Keep pitch, intended hand, optional finger, and
  note-level annotations in one immutable value object.
- **Sequencer behavior**: Treat an exercise as ordered onset steps and each step
  as the notes intended to begin together.
- **Broad pedagogy**: Support single hand, hands together, independent hands,
  single tones, blocked sonorities, broken textures, and permutations without
  family-specific runtime models.
- **Small delta**: Retain the existing top-level models, generator interface,
  transport, and step metadata that already work.
- **One runtime representation**: Do not zip parallel pitch, hand, or finger
  arrays in evaluation or presentation.

## Domain Model

### PracticeNote

`PracticeNote` is an immutable note-target value object. It owns:

- a validated `MidiNote` pitch;
- exactly one intended hand, left or right;
- an optional finger number from 1 through 5; and
- optional note-level annotations such as enharmonic spelling, scale degree,
  harmonic role, help text, or structural identity.

The intended hand uses a two-valued note-hand type. `HandSelection.both` remains
useful when configuring an exercise, but it is not a valid hand for one note
target.

`PracticeNote` equality includes its target and guidance. Evaluation compares
only MIDI pitches because ordinary MIDI input cannot report a physical hand or
finger.

### PracticeStep

`PracticeStep` is one ordered onset moment. Its `notes` collection contains
complete `PracticeNote` values intended to begin together.

- A runnable step contains at least one note.
- Notes are stored in deterministic order for serialization and display, but
  their order has no performance meaning within the step.
- The notes are semantically a set.
- A MIDI pitch may occur only once in a step. Standard MIDI input cannot
  distinguish two same-pitch targets assigned to different hands.
- A hand may not assign one finger to two notes in the same step.
- Expected MIDI pitches are derived directly from `PracticeStep.notes`.
- Step-level data such as chord label, harmonic function, instruction, or
  display name remains in the existing step metadata; it is not duplicated on
  every note.
- Note-level `hand` and `fingers` metadata is removed after those values move
  into `PracticeNote`.

`StepType` is removed. A step is simultaneous by definition, so the type does
not add information:

- sequential material is represented by multiple ordered singleton steps;
- hands-together material is represented by one step containing both hands'
  notes; and
- a blocked chord is represented by one step containing all chord notes.

All steps therefore use the same expected-pitch-set evaluation rule.

### PracticeExercise

`PracticeExercise` remains the top-level immutable sequence. It owns:

- an ordered collection of `PracticeStep` values; and
- exercise-level metadata such as exercise family, key, mode, difficulty, or
  display description.

Its existing operations remain conceptually valid:

- step access by playhead position;
- `length`, `isEmpty`, and `isNotEmpty`;
- collecting all pitches for keyboard range calculation;
- copying, equality, and deterministic JSON serialization.

Those operations are updated to traverse `PracticeNote.pitch` rather than raw
integer note lists. No `PracticeSequence` wrapper or replacement type is added.

## Transport Behavior

`PracticeSession` remains the transport controller. It owns the current step
index, active/complete state, and currently held MIDI pitches. The immutable
`PracticeExercise` does not own mutable playhead state.

- Guidance highlights every `PracticeNote.pitch` in the current step.
- Self-paced evaluation compares currently held MIDI pitches with the current
  step's expected pitch set.
- A step completes only when the pitch sets are equal; unexpected held pitches
  prevent advancement.
- The playhead advances by one step and never interprets note ordering within a
  step.
- Transport logic does not branch on whether an exercise originated as a scale,
  chord, cadence, arpeggio, or authored drill.
- Hand and finger remain guidance only; they are not evaluated from MIDI input.

The MIDI/DAW analogy is structural rather than clock-based in V1. Steps advance
through successful self-paced input, not elapsed time. Duration, tempo, release,
and pedal can be added later without changing the ordered-step hierarchy.

## Unified Pedagogical Representations

| Exercise family | `PracticeExercise` representation |
| --- | --- |
| Single-hand scale | Singleton steps whose notes all name the selected hand. |
| Hands-together scale | Each step contains left- and right-hand notes. |
| Blocked chord | One step contains all chord notes. |
| Broken chord or arpeggio | Chord notes occur in successive singleton steps. |
| Arpeggio plus bass | Some steps contain bass and right-hand notes; intervening steps contain right-hand notes only. |
| Mixed accompaniment | Blocked and singleton steps occur in one exercise. |
| Voiced chord progression | Each chord is a step of individually guided notes. |
| Independent hands | Each step contains whichever hand has an onset; neither hand must occur in every step. |
| Repeated technical drill | Repetition is repeated subsequences with distinct structural occurrence IDs when persistence requires them. |

A right-hand scale fragment is:

```text
(
  { (60, right, 1) },
  { (62, right, 2) },
  { (64, right, 3) },
  { (65, right, 1) }
)
```

A hands-together scale fragment is:

```text
(
  { (48, left, 5), (60, right, 1) },
  { (50, left, 4), (62, right, 2) },
  { (52, left, 3), (64, right, 3) }
)
```

An arpeggio with unequal hand density is:

```text
(
  { (36, left, 5), (48, left, 1), (60, right, 1) },
  { (64, right, 2) },
  { (67, right, 3) },
  { (72, right, 5) },
  { (43, left, 5), (55, left, 1), (67, right, 3) },
  { (64, right, 2) },
  { (60, right, 1) }
)
```

No blocked-chord, arpeggio, hands-together, or independent-hands runtime subtype
is necessary. Those distinctions belong to generation and presentation.

## Ordering and Permutations

There is no performance permutation inside one blocked step. All of its notes
begin together:

```text
{ (60, right, 1), (64, right, 3), (67, right, 5) }
```

To arpeggiate the same material, a generator emits ordered singleton steps:

```text
root–third–fifth             fifth–third–root

{ (60, right, 1) }        { (67, right, 5) }
{ (64, right, 3) }        { (64, right, 3) }
{ (67, right, 5) }        { (60, right, 1) }
```

If a generator recalculates fingering for a permutation, it preserves the
pitch-hand content but produces new guided `PracticeNote` values. Fingering is
part of target guidance, not MIDI evaluation.

## Generators and Combinators

Existing music-theory services and `PracticeStrategy` implementations remain
the family-specific generators. `PracticeStrategy.initializeExercise()` still
returns `PracticeExercise`; the returned steps now contain complete notes.

The generation space includes independent choices along these axes:

| Axis | Supported forms |
| --- | --- |
| Hand allocation | Left, right, hands together, alternating, and independent hands with unequal onset density. |
| Texture | Single tone, interval, blocked multi-tone group, broken group, and mixtures within one exercise. |
| Sequence shape | Ascending, descending, mirrored, repeated, concatenated, transposed, and selected permutations. |
| Coordination | Parallel motion, contrary motion, one-hand-only steps, and explicitly merged onsets. |
| Guidance | Finger, spelling, harmonic role, structural ID, and help annotations attached to the appropriate object. |

Reusable pure operations may:

- convert a note collection into singleton steps in a chosen order;
- keep a note collection together as one blocked step;
- concatenate, repeat, reverse, transpose, or select permutations;
- merge explicitly aligned left- and right-hand onsets while retaining unpaired
  onsets from either hand;
- assign or recalculate hands, fingers, spelling, and structural identity; and
- validate the resulting `PracticeExercise`.

Operations return new immutable values and preserve guidance and identity unless
their contract explicitly recalculates them. Combinatoric generation must be
bounded by pedagogical intent: callers select a particular order, constrained
family, sample, or maximum count rather than materializing every factorial
permutation.

This does not require an upfront exercise DSL. A reusable operation should be
extracted when an existing strategy and another concrete exercise need the same
transformation.

## Alignment With the Current Codebase

The current implementation already supplies most required behavior:

- `PracticeExercise` already owns ordered `PracticeStep` values.
- All `PracticeStrategy` implementations already return that common model.
- Scale and arpeggio strategies already emit singleton or two-note
  hands-together onset steps.
- Chord and progression strategies already emit blocked onset steps.
- `PracticeSession` already owns the playhead and tracks held pitches as a set.
- The UI already highlights the current step and displays fingering.

The delta is deliberately narrow:

| Existing area | Focused change |
| --- | --- |
| `PracticeExercise` and its role | Update traversal and JSON for complete notes. |
| `PracticeStep` and its role | Change `notes` from raw MIDI integers to `PracticeNote` values. |
| `PracticeStrategy.initializeExercise()` | Construct complete notes directly. |
| `PracticeSession` as transport | Evaluate every step through exact pitch-set equality. |
| `StepType` | Remove the enum, field, constructor argument, JSON value, and evaluation branches. |
| Exercise- and step-level metadata | Remove only note-level hand/finger entries. |

No `PracticeSequence`, parallel `hands` array, compatibility adapter, or second
persisted object graph is introduced.

## Implementation Plan

### Phase 1 — Lock Existing Musical Output

**Goal**: Preserve musical behavior while changing the internal note shape.

- Add focused tests for every existing strategy's pitches, hands, fingers, and
  step order.
- Add invariant tests for MIDI range, finger range, non-empty steps, and unique
  in-step pitches.

### Phase 2 — Consolidate PracticeStep Notes

**Goal**: Establish the cohesive note-target model.

- Add `PracticeNote` and the two-valued note-hand type in the domain layer.
- Change `PracticeStep.notes` to contain complete `PracticeNote` values.
- Move hand and finger guidance out of raw metadata.
- Remove `StepType` from the domain model and serialized step shape.
- Update `PracticeStep` and `PracticeExercise` equality, copying, pitch access,
  range collection, and JSON.
- Keep `PracticeExercise`, `PracticeStep`, and
  `PracticeStrategy.initializeExercise()` otherwise intact.

### Phase 3 — Update Existing Generators

**Goal**: Preserve every existing exercise using the consolidated model.

- Update scales, arpeggios, chords, progressions, and cadences to construct
  `PracticeNote` directly.
- Preserve current step order, pitches, hand assignments, fingering, labels,
  harmonic descriptions, and exercise metadata.
- Delete generation of note-level hand and finger metadata.

### Phase 4 — Update Transport and Presentation

**Goal**: Consume complete notes without runtime reconstruction.

- Update `PracticeSession` to derive exact pitch sets from current-step notes.
- Replace the three type-based evaluation branches with one pitch-set
  completion rule.
- Update highlighting, range calculation, fingering, and accessibility code to
  read `PracticeNote` directly.
- Derive pitch-only integer collections only at MIDI or keyboard API boundaries.

### Phase 5 — Expand the Generator Space

**Goal**: Add richer pedagogy without further transport changes.

- Add mixed accompaniment, arpeggio-plus-bass, hands-independent, and bounded
  permutation generators.
- Extract shared pure combinators only after concrete reuse appears.
- Verify each new generator with the common exercise and transport invariants.

## Exercise History

A future exact-attempt record should store the resolved, versioned
`PracticeExercise` used by the transport. Regenerating it from
`ExerciseConfiguration` is insufficient because voicings, fingering,
permutations, and generator behavior may change.

Current `ExerciseHistoryEntry` stores only `ExerciseConfiguration`, so this
internal refactor does not require a database migration. Exact exercise
snapshots are a separate future history enhancement.

## Testing Requirements

### Domain Tests

- Validate note pitch, hand, finger, equality, and JSON.
- Validate non-empty steps, unique in-step pitches, deterministic serialization,
  immutability, and structural identity.
- Verify every existing strategy preserves its current musical output.

### Application Tests

- Verify exact pitch-set equality for singleton and multi-note steps.
- Verify unexpected held pitches prevent advancement for singleton,
  hands-together, and chord-sized steps.
- Verify guidance and evaluation never read hand or finger from raw metadata.
- Verify exercise completion and reset behavior remain unchanged.

### Widget Tests

- Verify every current-step pitch is highlighted.
- Verify each displayed pitch receives hand, finger, spelling, and accessible
  guidance from its `PracticeNote`.
- Verify mixed and unequal-density hand patterns render without positional
  metadata reconstruction.

## Acceptance Criteria

- [ ] `PracticeExercise` remains the canonical immutable exercise consumed by
  `PracticeSession`.
- [ ] `PracticeStep.notes` contains complete `PracticeNote` values.
- [ ] No runtime consumer zips pitch, hand, or finger arrays from metadata.
- [ ] `PracticeStrategy.initializeExercise()` continues returning
  `PracticeExercise`.
- [ ] `StepType` and its type-based evaluation branches are removed.
- [ ] Every step uses one exact pitch-set evaluation rule.
- [ ] Existing exercises preserve their step order, pitches, hands, fingers,
  labels, and configuration metadata.
- [ ] New generators can express single-hand, hands-together,
  hands-independent, single-tone, multi-tone, mixed-texture, and bounded
  permutation exercises without transport changes.

## Future: Custom Tone-Pattern Authoring

`lib/domain/services/music_theory/tone_pattern.dart` implements a Phase 5
generator: a chord-tone-degree pattern engine shared by the Arpeggios
(broken texture) and Block Chords (blocked texture) strategies. A pattern is
a list of tokens; each token is a bare 1-based chord-tone degree (a
singleton onset) or a parenthesized group of degrees (a blocked onset).
Degrees wrap across octaves via `(degree - 1) % n` / `(degree - 1) ~/ n`
(`n` = the chord's tone count) — the same numbering convention as the
Nashville number system, extended past the chord size to reach higher
octaves. `TonePattern.parse` also accepts this as a compact string, e.g.
`"1,2,3,2,3,4"` or `"1,(2,3),4,2,(3,4),5"`, with:

- per-degree hand suffixes `L`/`R` (e.g. `"(1L,1),2,3"`) for hand-tagged
  patterns like a sparse left-hand root tap merged into a right-hand run;
- ABC-notation-style apostrophe octave marks (e.g. `"1,2,3,1'"`), so every
  bare digit stays in the readable `1..n` range instead of growing without
  bound as the pattern climbs octaves.

Only two generated presets (`ChordTonePattern.straight`, `.rolling`) are
currently wired into `ExerciseConfiguration` and the settings UI. `parse` is
fully implemented and tested but has no caller yet — no `custom` pattern
value exists on `ChordTonePattern`, and no `customPattern` string field
exists on `ExerciseConfiguration`.

A future custom-pattern mode is a small, additive change, since everything
downstream of token generation (mirroring, the left-hand-root-tap and
both-hands transforms, hand resolution, fingering, `toPracticeSteps`)
already operates on `List<PatternToken>` regardless of where the tokens came
from:

- add `ChordTonePattern.custom`;
- add `String? customPattern` to `ExerciseConfiguration`, required when
  `pattern == custom`;
- in `ArpeggiosStrategy`/`BlockChordsStrategy`, branch to
  `TonePattern.parse(customPattern!, n: n)` instead of the canonical
  generator when `pattern == custom`;
- add a settings-panel text field for entering the pattern string, with
  parse-error surfacing.

This would let a user (or another contributor) author "impressionistic"
practice patterns that don't fit the straight/rolling presets — e.g. mixed
broken-and-blocked motives like `"1,(2,3),4,2,(3,4),5"` — without any
further engine changes.

A separate, unrelated idea raised alongside this: exporting a resolved
pattern to ABC notation (or MusicXML) for sharing/printing via existing
notation tooling. That's a plain **export** format, not an authoring format
— ABC is pitch/key-absolute and has no natural slot for finger numbers,
whereas this DSL is deliberately degree-relative (transposable to any root
for free) and hand/finger-aware. If pursued, it belongs as a one-way
resolved-pattern-to-ABC converter, layered on top of `toPracticeSteps`'
output, not a change to the DSL itself.

## Future Semantics

Duration, release, pedal, velocity, tempo, meter, accepted alternatives,
bounded improvisation, and polyrhythm are outside V1. Future support must extend
the exercise, step, or note contracts explicitly while preserving the hierarchy
of ordered steps containing simultaneous note targets.
