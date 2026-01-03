import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/practice_strategies/chord_progressions_strategy.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("ChordProgressionsStrategy", () {
    test("should initialize I-V-vi-IV progression in C major", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V - vi - IV",
      );

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordProgressions");
      expect(exercise.metadata?["key"], "C");
      expect(exercise.steps.length, 4);
    });

    test("should initialize I-V progression when progression is provided", () {
      final progression = ChordProgressionLibrary.getProgressionByName("I - V");

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordProgressions");
      expect(exercise.steps.length, 2);
    });

    test("should default to I-V when no progression provided", () {
      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: null,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordProgressions");
      expect(exercise.steps.length, 2);
      expect(strategy.chordProgression, isNotNull);
      expect(strategy.chordProgression!.name, "I - V");
    });

    test("should generate different sequences for different keys", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V - vi - IV",
      );

      final cMajorStrategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        startOctave: 4,
      );

      final gMajorStrategy = ChordProgressionsStrategy(
        key: music.Key.g,
        chordProgression: progression,
        startOctave: 4,
      );

      final cExercise = cMajorStrategy.initializeExercise();
      final gExercise = gMajorStrategy.initializeExercise();

      expect(cExercise.steps, isNot(equals(gExercise.steps)));
    });

    test("should handle all available progressions", () {
      final allProgressions = ChordProgressionLibrary.progressions;

      for (final progression in allProgressions) {
        final strategy = ChordProgressionsStrategy(
          key: music.Key.c,
          chordProgression: progression,
          startOctave: 4,
        );

        final exercise = strategy.initializeExercise();

        expect(
          exercise.steps,
          isNotEmpty,
          reason: "Progression ${progression.name} should generate steps",
        );
      }
    });
  });
}
