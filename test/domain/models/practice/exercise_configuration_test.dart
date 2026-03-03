import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

void main() {
  group("ExerciseConfiguration", () {
    group("Construction & Defaults", () {
      test(
        "should create scales configuration with minimal required fields",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.scales,
            handSelection: HandSelection.both,
            key: music.Key.c,
            scaleType: music.ScaleType.major,
          );

          expect(config.practiceMode, equals(PracticeMode.scales));
          expect(config.handSelection, equals(HandSelection.both));
          expect(config.key, equals(music.Key.c));
          expect(config.scaleType, equals(music.ScaleType.major));
          expect(config.includeInversions, equals(false));
          expect(config.includeSeventhChords, equals(false));
          expect(config.arpeggioOctaves, equals(ArpeggioOctaves.one));
        },
      );

      test(
        "should create chordsByKey configuration with minimal required fields",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.chordsByKey,
            handSelection: HandSelection.right,
            key: music.Key.d,
            scaleType: music.ScaleType.minor,
          );

          expect(config.practiceMode, equals(PracticeMode.chordsByKey));
          expect(config.handSelection, equals(HandSelection.right));
          expect(config.key, equals(music.Key.d));
          expect(config.scaleType, equals(music.ScaleType.minor));
        },
      );

      test(
        "should create chordsByType configuration with minimal required fields",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.chordsByType,
            handSelection: HandSelection.left,
            chordType: ChordType.major,
          );

          expect(config.practiceMode, equals(PracticeMode.chordsByType));
          expect(config.handSelection, equals(HandSelection.left));
          expect(config.chordType, equals(ChordType.major));
        },
      );

      test(
        "should create arpeggios configuration with minimal required fields",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.arpeggios,
            handSelection: HandSelection.both,
            musicalNote: MusicalNote.c,
            arpeggioType: ArpeggioType.major,
          );

          expect(config.practiceMode, equals(PracticeMode.arpeggios));
          expect(config.handSelection, equals(HandSelection.both));
          expect(config.musicalNote, equals(MusicalNote.c));
          expect(config.arpeggioType, equals(ArpeggioType.major));
          expect(config.arpeggioOctaves, equals(ArpeggioOctaves.one));
        },
      );

      test(
        "should create chordProgressions configuration with minimal required fields",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.chordProgressions,
            handSelection: HandSelection.both,
            key: music.Key.c,
            chordProgressionId: "I - V",
          );

          expect(config.practiceMode, equals(PracticeMode.chordProgressions));
          expect(config.handSelection, equals(HandSelection.both));
          expect(config.key, equals(music.Key.c));
          expect(config.chordProgressionId, equals("I - V"));
        },
      );

      test("should respect non-default boolean values", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
          chordType: ChordType.major,
          includeInversions: true,
          includeSeventhChords: true,
        );

        expect(config.includeInversions, equals(true));
        expect(config.includeSeventhChords, equals(true));
      });

      test("should respect non-default arpeggio octaves", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          arpeggioOctaves: ArpeggioOctaves.two,
        );

        expect(config.arpeggioOctaves, equals(ArpeggioOctaves.two));
      });
    });

    group("Validation Rules", () {
      test("scales mode: should pass validation with required fields", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        expect(() => config.validate(), returnsNormally);
      });

      test("scales mode: should fail validation without key", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          scaleType: music.ScaleType.major,
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("key is required for scales mode"),
            ),
          ),
        );
      });

      test("scales mode: should fail validation without scaleType", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("scaleType is required for scales mode"),
            ),
          ),
        );
      });

      test("chordsByKey mode: should pass validation with required fields", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByKey,
          handSelection: HandSelection.both,
          key: music.Key.d,
          scaleType: music.ScaleType.minor,
        );

        expect(() => config.validate(), returnsNormally);
      });

      test("chordsByKey mode: should fail validation without key", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByKey,
          handSelection: HandSelection.both,
          scaleType: music.ScaleType.minor,
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("key is required for chordsByKey mode"),
            ),
          ),
        );
      });

      test("chordsByKey mode: should fail validation without scaleType", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByKey,
          handSelection: HandSelection.both,
          key: music.Key.d,
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("scaleType is required for chordsByKey mode"),
            ),
          ),
        );
      });

      test(
        "chordsByType mode: should pass validation with required fields",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.chordsByType,
            handSelection: HandSelection.both,
            chordType: ChordType.diminished,
          );

          expect(() => config.validate(), returnsNormally);
        },
      );

      test("chordsByType mode: should fail validation without chordType", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("chordType is required for chordsByType mode"),
            ),
          ),
        );
      });

      test("arpeggios mode: should pass validation with required fields", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.g,
          arpeggioType: ArpeggioType.minor,
        );

        expect(() => config.validate(), returnsNormally);
      });

      test("arpeggios mode: should fail validation without musicalNote", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          arpeggioType: ArpeggioType.minor,
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("musicalNote is required for arpeggios mode"),
            ),
          ),
        );
      });

      test("arpeggios mode: should fail validation without arpeggioType", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.g,
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("arpeggioType is required for arpeggios mode"),
            ),
          ),
        );
      });

      test(
        "chordProgressions mode: should pass validation with required fields",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.chordProgressions,
            handSelection: HandSelection.both,
            key: music.Key.f,
            chordProgressionId: "I - V",
          );

          expect(() => config.validate(), returnsNormally);
        },
      );

      test("chordProgressions mode: should fail validation without key", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordProgressions,
          handSelection: HandSelection.both,
          chordProgressionId: "I - V",
        );

        expect(
          () => config.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("key is required for chordProgressions mode"),
            ),
          ),
        );
      });

      test(
        "chordProgressions mode: should fail validation without chordProgressionId",
        () {
          final config = ExerciseConfiguration(
            practiceMode: PracticeMode.chordProgressions,
            handSelection: HandSelection.both,
            key: music.Key.f,
          );

          expect(
            () => config.validate(),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                "message",
                contains(
                  "chordProgressionId is required for chordProgressions mode",
                ),
              ),
            ),
          );
        },
      );
    });

    group("JSON Serialization", () {
      test("should serialize and deserialize scales configuration", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final json = original.toJson();
        final deserialized = ExerciseConfiguration.fromJson(json);

        expect(deserialized, equals(original));
        expect(json["practiceMode"], equals("scales"));
        expect(json["handSelection"], equals("both"));
        expect(json["key"], equals("c"));
        expect(json["scaleType"], equals("major"));
      });

      test("should serialize and deserialize chordsByKey configuration", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByKey,
          handSelection: HandSelection.right,
          key: music.Key.d,
          scaleType: music.ScaleType.minor,
          includeSeventhChords: true,
        );

        final json = original.toJson();
        final deserialized = ExerciseConfiguration.fromJson(json);

        expect(deserialized, equals(original));
        expect(json["practiceMode"], equals("chordsByKey"));
        expect(json["includeSeventhChords"], equals(true));
      });

      test("should serialize and deserialize chordsByType configuration", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.left,
          chordType: ChordType.diminished,
          includeInversions: true,
        );

        final json = original.toJson();
        final deserialized = ExerciseConfiguration.fromJson(json);

        expect(deserialized, equals(original));
        expect(json["practiceMode"], equals("chordsByType"));
        expect(json["chordType"], equals("diminished"));
        expect(json["includeInversions"], equals(true));
      });

      test("should serialize and deserialize arpeggios configuration", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.g,
          arpeggioType: ArpeggioType.minor,
          arpeggioOctaves: ArpeggioOctaves.two,
        );

        final json = original.toJson();
        final deserialized = ExerciseConfiguration.fromJson(json);

        expect(deserialized, equals(original));
        expect(json["practiceMode"], equals("arpeggios"));
        expect(json["musicalNote"], equals("g"));
        expect(json["arpeggioType"], equals("minor"));
        expect(json["arpeggioOctaves"], equals("two"));
      });

      test(
        "should serialize and deserialize chordProgressions configuration",
        () {
          final original = ExerciseConfiguration(
            practiceMode: PracticeMode.chordProgressions,
            handSelection: HandSelection.both,
            key: music.Key.f,
            chordProgressionId: "I - V",
          );

          final json = original.toJson();
          final deserialized = ExerciseConfiguration.fromJson(json);

          expect(deserialized, equals(original));
          expect(json["practiceMode"], equals("chordProgressions"));
          expect(json["key"], equals("f"));
          expect(json["chordProgressionId"], equals("I - V"));
        },
      );

      test("should omit fields with default values in JSON", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final json = config.toJson();

        expect(json.containsKey("includeInversions"), equals(false));
        expect(json.containsKey("includeSeventhChords"), equals(false));
        expect(json.containsKey("arpeggioOctaves"), equals(false));
      });

      test("should omit null fields in JSON", () {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
          chordType: ChordType.major,
        );

        final json = config.toJson();

        expect(json.containsKey("key"), equals(false));
        expect(json.containsKey("scaleType"), equals(false));
        expect(json.containsKey("musicalNote"), equals(false));
        expect(json.containsKey("arpeggioType"), equals(false));
        expect(json.containsKey("chordProgressionId"), equals(false));
      });

      test("should handle all enum values correctly in serialization", () {
        // Test all PracticeMode values
        for (final mode in PracticeMode.values) {
          final json = {"practiceMode": mode.name};
          expect(
            PracticeMode.values.byName(json["practiceMode"] as String),
            equals(mode),
          );
        }

        // Test all HandSelection values
        for (final hand in HandSelection.values) {
          final json = {"handSelection": hand.name};
          expect(
            HandSelection.values.byName(json["handSelection"] as String),
            equals(hand),
          );
        }
      });
    });

    group("Equality & HashCode", () {
      test("should be equal when all fields match", () {
        final config1 = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final config2 = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test("should not be equal when practice mode differs", () {
        final config1 = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final config2 = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByKey,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        expect(config1, isNot(equals(config2)));
      });

      test("should not be equal when hand selection differs", () {
        final config1 = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final config2 = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.right,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        expect(config1, isNot(equals(config2)));
      });

      test("should not be equal when mode-specific fields differ", () {
        final config1 = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
        );

        final config2 = ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.d,
          arpeggioType: ArpeggioType.major,
        );

        expect(config1, isNot(equals(config2)));
      });

      test("should not be equal when boolean flags differ", () {
        final config1 = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
          chordType: ChordType.major,
        );

        final config2 = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
          chordType: ChordType.major,
          includeInversions: true,
        );

        expect(config1, isNot(equals(config2)));
      });
    });

    group("CopyWith Field<T> Wrapper", () {
      test("should update non-nullable fields without Field wrapper", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final updated = original.copyWith(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.left,
        );

        expect(updated.practiceMode, equals(PracticeMode.chordsByType));
        expect(updated.handSelection, equals(HandSelection.left));
      });

      test("should preserve nullable fields when Field is unset", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final updated = original.copyWith(handSelection: HandSelection.right);

        expect(updated.key, equals(music.Key.c));
        expect(updated.scaleType, equals(music.ScaleType.major));
        expect(updated.handSelection, equals(HandSelection.right));
      });

      test("should clear nullable field when Field.set(null) is used", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final updated = original.copyWith(
          practiceMode: PracticeMode.chordsByType,
          key: const Field.set(null),
          scaleType: const Field.set(null),
          chordType: const Field.set(ChordType.major),
        );

        expect(updated.practiceMode, equals(PracticeMode.chordsByType));
        expect(updated.key, isNull);
        expect(updated.scaleType, isNull);
        expect(updated.chordType, equals(ChordType.major));
      });

      test("should update nullable field when Field.set(value) is used", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        );

        final updated = original.copyWith(
          key: const Field.set(music.Key.d),
          scaleType: const Field.set(music.ScaleType.minor),
        );

        expect(updated.key, equals(music.Key.d));
        expect(updated.scaleType, equals(music.ScaleType.minor));
      });

      test(
        "should handle mode switching: clear chordProgressionId when leaving chordProgressions mode",
        () {
          final original = ExerciseConfiguration(
            practiceMode: PracticeMode.chordProgressions,
            handSelection: HandSelection.both,
            key: music.Key.c,
            chordProgressionId: "I - V",
          );

          final updated = original.copyWith(
            practiceMode: PracticeMode.scales,
            scaleType: const Field.set(music.ScaleType.major),
            chordProgressionId: const Field.set(null),
          );

          expect(updated.practiceMode, equals(PracticeMode.scales));
          expect(updated.key, equals(music.Key.c)); // preserved
          expect(updated.scaleType, equals(music.ScaleType.major)); // set
          expect(updated.chordProgressionId, isNull); // cleared
        },
      );

      test(
        "should handle mode switching: clear arpeggio fields when leaving arpeggios mode",
        () {
          final original = ExerciseConfiguration(
            practiceMode: PracticeMode.arpeggios,
            handSelection: HandSelection.both,
            musicalNote: MusicalNote.c,
            arpeggioType: ArpeggioType.major,
            arpeggioOctaves: ArpeggioOctaves.two,
          );

          final updated = original.copyWith(
            practiceMode: PracticeMode.chordsByType,
            musicalNote: const Field.set(null),
            arpeggioType: const Field.set(null),
            chordType: const Field.set(ChordType.major),
          );

          expect(updated.practiceMode, equals(PracticeMode.chordsByType));
          expect(updated.musicalNote, isNull);
          expect(updated.arpeggioType, isNull);
          expect(updated.chordType, equals(ChordType.major));
          expect(
            updated.arpeggioOctaves,
            equals(ArpeggioOctaves.two),
          ); // preserved
        },
      );

      test("should update boolean flags correctly", () {
        final original = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
          chordType: ChordType.major,
        );

        final updated = original.copyWith(
          includeInversions: true,
          includeSeventhChords: true,
        );

        expect(updated.includeInversions, equals(true));
        expect(updated.includeSeventhChords, equals(true));
      });
    });
  });
}
