import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";

/// Learner-facing bands derived from an attempt's timing statistics.
///
/// These bands describe how even the tempo felt. They are deliberately
/// separate from [TempoMeasurementQuality], which records whether an attempt
/// qualified as proficiency evidence under its measurement algorithm.
enum TempoConsistencyBand { steady, mostlySteady, varied, shortSample }

/// A runtime interpretation of stored inter-onset statistics.
@immutable
class TempoConsistencyAssessment {
  const TempoConsistencyAssessment({
    required this.band,
    this.coefficientOfVariation,
  });

  final TempoConsistencyBand band;

  /// Population standard deviation divided by the mean interval.
  final double? coefficientOfVariation;
}

/// Converts neutral timing statistics into learner-facing feedback.
///
/// Thresholds live here rather than in persisted history so the product can
/// refine its feedback language without rewriting previous attempts.
abstract final class TempoConsistencyInterpreter {
  /// Up to 10% relative timing variation reads as steady.
  static const maximumSteadyCoefficient = 0.10;

  /// Up to 20% relative timing variation reads as mostly steady.
  static const maximumMostlySteadyCoefficient = 0.20;

  static TempoConsistencyAssessment? assess({
    double? coefficientOfVariation,
    int? meanInterOnsetMicroseconds,
    int? interOnsetStandardDeviationMicroseconds,
    int? intervalCount,
    TempoMeasurementQuality? measurementQuality,
  }) {
    final coefficient = _validCoefficient(
      coefficientOfVariation,
      meanInterOnsetMicroseconds: meanInterOnsetMicroseconds,
      interOnsetStandardDeviationMicroseconds:
          interOnsetStandardDeviationMicroseconds,
    );

    if (_isShortSample(
      meanInterOnsetMicroseconds: meanInterOnsetMicroseconds,
      intervalCount: intervalCount,
      measurementQuality: measurementQuality,
    )) {
      return TempoConsistencyAssessment(
        band: TempoConsistencyBand.shortSample,
        coefficientOfVariation: coefficient,
      );
    }

    if (coefficient == null) return null;
    final band = switch (coefficient) {
      <= maximumSteadyCoefficient => TempoConsistencyBand.steady,
      <= maximumMostlySteadyCoefficient => TempoConsistencyBand.mostlySteady,
      _ => TempoConsistencyBand.varied,
    };
    return TempoConsistencyAssessment(
      band: band,
      coefficientOfVariation: coefficient,
    );
  }

  static double? _validCoefficient(
    double? stored, {
    required int? meanInterOnsetMicroseconds,
    required int? interOnsetStandardDeviationMicroseconds,
  }) {
    if (stored != null && stored.isFinite && stored >= 0) return stored;
    if (meanInterOnsetMicroseconds == null ||
        meanInterOnsetMicroseconds <= 0 ||
        interOnsetStandardDeviationMicroseconds == null ||
        interOnsetStandardDeviationMicroseconds < 0) {
      return null;
    }
    return interOnsetStandardDeviationMicroseconds / meanInterOnsetMicroseconds;
  }

  static bool _isShortSample({
    required int? meanInterOnsetMicroseconds,
    required int? intervalCount,
    required TempoMeasurementQuality? measurementQuality,
  }) {
    if (measurementQuality == TempoMeasurementQuality.insufficientData) {
      return true;
    }
    if (intervalCount == null) return false;
    if (intervalCount < TempoMeasurementThresholds.minimumIntervalCount) {
      return true;
    }
    if (meanInterOnsetMicroseconds == null || meanInterOnsetMicroseconds <= 0) {
      return false;
    }
    final measuredMicroseconds = meanInterOnsetMicroseconds * intervalCount;
    return measuredMicroseconds <
        TempoMeasurementThresholds.minimumMeasuredDuration.inMicroseconds;
  }
}
