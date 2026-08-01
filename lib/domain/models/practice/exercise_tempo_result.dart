import "package:meta/meta.dart";

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
  }) : assert(
         quality == TempoMeasurementQuality.reliable
             ? measuredTempoBpm != null
             : measuredTempoBpm == null,
       );

  final TempoMeasurementQuality quality;
  final int intervalCount;
  final double? measuredTempoBpm;
  final int? meanInterOnsetMicroseconds;
  final int? interOnsetStandardDeviationMicroseconds;
  final double? coefficientOfVariation;
}
