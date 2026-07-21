import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/metronome/tempo_calculator.dart";

void main() {
  group("TempoCalculator", () {
    test("converts 120 BPM to a 500ms interval", () {
      expect(
        TempoCalculator.bpmToInterval(120),
        equals(const Duration(milliseconds: 500)),
      );
    });

    test("converts 60 BPM to a 1000ms interval", () {
      expect(
        TempoCalculator.bpmToInterval(60),
        equals(const Duration(seconds: 1)),
      );
    });

    test("round-trips interval back to BPM", () {
      for (final bpm in [40, 60, 90, 120, 168, 208]) {
        final interval = TempoCalculator.bpmToInterval(bpm);
        expect(TempoCalculator.intervalToBpm(interval), equals(bpm));
      }
    });

    test("clampBpm keeps in-range values unchanged", () {
      expect(TempoCalculator.clampBpm(120), equals(120));
    });

    test("clampBpm clamps below minBpm up to minBpm", () {
      expect(TempoCalculator.clampBpm(1), equals(TempoCalculator.minBpm));
    });

    test("clampBpm clamps above maxBpm down to maxBpm", () {
      expect(TempoCalculator.clampBpm(999), equals(TempoCalculator.maxBpm));
    });
  });
}
