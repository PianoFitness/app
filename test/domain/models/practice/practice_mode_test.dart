import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";

void main() {
  group("PracticeMode", () {
    test("should have all expected values", () {
      expect(PracticeMode.values.length, equals(6));
      expect(PracticeMode.values, contains(PracticeMode.scales));
      expect(PracticeMode.values, contains(PracticeMode.chordsByKey));
      expect(PracticeMode.values, contains(PracticeMode.chordsByType));
      expect(PracticeMode.values, contains(PracticeMode.arpeggios));
      expect(PracticeMode.values, contains(PracticeMode.chordProgressions));
      expect(PracticeMode.values, contains(PracticeMode.dominantCadence));
    });

    test("should have stable name property for serialization", () {
      // Prefer .name over .toString() for stability and serialization
      expect(PracticeMode.scales.name, equals("scales"));
      expect(PracticeMode.chordsByKey.name, equals("chordsByKey"));
      expect(PracticeMode.chordsByType.name, equals("chordsByType"));
      expect(PracticeMode.arpeggios.name, equals("arpeggios"));
      expect(PracticeMode.chordProgressions.name, equals("chordProgressions"));
      expect(PracticeMode.dominantCadence.name, equals("dominantCadence"));

      // toString() includes type prefix, less ideal for serialization
      expect(PracticeMode.scales.toString(), equals("PracticeMode.scales"));
      expect(
        PracticeMode.chordsByKey.toString(),
        equals("PracticeMode.chordsByKey"),
      );
      expect(
        PracticeMode.chordsByType.toString(),
        equals("PracticeMode.chordsByType"),
      );
      expect(
        PracticeMode.arpeggios.toString(),
        equals("PracticeMode.arpeggios"),
      );
      expect(
        PracticeMode.chordProgressions.toString(),
        equals("PracticeMode.chordProgressions"),
      );
      expect(
        PracticeMode.dominantCadence.toString(),
        equals("PracticeMode.dominantCadence"),
      );
    });

    test("should support equality comparison", () {
      expect(PracticeMode.scales, equals(PracticeMode.scales));
      expect(PracticeMode.chordsByKey, equals(PracticeMode.chordsByKey));
      expect(PracticeMode.chordsByType, equals(PracticeMode.chordsByType));
      expect(PracticeMode.arpeggios, equals(PracticeMode.arpeggios));

      expect(PracticeMode.scales, isNot(equals(PracticeMode.chordsByKey)));
      expect(PracticeMode.chordsByKey, isNot(equals(PracticeMode.arpeggios)));
      expect(PracticeMode.arpeggios, isNot(equals(PracticeMode.scales)));
    });

    test("should support switch statements", () {
      String getModeString(PracticeMode mode) {
        switch (mode) {
          case PracticeMode.scales:
            return "Scales";
          case PracticeMode.chordsByKey:
            return "Chords by Key";
          case PracticeMode.chordsByType:
            return "Chord Types";
          case PracticeMode.arpeggios:
            return "Arpeggios";
          case PracticeMode.chordProgressions:
            return "Chord Progressions";
          case PracticeMode.dominantCadence:
            return "Dominant Cadence";
        }
      }

      expect(getModeString(PracticeMode.scales), equals("Scales"));
      expect(getModeString(PracticeMode.chordsByKey), equals("Chords by Key"));
      expect(getModeString(PracticeMode.chordsByType), equals("Chord Types"));
      expect(getModeString(PracticeMode.arpeggios), equals("Arpeggios"));
      expect(
        getModeString(PracticeMode.chordProgressions),
        equals("Chord Progressions"),
      );
      expect(
        getModeString(PracticeMode.dominantCadence),
        equals("Dominant Cadence"),
      );
    });

    test("should serialize to and from JSON correctly", () {
      // Test toJson() returns expected string values
      expect(PracticeMode.scales.toJson(), equals("scales"));
      expect(PracticeMode.chordsByKey.toJson(), equals("chordsByKey"));
      expect(PracticeMode.chordsByType.toJson(), equals("chordsByType"));
      expect(PracticeMode.arpeggios.toJson(), equals("arpeggios"));
      expect(
        PracticeMode.chordProgressions.toJson(),
        equals("chordProgressions"),
      );
      expect(PracticeMode.dominantCadence.toJson(), equals("dominantCadence"));

      // Test fromJson() reconstructs correct enum values
      expect(PracticeModeJson.fromJson("scales"), equals(PracticeMode.scales));
      expect(
        PracticeModeJson.fromJson("chordsByKey"),
        equals(PracticeMode.chordsByKey),
      );
      expect(
        PracticeModeJson.fromJson("chordsByType"),
        equals(PracticeMode.chordsByType),
      );
      expect(
        PracticeModeJson.fromJson("arpeggios"),
        equals(PracticeMode.arpeggios),
      );
      expect(
        PracticeModeJson.fromJson("chordProgressions"),
        equals(PracticeMode.chordProgressions),
      );
      expect(
        PracticeModeJson.fromJson("dominantCadence"),
        equals(PracticeMode.dominantCadence),
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
