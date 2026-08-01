import "dart:math";

import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";

/// Pure performed-tempo calculation for one completed exercise attempt.
abstract final class ExerciseTempoCalculator {
  static ExerciseTempoResult calculate(List<Duration> orderedOnsets) {
    final intervalCount = max(orderedOnsets.length - 1, 0);
    if (orderedOnsets.length < 2) {
      return ExerciseTempoResult(
        quality: TempoMeasurementQuality.insufficientData,
        intervalCount: intervalCount,
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

    final measuredSpan = orderedOnsets.last - orderedOnsets.first;
    if (intervals.length < TempoMeasurementThresholds.minimumIntervalCount ||
        measuredSpan < TempoMeasurementThresholds.minimumMeasuredDuration) {
      return ExerciseTempoResult(
        quality: TempoMeasurementQuality.insufficientData,
        intervalCount: intervals.length,
        meanInterOnsetMicroseconds: meanMicroseconds,
        interOnsetStandardDeviationMicroseconds: standardDeviationMicroseconds,
        coefficientOfVariation: coefficientOfVariation,
      );
    }

    if (coefficientOfVariation >
        TempoMeasurementThresholds.maximumCoefficientOfVariation) {
      return ExerciseTempoResult(
        quality: TempoMeasurementQuality.inconsistent,
        intervalCount: intervals.length,
        meanInterOnsetMicroseconds: meanMicroseconds,
        interOnsetStandardDeviationMicroseconds: standardDeviationMicroseconds,
        coefficientOfVariation: coefficientOfVariation,
      );
    }

    return ExerciseTempoResult(
      quality: TempoMeasurementQuality.reliable,
      intervalCount: intervals.length,
      measuredTempoBpm: 60000000 / mean,
      meanInterOnsetMicroseconds: meanMicroseconds,
      interOnsetStandardDeviationMicroseconds: standardDeviationMicroseconds,
      coefficientOfVariation: coefficientOfVariation,
    );
  }
}
