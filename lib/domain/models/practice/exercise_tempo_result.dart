import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/practice/practice_step_note_value.dart";

/// Whether a completed exercise has usable performed-tempo evidence.
enum TempoMeasurementQuality {
  unavailable,
  insufficientData,
  inconsistent,
  reliable,
}

/// Input sources recognised by exercise performance tracking.
enum ExerciseInputSource { externalMidi, virtualPiano }

/// Product thresholds for a tempo measurement to be shown or reused.
abstract final class TempoMeasurementThresholds {
  static const minimumIntervalCount = 5;
  static const minimumMeasuredDuration = Duration(seconds: 2);
  static const maximumCoefficientOfVariation = 0.15;
}

/// Versions of the persisted tempo calculation algorithm.
abstract final class TempoMeasurementVersions {
  /// Version 2 converts declared step note values to quarter-note BPM.
  static const declaredStepDurations = 2;

  /// Version 3 explicitly defines scale-note onsets as eighth notes.
  static const scaleEighthNotes = 3;

  static const current = scaleEighthNotes;
}

/// Statistical evidence derived from the onsets of one exercise attempt.
@immutable
class ExerciseTempoResult {
  const ExerciseTempoResult({
    required this.quality,
    required this.intervalCount,
    this.measuredTempoBpm,
    this.meanInterOnsetMicroseconds,
    this.interOnsetStandardDeviationMicroseconds,
    this.coefficientOfVariation,
    this.tempoStepNoteValue,
  }) : assert(
         quality != TempoMeasurementQuality.reliable ||
             measuredTempoBpm != null,
       ),
       assert(measuredTempoBpm == null || tempoStepNoteValue != null),
       assert(
         quality != TempoMeasurementQuality.unavailable ||
             measuredTempoBpm == null,
       );

  final TempoMeasurementQuality quality;
  final int intervalCount;

  /// Average performed tempo when enough ordered onsets exist to calculate it.
  ///
  /// This can be present for an inconsistent or short attempt. [quality]
  /// determines whether the measurement is reliable enough for proficiency.
  final double? measuredTempoBpm;
  final int? meanInterOnsetMicroseconds;
  final int? interOnsetStandardDeviationMicroseconds;
  final double? coefficientOfVariation;

  /// The uniform step value used to convert onsets to quarter-note BPM.
  final PracticeStepNoteValue? tempoStepNoteValue;
}
