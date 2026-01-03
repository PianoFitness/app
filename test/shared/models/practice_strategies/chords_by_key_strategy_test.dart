import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/practice_strategies/chords_by_key_strategy.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("ChordsByKeyStrategy", () {
    test("should initialize C major chord progression", () {
      final strategy = ChordsByKeyStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByKey");
      expect(exercise.metadata?["key"], "C");
      expect(exercise.metadata?["scaleType"], "major");
      // C major has 7 triads, each with 4 positions (root, 1st, 2nd, 1st) = 28 total
      expect(exercise.steps.length, 28);
    });

    test("should initialize A minor chord progression", () {
      final strategy = ChordsByKeyStrategy(
        key: music.Key.a,
        scaleType: music.ScaleType.minor,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByKey");
      expect(exercise.metadata?["key"], "A");
      expect(exercise.metadata?["scaleType"], "minor");
      // A minor has 7 triads, each with 4 positions = 28 total
      expect(exercise.steps.length, 28);
    });

    test("should generate different sequences for different keys", () {
      final cMajorStrategy = ChordsByKeyStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        startOctave: 4,
      );

      final gMajorStrategy = ChordsByKeyStrategy(
        key: music.Key.g,
        scaleType: music.ScaleType.major,
        startOctave: 4,
      );

      final cExercise = cMajorStrategy.initializeExercise();
      final gExercise = gMajorStrategy.initializeExercise();

      expect(cExercise.steps, isNot(equals(gExercise.steps)));
    });
  });
}
