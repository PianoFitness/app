import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_strategies/chords_by_key_strategy.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("ChordsByKeyStrategy", () {
    test("should initialize C major chord progression", () {
      final strategy = ChordsByKeyStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByKey");
      expect(exercise.metadata?["key"], "C");
      expect(exercise.metadata?["scaleType"], "major");
      expect(exercise.metadata?["handSelection"], "both");
      // C major has 7 triads, each with 4 positions (root, 1st, 2nd, 1st) = 28 total
      expect(exercise.steps.length, 28);
    });

    test("should initialize A minor chord progression", () {
      final strategy = ChordsByKeyStrategy(
        key: music.Key.a,
        scaleType: music.ScaleType.minor,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByKey");
      expect(exercise.metadata?["key"], "A");
      expect(exercise.metadata?["scaleType"], "minor");
      expect(exercise.metadata?["handSelection"], "right");
      // A minor has 7 triads, each with 4 positions = 28 total
      expect(exercise.steps.length, 28);
    });

    test("should generate different sequences for different keys", () {
      final cMajorStrategy = ChordsByKeyStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final gMajorStrategy = ChordsByKeyStrategy(
        key: music.Key.g,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final cExercise = cMajorStrategy.initializeExercise();
      final gExercise = gMajorStrategy.initializeExercise();

      expect(cExercise.steps, isNot(equals(gExercise.steps)));
    });

    test("should handle left hand selection correctly", () {
      final strategy = ChordsByKeyStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.left,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["handSelection"], "left");

      // Verify first chord (C major) has only 1 note (root/bass note)
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 1);
      expect(firstStep.notes.first, 60); // C4
    });

    test("should handle right hand selection correctly", () {
      final strategy = ChordsByKeyStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["handSelection"], "right");

      // Verify first chord (C major) has 2 notes (upper chord tones)
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 2);
      expect(firstStep.notes, containsAll([64, 67])); // E4 and G4
    });

    test("should handle both hands selection correctly", () {
      final strategy = ChordsByKeyStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
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
