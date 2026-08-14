import "dart:math";

import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_step_note_value.dart";

/// Pure performed-tempo calculation for one completed exercise attempt.
abstract final class ExerciseTempoCalculator {
  /// Converts a mean inter-onset interval to quarter-note BPM.
  ///
  /// This conversion is independent of measurement quality: a rhythmically
  /// variable attempt still has an observable average tempo even when it is
  /// not reliable enough to count as proficiency evidence.
  static double bpmFromMeanInterval({
    required int meanMicroseconds,
    required PracticeStepNoteValue noteValue,
  }) {
    if (meanMicroseconds <= 0) {
      throw ArgumentError.value(
        meanMicroseconds,
        "meanMicroseconds",
        "must be positive",
      );
    }
    return 60000000 * noteValue.quarterNoteBeats / meanMicroseconds;
  }

  static ExerciseTempoResult calculate(
    List<Duration> orderedOnsets, {
    required PracticeStepNoteValue noteValue,
  }) {
    final intervalCount = max(orderedOnsets.length - 1, 0);
    if (orderedOnsets.length < 2) {
      return ExerciseTempoResult(
        quality: TempoMeasurementQuality.insufficientData,
        intervalCount: intervalCount,
        tempoStepNoteValue: noteValue,
      );
    }

    final intervals = <int>[];
    for (var index = 1; index < orderedOnsets.length; index++) {
      final interval =
          orderedOnsets[index].inMicroseconds -
          orderedOnsets[index - 1].inMicroseconds;
      if (interval <= 0) {
        return ExerciseTempoResult(
          quality: TempoMeasurementQuality.unavailable,
          intervalCount: intervalCount,
        );
      }
      intervals.add(interval);
    }

    final mean =
        intervals.reduce((sum, interval) => sum + interval) / intervals.length;
    final variance =
        intervals
            .map((interval) => pow(interval - mean, 2))
            .reduce((sum, square) => sum + square) /
        intervals.length;
    final standardDeviation = sqrt(variance);
    final coefficientOfVariation = standardDeviation / mean;
    final meanMicroseconds = mean.round();
    final standardDeviationMicroseconds = standardDeviation.round();
    final measuredTempoBpm = 60000000 * noteValue.quarterNoteBeats / mean;

    final measuredSpan = orderedOnsets.last - orderedOnsets.first;
    if (intervals.length < TempoMeasurementThresholds.minimumIntervalCount ||
        measuredSpan < TempoMeasurementThresholds.minimumMeasuredDuration) {
      return ExerciseTempoResult(
        quality: TempoMeasurementQuality.insufficientData,
        intervalCount: intervals.length,
        measuredTempoBpm: measuredTempoBpm,
        meanInterOnsetMicroseconds: meanMicroseconds,
        interOnsetStandardDeviationMicroseconds: standardDeviationMicroseconds,
        coefficientOfVariation: coefficientOfVariation,
        tempoStepNoteValue: noteValue,
      );
    }

    if (coefficientOfVariation >
        TempoMeasurementThresholds.maximumCoefficientOfVariation) {
      return ExerciseTempoResult(
        quality: TempoMeasurementQuality.inconsistent,
        intervalCount: intervals.length,
        measuredTempoBpm: measuredTempoBpm,
        meanInterOnsetMicroseconds: meanMicroseconds,
        interOnsetStandardDeviationMicroseconds: standardDeviationMicroseconds,
        coefficientOfVariation: coefficientOfVariation,
        tempoStepNoteValue: noteValue,
      );
    }

    return ExerciseTempoResult(
      quality: TempoMeasurementQuality.reliable,
      intervalCount: intervals.length,
      measuredTempoBpm: measuredTempoBpm,
      meanInterOnsetMicroseconds: meanMicroseconds,
      interOnsetStandardDeviationMicroseconds: standardDeviationMicroseconds,
      coefficientOfVariation: coefficientOfVariation,
      tempoStepNoteValue: noteValue,
    );
  }
}
