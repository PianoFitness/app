import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/services/practice/exercise_tempo_calculator.dart";

void main() {
  List<Duration> onsets(List<int> milliseconds) =>
      milliseconds.map((value) => Duration(milliseconds: value)).toList();

  group("ExerciseTempoCalculator", () {
    test("marks fewer than five intervals as insufficient", () {
      final result = ExerciseTempoCalculator.calculate(onsets([0, 500, 1000]));

      expect(result.quality, TempoMeasurementQuality.insufficientData);
      expect(result.intervalCount, 2);
      expect(result.measuredTempoBpm, isNull);
    });

    test("requires a measured span of at least two seconds", () {
      final result = ExerciseTempoCalculator.calculate(
        onsets([0, 300, 600, 900, 1200, 1500]),
      );

      expect(result.quality, TempoMeasurementQuality.insufficientData);
      expect(result.intervalCount, 5);
      expect(result.measuredTempoBpm, isNull);
    });

    test("calculates reliable BPM for steady timing", () {
      final result = ExerciseTempoCalculator.calculate(
        onsets([0, 400, 800, 1200, 1600, 2000]),
      );

      expect(result.quality, TempoMeasurementQuality.reliable);
      expect(result.intervalCount, 5);
      expect(result.measuredTempoBpm, closeTo(150, 0.000001));
      expect(result.meanInterOnsetMicroseconds, 400000);
      expect(result.interOnsetStandardDeviationMicroseconds, 0);
      expect(result.coefficientOfVariation, 0);
    });

    test("withholds BPM when timing variation exceeds the threshold", () {
      final result = ExerciseTempoCalculator.calculate(
        onsets([0, 400, 800, 1200, 1600, 3200]),
      );

      expect(result.quality, TempoMeasurementQuality.inconsistent);
      expect(result.measuredTempoBpm, isNull);
      expect(
        result.coefficientOfVariation,
        greaterThan(TempoMeasurementThresholds.maximumCoefficientOfVariation),
      );
    });

    test("marks non-monotonic onsets unavailable", () {
      final result = ExerciseTempoCalculator.calculate(
        onsets([0, 400, 800, 800, 1600, 2000]),
      );

      expect(result.quality, TempoMeasurementQuality.unavailable);
      expect(result.measuredTempoBpm, isNull);
    });
  });
}
