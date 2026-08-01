# Exercise Tempo Calculation Specification

**Status:** Draft  
**Proposed file:** `docs/specifications/exercise-tempo-calculation.md`  
**Scope:** Minimum viable measurement of exercise tempo from MIDI note onsets  
**Depends on:** Existing MIDI input, `PracticeStep`, `PracticeRunner`, exercise completion, and exercise history paths  
**Used by:** Exercise history, future skill-progression proficiency, and later tempo recommendations  

## 1. Purpose

PianoFitness shall record the tempo at which a learner completes a MIDI practice exercise.

The measurement must:

- Work whether or not the metronome is enabled.
- Use the learner’s performed note onsets rather than the configured metronome BPM.
- Reuse the existing `PracticeStep`, `PracticeRunner`, completion, and history paths.
- Avoid presenting an exact BPM when the available timing evidence is too short or inconsistent.
- Remain conservative when Flutter or MIDI transport timing may have introduced jitter.
- Store enough statistical evidence with the history entry to support future proficiency calculations.

This is a minimum viable specification. It intentionally avoids notated rhythm, mixed note values, beat alignment, metronome comparison, and advanced outlier modelling.

## 2. Core decision

For version 1:

> One completed `PracticeStep` onset equals one exercise beat.

The resulting value is an **exercise tempo** measured in step beats per minute.

Examples:

- A scale with one note per `PracticeStep` measures note onsets per minute.
- An arpeggio with one note per `PracticeStep` measures arpeggio-note onsets per minute.
- A block-chord exercise with one chord per `PracticeStep` measures chord onsets per minute.
- A progression with one chord per `PracticeStep` measures chord onsets per minute.

This avoids prematurely deciding whether a generated exercise should be interpreted as quarter notes, eighth notes, or another notated value.

The tempo is meaningful for:

- Comparing repetitions of the same exercise.
- Establishing a learner’s demonstrated baseline.
- Tracking improvement over time.
- Recommending a slightly faster future tempo.

It is not necessarily comparable across unrelated exercise types.

A future specification may add an explicit `stepsPerBeat` or rhythmic profile without changing the timestamp or inter-onset data model.

## 3. Goals

The system must:

1. Assign each incoming external MIDI packet an application-owned monotonic receive timestamp.
2. Record one onset timestamp for each `PracticeStep`.
3. Calculate inter-onset intervals after a completed exercise.
4. Calculate mean interval, standard deviation, coefficient of variation, and exercise BPM.
5. Classify each measurement as reliable, insufficient, inconsistent, or unavailable.
6. Persist the tempo result and its supporting statistics with the existing exercise-history entry.
7. Display and use BPM only when the measurement is reliable.
8. Operate independently of the metronome.
9. Preserve the existing practice repetition and history workflow.
10. Add no periodic timer or alternate practice runner.

## 4. Non-goals

Version 1 will not:

- Schedule metronome sounds.
- Use `Timer.periodic`, an isolate timer, or `reliable_interval_timer`.
- Infer whole, half, quarter, eighth, triplet, or sixteenth-note values.
- Compare note onsets with metronome clicks.
- Calculate early or late timing against a beat grid.
- Measure note duration.
- Measure articulation.
- Measure chord-note synchronisation.
- Remove statistical outliers.
- Pool intervals across multiple history entries.
- Qualify on-screen virtual-piano input for tempo progression.
- Use the `flutter_midi_command` transport timestamp as the canonical clock.
- Store every raw onset timestamp in the database.
- Change the current pitch-accuracy calculation.

## 5. Existing architecture

The feature extends the existing path:

```text
flutter_midi_command MidiPacket
    ↓
MidiConnectionService
    ↓
IMidiRepository / MidiCoordinator
    ↓
MidiEvent
    ↓
PracticePageViewModel
    ↓
PracticeSession
    ↓
PracticeRunner
    ↓
ExerciseCompletionResult
    ↓
ExerciseHistoryEntry
```

The existing `PracticeRunner` remains responsible for:

- Starting practice on the first note.
- Processing expected and unexpected notes.
- Advancing through ordered steps.
- Completing the exercise.
- Resetting for another repetition through `PracticeSession`.

Tempo measurement is additional state inside this same execution path.

## 6. Timestamp source

### 6.1 Canonical clock

PianoFitness shall use an application-owned monotonic `Stopwatch`.

The clock shall be started by `MidiConnectionService` and sampled immediately when a `MidiPacket` callback begins.

```dart
class MidiConnectionService {
  final Stopwatch _inputClock = Stopwatch()..start();

  void _handlePacket(MidiPacket packet) {
    final receivedAt = _inputClock.elapsed;

    final inputPacket = MidiInputPacket(
      data: packet.data,
      receivedAt: receivedAt,
      transportTimestamp: packet.timestamp,
    );

    _dispatch(inputPacket);
  }
}
```

The timestamp must be captured before:

- Logging.
- MIDI parsing.
- Updating `MidiState`.
- Calling application handlers.
- Calling `notifyListeners()`.
- Running exercise logic.

### 6.2 Why no interval timer is used

Tempo recording is passive event measurement.

It does not need to generate recurring ticks. A periodic timer would add scheduling work without providing information about when a MIDI event occurred.

The feature reuses the metronome’s principle of a monotonic clock, but not its scheduling mechanism.

### 6.3 Transport timestamp

`flutter_midi_command` supplies an integer packet timestamp. Version 1 may preserve it for diagnostics:

```dart
@immutable
class MidiInputPacket {
  const MidiInputPacket({
    required this.data,
    required this.receivedAt,
    this.transportTimestamp,
  });

  final Uint8List data;
  final Duration receivedAt;
  final int? transportTimestamp;
}
```

Version 1 must not assume that the transport timestamp has consistent units or epoch semantics across platforms and transports.

It must not be used in the user-facing BPM calculation until validated and normalised by a separate specification.

### 6.4 Known limitation

The application receive clock measures when Dart begins handling the packet, not necessarily when the native MIDI system first received it.

A blocked Dart isolate may delay packet delivery and distort an interval.

This risk is addressed by:

- Timestamping at the earliest Dart boundary.
- Keeping MIDI callback work small.
- Applying conservative statistical reliability gates.
- Withholding exact BPM when the evidence fails.
- Requiring real-device validation under UI load before release.

## 7. MIDI packet propagation

Change the internal MIDI handler contract from raw bytes to a timestamped packet.

```dart
typedef MidiInputHandler = void Function(MidiInputPacket packet);
```

Update:

- `MidiConnectionService`
- `IMidiRepository`
- `MidiRepositoryImpl`
- `MidiCoordinator`
- `MidiDataHandler`
- Test mocks

The parsed domain event shall preserve the application timestamp:

```dart
@immutable
class MidiEvent {
  const MidiEvent({
    required this.status,
    required this.channel,
    required this.data1,
    required this.data2,
    required this.type,
    required this.occurredAt,
  });

  final Duration occurredAt;
}
```

The transport timestamp does not need to propagate beyond the MIDI adapter in version 1 unless retained for diagnostic logging or tests.

## 8. Supported input

### 8.1 External MIDI

Tempo measurement is supported for external MIDI note-on events carrying the application receive timestamp.

### 8.2 Virtual piano

The on-screen virtual piano currently invokes exercise logic through Flutter UI callbacks rather than the external MIDI packet path.

Version 1 shall allow virtual-piano practice to continue normally, but its completed exercises shall produce:

```text
tempo quality: unavailable
```

Virtual-piano attempts must not contribute tempo evidence to skill progression.

A later version may define a separate validated timestamp source for virtual-piano input.

### 8.3 Mixed input

If one exercise repetition contains both external MIDI and virtual-piano note-on events, its tempo measurement shall be unavailable.

Pitch accuracy and ordinary exercise completion remain unaffected.

## 9. Onset definition

`PracticeStep` already represents one onset moment in which all contained notes are intended to begin together.

Version 1 shall record one timestamp per step.

### 9.1 Recorded moment

The onset timestamp for a step is:

> The timestamp of the first expected external MIDI note-on received for the current `PracticeStep`.

### 9.2 Chords

For a chord step, the first expected chord tone records the step onset.

The remaining expected chord tones:

- Complete the existing pitch-set requirement.
- Do not create additional step onsets.
- Do not change the recorded onset.

Chord spread is outside version 1.

### 9.3 Wrong notes

An unexpected note-on:

- Continues to affect pitch accuracy.
- Does not create a tempo onset.
- Does not replace the current step’s onset.

### 9.4 Repeated notes within a step

After a step onset has been recorded, repeated note-ons during that same step do not create another onset.

### 9.5 Step completion

The existing step-completion rule remains unchanged.

Tempo measurement does not advance the exercise or relax the expected-note-set requirement.

## 10. Attempt lifecycle

### 10.1 Start

When the first note starts a new exercise repetition:

- Reset all previous tempo state.
- Mark the input source.
- Record the first step onset when the first expected note arrives.

The wait before the first note is not part of tempo calculation.

### 10.2 During practice

For every newly started `PracticeStep`:

1. Record at most one onset.
2. Preserve the timestamp in step order.
3. Continue the current accuracy and step-completion logic.

### 10.3 Completion

When the exercise completes:

1. Calculate tempo statistics.
2. Create one `ExerciseCompletionResult`.
3. Persist one ordinary exercise-history entry.
4. Reset through the existing repetition flow.

### 10.4 Reset or abandonment

If the learner resets, changes configuration, navigates away, or otherwise abandons an incomplete repetition:

- Discard all onset timestamps for that repetition.
- Save no tempo history entry.
- Preserve existing practice behaviour.

## 11. Calculation

Given ordered step-onset timestamps:

```text
t0, t1, t2, ..., tn
```

calculate inter-onset intervals:

```text
i1 = t1 - t0
i2 = t2 - t1
...
in = tn - t(n - 1)
```

Only strictly positive intervals are valid.

### 11.1 Mean interval

Use the arithmetic mean:

```text
mean = sum(intervals) / intervalCount
```

Calculate in microseconds to avoid unnecessary loss of precision.

### 11.2 Standard deviation

Use population standard deviation for the intervals in one completed repetition:

```text
variance = sum((interval - mean)²) / intervalCount
standardDeviation = sqrt(variance)
```

Version 1 treats the completed repetition as the complete measured population, not a sample of an unknown larger sequence.

### 11.3 Coefficient of variation

Calculate:

```text
coefficientOfVariation = standardDeviation / mean
```

This normalises timing variation across slow and fast exercises.

### 11.4 Exercise BPM

Because one `PracticeStep` equals one exercise beat:

```text
exerciseBpm = 60,000,000 / meanIntervalMicroseconds
```

Do not clamp the calculated value to the metronome’s supported range.

The stored and displayed value may be rounded to one decimal place, while calculations use the unrounded value.

## 12. Reliability classification

```dart
enum TempoMeasurementQuality {
  unavailable,
  insufficientData,
  inconsistent,
  reliable,
}
```

### 12.1 Unavailable

Use `unavailable` when:

- The repetition did not use only supported external MIDI input.
- A required timestamp is missing.
- Timestamps are non-monotonic.
- An interval is zero or negative.
- A clock reset or MIDI reconnect occurred during the repetition.
- Calculation otherwise fails validation.

No BPM is exposed.

### 12.2 Insufficient data

Use `insufficientData` unless both conditions are met:

```text
interval count >= 5
measured span >= 2 seconds
```

The measured span is:

```text
last onset - first onset
```

No BPM is exposed.

This intentionally excludes short exercises and very brief repetitions from progression evidence.

### 12.3 Inconsistent

Use `inconsistent` when sufficient data exists but:

```text
coefficient of variation > 0.15
```

No outlier removal is performed.

A hesitation, acceleration, or isolated long pause is treated as genuine inconsistency rather than silently discarded.

No BPM is exposed to the learner or skill-progression evaluator.

### 12.4 Reliable

Use `reliable` when:

- The input source is supported.
- All timestamps and intervals are valid.
- At least five intervals exist.
- The measured span is at least two seconds.
- The coefficient of variation is no greater than 0.15.

Only `reliable` results expose `measuredTempoBpm`.

### 12.5 Threshold configuration

The version 1 values shall be named constants and covered by tests:

```dart
abstract final class TempoMeasurementThresholds {
  static const minimumIntervalCount = 5;
  static const minimumMeasuredDuration = Duration(seconds: 2);
  static const maximumCoefficientOfVariation = 0.15;
}
```

Changing these constants changes product behaviour and requires test and UX review.

## 13. Result model

```dart
@immutable
class ExerciseTempoResult {
  const ExerciseTempoResult({
    required this.quality,
    required this.intervalCount,
    this.measuredTempoBpm,
    this.meanInterOnsetMicroseconds,
    this.interOnsetStandardDeviationMicroseconds,
    this.coefficientOfVariation,
  });

  final TempoMeasurementQuality quality;

  /// Number of inter-onset intervals, not onset count.
  final int intervalCount;

  /// Present only when quality is reliable.
  final double? measuredTempoBpm;

  /// May be retained for sufficient and inconsistent measurements.
  final int? meanInterOnsetMicroseconds;

  /// May be retained for sufficient and inconsistent measurements.
  final int? interOnsetStandardDeviationMicroseconds;

  /// May be retained for sufficient and inconsistent measurements.
  final double? coefficientOfVariation;
}
```

The result must enforce:

```text
quality == reliable  → measuredTempoBpm != null
quality != reliable  → measuredTempoBpm == null
```

## 14. Tempo tracker

Add a small stateful tracker owned by `PracticeRunner`.

```dart
class ExerciseTempoTracker {
  void reset();

  void recordStepOnset({
    required int stepIndex,
    required Duration occurredAt,
    required ExerciseInputSource source,
  });

  ExerciseTempoResult complete();
}
```

Responsibilities:

- Store one onset per step.
- Reject duplicate or out-of-order step indexes.
- Detect mixed or unsupported input.
- Validate monotonic timestamps.
- Calculate the final result through a pure calculator.

Separate the pure calculation into a testable domain service:

```dart
abstract final class ExerciseTempoCalculator {
  static ExerciseTempoResult calculate(
    List<Duration> orderedOnsets,
  );
}
```

## 15. Practice Runner integration

Change note handling to include timestamp and source:

```dart
void handleNotePressed(
  int midiNote, {
  required Duration occurredAt,
  required ExerciseInputSource inputSource,
})
```

When the current step receives its first expected note:

```dart
_tempoTracker.recordStepOnset(
  stepIndex: _currentStepIndex,
  occurredAt: occurredAt,
  source: inputSource,
);
```

Reset the tracker in both:

- `startPractice()`
- `resetPractice()`

Complete it in `_completeExercise()`.

## 16. Completion result

Replace the growing positional completion callback with one result object.

```dart
@immutable
class ExerciseCompletionResult {
  const ExerciseCompletionResult({
    required this.accuracyPercentage,
    required this.correctNoteCount,
    required this.errorCount,
    required this.tempo,
  });

  final double? accuracyPercentage;
  final int correctNoteCount;
  final int errorCount;
  final ExerciseTempoResult tempo;
}
```

Update:

- `PracticeRunner`
- `PracticeSession`
- `PracticePageViewModel`
- Completion tests
- History creation

This keeps future performance metrics from adding further positional callback parameters.

## 17. History persistence

Extend `ExerciseHistoryEntry` with nullable tempo evidence:

```dart
final double? measuredTempoBpm;
final int? meanInterOnsetMicroseconds;
final int? interOnsetStandardDeviationMicroseconds;
final double? tempoCoefficientOfVariation;
final int? tempoIntervalCount;
final TempoMeasurementQuality? tempoMeasurementQuality;
final int? tempoMeasurementVersion;
```

Use:

```text
tempoMeasurementVersion = 1
```

for entries created by this specification.

### 17.1 Reliable result

Persist:

- `measuredTempoBpm`
- Mean interval
- Standard deviation
- Coefficient of variation
- Interval count
- `reliable`
- Version 1

### 17.2 Insufficient or inconsistent result

Persist:

- `measuredTempoBpm = null`
- Available summary statistics
- Interval count
- Quality
- Version 1

### 17.3 Unavailable result

Persist:

- `measuredTempoBpm = null`
- Quality
- Version 1

Other statistic fields may remain null.

### 17.4 Existing rows

All new database columns must be nullable.

Existing history rows remain valid and mean:

```text
tempo measurement not available
```

## 18. Metronome independence

The metronome is optional.

Version 1 tempo measurement:

- Runs whenever a supported external MIDI exercise is performed.
- Does not require the metronome to be running.
- Does not use configured metronome BPM.
- Does not compare the learner against metronome clicks.
- Does not change metronome scheduling.
- Does not add `reliable_interval_timer`.

Recording whether the metronome was enabled is deferred. It is contextual information, not required to calculate performed tempo.

## 19. User experience

### 19.1 Reliable measurement

When the result is reliable, the existing completion overlay may add:

```text
Exercise completed! 94% accuracy · 82 BPM
```

The History page may display:

```text
82 BPM
Steady timing
```

### 19.2 Insufficient data

Do not display an estimated BPM.

The ordinary completion message remains unchanged.

History may show a neutral value such as:

```text
Tempo not recorded
Exercise too short
```

This explanatory text is optional for the first UI increment.

### 19.3 Inconsistent timing

Do not display an estimated BPM.

The ordinary completion message remains positive and unchanged.

History may show:

```text
Tempo not recorded
Timing varied
```

Do not use red, failure language, or a punitive visual state.

### 19.4 Unavailable measurement

Do not display BPM.

Practice and accuracy continue normally.

### 19.5 Skill progression

Only history entries with:

```text
tempoMeasurementQuality == reliable
measuredTempoBpm != null
```

may count as tempo evidence.

No fallback to configured metronome BPM is allowed.

## 20. Failure behaviour

Tempo calculation must never interrupt exercise completion.

If timestamping or calculation fails:

1. Log the failure.
2. Produce `TempoMeasurementQuality.unavailable`.
3. Save the ordinary accuracy history entry.
4. Show the normal completion feedback.
5. Reset for the next repetition.

Tempo is supplemental evidence, not a prerequisite for completing practice.

## 21. Testing

### 21.1 Calculator unit tests

Test:

- Empty onset list.
- One onset.
- Five intervals but less than two seconds.
- Exactly five intervals and exactly two seconds.
- Perfectly regular intervals.
- Small acceptable variation.
- Coefficient of variation exactly 0.15.
- Coefficient of variation above 0.15.
- Zero interval.
- Negative interval.
- Non-monotonic timestamps.
- BPM conversion.
- One-decimal display rounding without calculation rounding.

### 21.2 Tracker unit tests

Test:

- One onset per step.
- Chord notes create one onset.
- Wrong notes create no onset.
- Repeated expected notes create no additional onset.
- Step indexes must increase.
- Reset clears timestamps.
- Mixed external and virtual input becomes unavailable.
- Virtual-only input becomes unavailable.
- Completion returns the expected quality.

### 21.3 Runner tests

Test:

- Existing accuracy behaviour remains unchanged.
- The first expected note starts a step onset.
- Completion includes one tempo result.
- Repetition reset starts a fresh measurement.
- Auto-key progression starts a fresh measurement.
- Incomplete repetitions save nothing.

### 21.4 MIDI pipeline tests

Test:

- `MidiConnectionService` captures `receivedAt` before handler dispatch.
- Packet timestamps are monotonic.
- Timestamp survives repository, coordinator, parser, and `MidiEvent`.
- Logging does not alter the captured timestamp.
- Plugin transport timestamp is not used by the calculator.
- Reconnect during an attempt invalidates the measurement.

### 21.5 Persistence tests

Test:

- Reliable results round-trip through Drift.
- Inconsistent results store statistics but no BPM.
- Insufficient results store no BPM.
- Existing rows with null tempo fields remain readable.
- Measurement version round-trips.

### 21.6 Widget tests

Test:

- Reliable BPM appears in completion feedback.
- Unreliable BPM never appears.
- Accuracy feedback remains available.
- History uses neutral wording for unavailable tempo.
- No colour alone communicates reliability.

## 22. Real-device timing validation

Unit tests cannot validate main-isolate or transport jitter.

Before enabling user-facing BPM on a supported platform, run a fixed-rate MIDI input test using a hardware or software MIDI source.

Recommended validation sequence:

```text
32 note-on events
500 ms target interval
Expected exercise tempo: 120 BPM
```

Run under:

- Idle UI.
- Normal piano highlighting.
- Repeated widget rebuilds.
- Scrolling or animation.
- Debug logging disabled.
- Deliberate short main-isolate load.
- Each supported MIDI transport intended for release.

### 22.1 Normal-load acceptance

Under normal UI load:

- Reported reliable BPM is within ±2 BPM of the source.
- Application-added coefficient of variation is no greater than 0.03.
- No events are lost or reordered.

### 22.2 Stress behaviour

Under deliberate main-isolate stalls:

- A materially distorted sequence must not be reported as reliable.
- The result should become `inconsistent` or `unavailable`.
- The app must not show a confidently precise but incorrect BPM.

### 22.3 Release gating

If a platform or transport cannot meet the normal-load acceptance criteria:

- Tempo display must remain disabled for that environment.
- Accuracy practice remains available.
- The limitation must not be hidden by loosening the learner-consistency threshold.

## 23. Suggested files

```text
lib/domain/models/midi/
└── midi_input_packet.dart

lib/domain/models/practice/
├── exercise_completion_result.dart
└── exercise_tempo_result.dart

lib/domain/services/practice/
└── exercise_tempo_calculator.dart

lib/application/state/
└── exercise_tempo_tracker.dart
```

Existing files to extend:

```text
lib/application/services/midi/midi_connection_service.dart
lib/domain/repositories/midi_repository.dart
lib/application/repositories/midi_repository_impl.dart
lib/application/utils/midi_coordinator.dart
lib/application/utils/midi_data_handler.dart
lib/domain/models/midi/midi_event.dart
lib/application/state/practice_runner.dart
lib/application/state/practice_session.dart
lib/presentation/features/practice/practice_page_view_model.dart
lib/domain/models/practice/exercise_history_entry.dart
lib/application/database/
```

## 24. Incremental delivery

### Increment 1: Timestamped MIDI packets

- Add the application monotonic receive clock.
- Add `MidiInputPacket`.
- Propagate timestamps through `MidiEvent`.
- Update tests and mocks.
- Do not change the Practice Page UI.

### Increment 2: Tempo calculation

- Add the pure calculator.
- Add the tracker to `PracticeRunner`.
- Add `ExerciseCompletionResult`.
- Produce quality classifications.
- Do not persist or display yet.

### Increment 3: History persistence

- Add nullable Drift columns.
- Persist result statistics.
- Add repository tests.
- Keep existing history compatible.

### Increment 4: User-facing BPM

- Complete real-device validation.
- Display BPM only for reliable results.
- Preserve neutral behaviour for all other qualities.

### Increment 5: Skill-progression consumption

- Filter for reliable tempo evidence.
- Combine tempo with the configured pitch-accuracy threshold.
- Keep the proficiency evaluator outside the Practice Runner.

## 25. Acceptance criteria

The minimum viable feature is complete when:

1. External MIDI packets receive an application-owned monotonic timestamp at the earliest Dart callback.
2. One onset is recorded for each `PracticeStep`.
3. Chords create one step onset.
4. Wrong notes do not create tempo onsets.
5. Inter-onset intervals are calculated after exercise completion.
6. One `PracticeStep` is treated as one exercise beat.
7. Mean interval, standard deviation, coefficient of variation, and interval count are calculated.
8. Fewer than five intervals or less than two seconds produces no BPM.
9. Coefficient of variation above 0.15 produces no BPM.
10. Only reliable results expose a measured BPM.
11. No outliers are silently removed.
12. Tempo calculation works without the metronome.
13. The metronome’s configured BPM is never used as performed tempo.
14. Tempo failure never blocks completion or accuracy history.
15. Statistics and quality are stored in the existing history event.
16. Existing history rows remain readable.
17. Virtual-piano attempts do not provide progression tempo evidence.
18. The existing runner and repetition flow remain in use.
19. No periodic or isolate timer is introduced.
20. Real-device normal-load validation meets the defined error and jitter limits.
21. Deliberate timing distortion does not produce a confident user-facing BPM.

## 26. Future extensions

Possible later work includes:

- Validated use of native transport timestamps.
- Per-platform timestamp normalisation.
- `stepsPerBeat` and explicit rhythmic profiles.
- Metronome-on/off context in history.
- Difference from configured metronome BPM.
- Beat-grid timing accuracy.
- Early and late onset counts.
- Median and median absolute deviation.
- Short-exercise pooling across repetitions.
- Chord spread and synchronisation.
- Virtual-piano timing qualification.
- Raw interval retention for diagnostic sessions.
- Adaptive consistency thresholds based on exercise type.

## 27. Summary

PianoFitness will measure exercise tempo by timestamping expected `PracticeStep` onsets from external MIDI input.

Version 1 defines one step as one exercise beat. It calculates inter-onset intervals, mean interval, standard deviation, coefficient of variation, and exercise BPM. A result is reliable only when it contains at least five intervals, spans at least two seconds, and has a coefficient of variation no greater than 0.15.

The application uses its own monotonic receive clock at the earliest Dart MIDI callback. It does not use a periodic timer, metronome scheduler, or plugin timestamp to calculate tempo.

Most importantly, PianoFitness does not display or use an exact BPM unless the measurement passes its reliability gates. Timing uncertainty therefore degrades gracefully into “tempo not recorded” rather than becoming a misleading user-facing result.
