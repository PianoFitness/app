import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/practice/tempo_consistency_interpreter.dart";

void main() {
  group("TempoConsistencyInterpreter", () {
    test("uses the stored coefficient when available", () {
      final result = TempoConsistencyInterpreter.assess(
        coefficientOfVariation: 0.08,
        meanInterOnsetMicroseconds: 400000,
        interOnsetStandardDeviationMicroseconds: 200000,
        intervalCount: 8,
      );

      expect(result?.band, TempoConsistencyBand.steady);
      expect(result?.coefficientOfVariation, 0.08);
    });

    test("reconstructs the coefficient from mean and standard deviation", () {
      final result = TempoConsistencyInterpreter.assess(
        meanInterOnsetMicroseconds: 400000,
        interOnsetStandardDeviationMicroseconds: 60000,
        intervalCount: 8,
      );

      expect(result?.band, TempoConsistencyBand.mostlySteady);
      expect(result?.coefficientOfVariation, closeTo(0.15, 0.000001));
    });

    test("classifies variation using runtime feedback thresholds", () {
      expect(
        TempoConsistencyInterpreter.assess(coefficientOfVariation: 0.10)?.band,
        TempoConsistencyBand.steady,
      );
      expect(
        TempoConsistencyInterpreter.assess(coefficientOfVariation: 0.20)?.band,
        TempoConsistencyBand.mostlySteady,
      );
      expect(
        TempoConsistencyInterpreter.assess(coefficientOfVariation: 0.21)?.band,
        TempoConsistencyBand.varied,
      );
    });

    test("short interval count takes precedence over consistency", () {
      final result = TempoConsistencyInterpreter.assess(
        coefficientOfVariation: 0.02,
        meanInterOnsetMicroseconds: 500000,
        intervalCount: 4,
      );

      expect(result?.band, TempoConsistencyBand.shortSample);
    });

    test("short measured duration takes precedence over consistency", () {
      final result = TempoConsistencyInterpreter.assess(
        coefficientOfVariation: 0.02,
        meanInterOnsetMicroseconds: 300000,
        intervalCount: 5,
      );

      expect(result?.band, TempoConsistencyBand.shortSample);
    });

    test("returns null when no valid statistics exist", () {
      expect(TempoConsistencyInterpreter.assess(), isNull);
      expect(
        TempoConsistencyInterpreter.assess(
          coefficientOfVariation: double.nan,
          meanInterOnsetMicroseconds: 0,
          interOnsetStandardDeviationMicroseconds: -1,
        ),
        isNull,
      );
    });
  });
}
