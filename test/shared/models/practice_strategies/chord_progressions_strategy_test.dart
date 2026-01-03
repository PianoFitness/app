import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_strategies/chord_progressions_strategy.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("ChordProgressionsStrategy", () {
    test("should initialize I-V-vi-IV progression in C major", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V - vi - IV",
      )!;

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordProgressions");
      expect(exercise.metadata?["key"], "C");
      expect(exercise.metadata?["handSelection"], "both");
      expect(exercise.steps.length, 4);
    });

    test("should initialize I-V progression when progression is provided", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V",
      )!;

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordProgressions");
      expect(exercise.metadata?["handSelection"], "right");
      expect(exercise.steps.length, 2);
    });

    test("should handle explicit I-V progression", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V",
      )!;

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.left,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordProgressions");
      expect(exercise.metadata?["handSelection"], "left");
      expect(exercise.steps.length, 2);
      expect(exercise.metadata?["progressionName"], "I - V");
    });

    test("should generate different sequences for different keys", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V - vi - IV",
      )!;

      final cMajorStrategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final gMajorStrategy = ChordProgressionsStrategy(
        key: music.Key.g,
        chordProgression: progression,
        handSelection: HandSelection.both,
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
          handSelection: HandSelection.both,
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

    test("should handle left hand selection correctly", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V",
      )!;

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.left,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["handSelection"], "left");

      // Verify first chord (C major) has full triad (3 notes) in left hand octave
      // Left hand plays one octave lower: C3, E3, G3
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 3);
      expect(firstStep.notes, containsAll([48, 52, 55])); // C3, E3, G3
    });

    test("should handle right hand selection correctly", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V",
      )!;

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["handSelection"], "right");

      // Verify first chord (C major) has full triad (3 notes) in right hand octave
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 3);
      expect(firstStep.notes, containsAll([60, 64, 67])); // C4, E4, G4
    });

    test("should handle both hands selection correctly", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V",
      )!;

      final strategy = ChordProgressionsStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["handSelection"], "both");

      // Verify first chord (C major) has 6 notes: left hand (C3,E3,G3) + right hand (C4,E4,G4)
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 6);
      // Left hand one octave lower: [48, 52, 55] = [C3, E3, G3]
      // Right hand at specified octave: [60, 64, 67] = [C4, E4, G4]
      expect(firstStep.notes, containsAll([48, 52, 55, 60, 64, 67]));
    });
  });
}
