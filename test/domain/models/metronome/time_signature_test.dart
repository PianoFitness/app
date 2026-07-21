import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";

void main() {
  group("TimeSignature", () {
    test("label formats as numerator/denominator", () {
      expect(TimeSignature.fourFour.label, equals("4/4"));
      expect(TimeSignature.sixEight.label, equals("6/8"));
    });

    test("equality is based on numerator and denominator", () {
      const other = TimeSignature.fourFour;
      expect(TimeSignature.fourFour, equals(other));
      expect(TimeSignature.fourFour, isNot(equals(TimeSignature.threeFour)));
    });

    test("common presets have a pattern entry per beat", () {
      for (final signature in TimeSignature.common) {
        expect(signature.pattern, hasLength(signature.numerator));
      }
    });
  });
}
