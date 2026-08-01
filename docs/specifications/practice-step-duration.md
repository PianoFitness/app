# PracticeStep Duration Addendum (MVP)

**Suggested repository path:** `docs/specifications/practice-step-duration.md`
**Status:** Proposed
**Depends on:** `exercise-tempo-calculation.md`
**Informs:** `skill-progression.md`

## Decision

Add one shared notated duration (`noteValue`) to every `PracticeStep`.

`PracticeStep` already represents one musical onset: one note for a scale or arpeggio, or several simultaneous notes for a chord. The new value describes the rhythmic distance from that onset to the next step. It belongs on the step, not on individual notes.

For the MVP, duration is descriptive. It informs tempo interpretation only; it does **not** require notes to be held, evaluate note-off events, or grade articulation.

## Rationale

The existing exercise model can continue to generate the same ordered onset steps. The duration makes the recorded tempo musically meaningful without creating a second exercise system.

For example, a chord progression may use whole-note steps while an arpeggio uses quarter-note steps. Both can therefore report a conventional quarter-note BPM, even though their raw onset intervals differ.

Putting a duration on each `PracticeNote` would imply independently sustained notes within a single chord. The current runner has no such polyphonic duration model, so that is deliberately out of scope.

## Model and API changes

Add a small domain enum and conversion helper near the practice models:

```dart
enum PracticeStepNoteValue {
  whole,
  half,
  quarter,
  eighth,
  sixteenth,
}

extension PracticeStepNoteValueX on PracticeStepNoteValue {
  double get quarterNoteBeats => switch (this) {
    PracticeStepNoteValue.whole => 4.0,
    PracticeStepNoteValue.half => 2.0,
    PracticeStepNoteValue.quarter => 1.0,
    PracticeStepNoteValue.eighth => 0.5,
    PracticeStepNoteValue.sixteenth => 0.25,
  };
}
```

Extend `PracticeStep` with a non-null field and a quarter-note default:

```dart
class PracticeStep {
  PracticeStep({
    required this.notes,
    this.noteValue = PracticeStepNoteValue.quarter,
    this.metadata,
  });

  final List<PracticeNote> notes;
  final PracticeStepNoteValue noteValue;
  final Map<String, dynamic>? metadata;
}
```

Update the model's equality, `copyWith`, JSON conversion, and test fixtures accordingly. Existing strategy code may remain unchanged because it receives the quarter-note default. Strategies for chord-progressions should explicitly emit `noteValue: PracticeStepNoteValue.whole` where the intended rhythm is one chord per whole note. Other values are opt-in per exercise definition.

## JSON and backward compatibility

New JSON should write an explicit value:

```json
{
  "notes": [],
  "noteValue": "whole"
}
```

`PracticeStep.fromJson` must treat a missing `noteValue` as `quarter`. This preserves all existing exercise data and any serialized history/configuration that embeds steps. No data migration or history backfill is required.

Unknown non-null values should be rejected as invalid exercise data rather than silently interpreted. New serializations should always include `noteValue`, including `"quarter"`, so their rhythm is self-describing.

## Tempo integration

Tempo recording continues to timestamp the first expected note-on of each completed `PracticeStep`. A chord produces one onset, regardless of how many notes it contains.

For a tempo-measurable MVP exercise, all steps must use the same `noteValue`. Convert the mean inter-onset interval to conventional quarter-note BPM as follows:

```text
quarter-note BPM =
  60 × noteValue.quarterNoteBeats
  ÷ meanInterOnsetSeconds
```

Examples:

- Quarter-note steps, 500 ms apart: 120 BPM.
- Whole-note chord steps, 2,000 ms apart: 120 BPM.
- Eighth-note steps, 250 ms apart: 120 BPM.

The final step's `noteValue` remains meaningful musical metadata, although it has no following onset interval in that repetition.

The tempo result should persist the uniform `noteValue` used for conversion (for example, `tempoStepNoteValue`) with the existing tempo statistics and measurement version. The BPM is reported only when the tempo-calculation specification considers the attempt reliable.

## MVP validation and limits

`PracticeExercise` should expose a helper such as `uniformTempoNoteValue` that returns the value only when every step uses the same note value.

Tempo measurement must be marked `unavailable` when:

- the exercise has no steps;
- the exercise contains mixed `noteValue` values; or
- another existing tempo-quality gate fails.

Mixed-duration exercises are valid future exercise content, but version 1 must not guess their BPM or partially average them. They remain playable and can retain pitch-accuracy history; they simply provide no tempo evidence until a duration-aware interval model is specified.

The MVP does not support dotted values, triplets, ties, rests, swing, per-note durations, or note-off/hold-length grading.

## Tests

Add focused tests for:

1. `PracticeStep` defaults to `quarter`.
2. JSON without `noteValue` deserializes to `quarter`.
3. JSON round-trips every supported value and newly serialized steps include it.
4. Conversion helpers return 4, 2, 1, 0.5, and 0.25 quarter-note beats.
5. Existing generators retain quarter-note steps without source changes.
6. A chord-progression generator can deliberately emit whole-note steps.
7. Tempo conversion reports the same 120 BPM for the three examples above.
8. Mixed-note-value exercises return no tempo BPM and the `unavailable` quality; they do not fail exercise completion.
9. Duration does not alter existing pitch-completion, repetition, or note-release behaviour.

## Acceptance criteria

- Existing exercises, JSON, and persisted data remain readable and behave as quarter-note exercises by default.
- New exercises can declare one shared duration per `PracticeStep`.
- Chord progressions can declare whole-note steps without a new practice mode or runner.
- Reliable tempo is conventional quarter-note BPM, converted using the declared uniform step value.
- The MVP never grades how long a note or chord is held.
- Mixed-duration exercises remain playable but contribute no tempo evidence.
- No parallel exercise representation, runner, or migration is introduced.

## Incremental implementation

1. Add `PracticeStepNoteValue`, the `PracticeStep.noteValue` default, serialization support, and model tests.
2. Add `PracticeExercise.uniformTempoNoteValue` and make the tempo tracker consume it for BPM conversion; persist the value with tempo results.
3. Mark mixed-duration exercises as tempo `unavailable` and cover the behaviour with tests.
4. Update intended chord-progression exercise definitions to explicitly use `whole`; leave all other generators unchanged until their rhythm is intentionally defined.

This keeps the change small: the existing `PracticeExercise`/`PracticeStep` pipeline remains the execution engine, while rhythm metadata provides the interpretation needed for tempo recording and later skill proficiency.
