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

    test("should have stable name property for serialization", () {
      // Prefer .name over .toString() for stability and serialization
      expect(PracticeMode.scales.name, equals("scales"));
      expect(PracticeMode.chords.name, equals("chords"));
      expect(PracticeMode.arpeggios.name, equals("arpeggios"));
      
      // toString() includes type prefix, less ideal for serialization
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

    test("should serialize to and from JSON correctly", () {
      // Test toJson() returns expected string values
      expect(PracticeMode.scales.toJson(), equals("scales"));
      expect(PracticeMode.chords.toJson(), equals("chords"));
      expect(PracticeMode.arpeggios.toJson(), equals("arpeggios"));

      // Test fromJson() reconstructs correct enum values
      expect(PracticeModeJson.fromJson("scales"), equals(PracticeMode.scales));
      expect(PracticeModeJson.fromJson("chords"), equals(PracticeMode.chords));
      expect(
        PracticeModeJson.fromJson("arpeggios"),
        equals(PracticeMode.arpeggios),
      );

      // Test round-trip serialization
      for (final mode in PracticeMode.values) {
        final serialized = mode.toJson();
        final deserialized = PracticeModeJson.fromJson(serialized);
        expect(deserialized, equals(mode));
      }
    });

    test("should handle invalid JSON gracefully", () {
      expect(() => PracticeModeJson.fromJson("invalid"), throwsArgumentError);
      expect(() => PracticeModeJson.fromJson(""), throwsArgumentError);
      expect(() => PracticeModeJson.fromJson("SCALES"), throwsArgumentError);
    });
  });
}
