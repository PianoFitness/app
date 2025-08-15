import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";

void main() {
  group("PracticeMode", () {
    test("should have all expected values", () {
      expect(PracticeMode.values.length, equals(3));
      expect(PracticeMode.values, contains(PracticeMode.scales));
      expect(PracticeMode.values, contains(PracticeMode.chords));
      expect(PracticeMode.values, contains(PracticeMode.arpeggios));
    });

    test("should have correct string representation", () {
      expect(PracticeMode.scales.toString(), equals("PracticeMode.scales"));
      expect(PracticeMode.chords.toString(), equals("PracticeMode.chords"));
      expect(
        PracticeMode.arpeggios.toString(),
        equals("PracticeMode.arpeggios"),
      );
    });

    test("should support equality comparison", () {
      expect(PracticeMode.scales, equals(PracticeMode.scales));
      expect(PracticeMode.chords, equals(PracticeMode.chords));
      expect(PracticeMode.arpeggios, equals(PracticeMode.arpeggios));

      expect(PracticeMode.scales, isNot(equals(PracticeMode.chords)));
      expect(PracticeMode.chords, isNot(equals(PracticeMode.arpeggios)));
      expect(PracticeMode.arpeggios, isNot(equals(PracticeMode.scales)));
    });

    test("should support switch statements", () {
      String getModeString(PracticeMode mode) {
        switch (mode) {
          case PracticeMode.scales:
            return "Scales";
          case PracticeMode.chords:
            return "Chords";
          case PracticeMode.arpeggios:
            return "Arpeggios";
        }
      }

      expect(getModeString(PracticeMode.scales), equals("Scales"));
      expect(getModeString(PracticeMode.chords), equals("Chords"));
      expect(getModeString(PracticeMode.arpeggios), equals("Arpeggios"));
    });

    test("should be serializable by index", () {
      expect(PracticeMode.scales.index, equals(0));
      expect(PracticeMode.chords.index, equals(1));
      expect(PracticeMode.arpeggios.index, equals(2));

      // Test that we can reconstruct from index
      expect(PracticeMode.values[0], equals(PracticeMode.scales));
      expect(PracticeMode.values[1], equals(PracticeMode.chords));
      expect(PracticeMode.values[2], equals(PracticeMode.arpeggios));
    });
  });
}
