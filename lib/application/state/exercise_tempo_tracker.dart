import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_step_note_value.dart";
import "package:piano_fitness/domain/services/practice/exercise_tempo_calculator.dart";

/// Collects one expected-note onset for each step in a practice attempt.
class ExerciseTempoTracker {
  final List<Duration> _onsets = [];
  ExerciseInputSource? _source;
  var _lastStepIndex = -1;
  var _isUnavailable = false;

  void reset() {
    _onsets.clear();
    _source = null;
    _lastStepIndex = -1;
    _isUnavailable = false;
  }

  void recordStepOnset({
    required int stepIndex,
    required Duration occurredAt,
    required ExerciseInputSource source,
  }) {
    recordInputSource(source);
    if (_isUnavailable) return;

    if (stepIndex <= _lastStepIndex) {
      _isUnavailable = true;
      return;
    }

    _lastStepIndex = stepIndex;
    _onsets.add(occurredAt);
  }

  /// Records a note-on source even when it is not an expected exercise note.
  /// A mixed attempt is not valid tempo evidence.
  void recordInputSource(ExerciseInputSource source) {
    if (_isUnavailable) return;
    if (_source != null && _source != source) {
      _isUnavailable = true;
      return;
    }
    _source ??= source;
    if (source != ExerciseInputSource.externalMidi) {
      _isUnavailable = true;
    }
  }

  ExerciseTempoResult complete({required PracticeStepNoteValue? noteValue}) {
    if (_isUnavailable ||
        _source != ExerciseInputSource.externalMidi ||
        noteValue == null) {
      return const ExerciseTempoResult(
        quality: TempoMeasurementQuality.unavailable,
        intervalCount: 0,
      );
    }
    return ExerciseTempoCalculator.calculate(_onsets, noteValue: noteValue);
  }
}
