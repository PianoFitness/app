import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_strategies/scales_strategy.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("ScalesStrategy", () {
    test("should initialize C major scale sequence for both hands", () {
      final strategy = ScalesStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "scale");
      expect(exercise.metadata?["key"], "C");
      expect(exercise.metadata?["scaleType"], "major");
      expect(exercise.metadata?["handSelection"], "both");
    });

    test("should initialize D minor scale sequence for left hand only", () {
      final strategy = ScalesStrategy(
        key: music.Key.d,
        scaleType: music.ScaleType.minor,
        handSelection: HandSelection.left,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "scale");
      expect(exercise.metadata?["key"], "D");
      expect(exercise.metadata?["scaleType"], "minor");
      expect(exercise.metadata?["handSelection"], "left");
    });

    test("should initialize G dorian scale sequence for right hand only", () {
      final strategy = ScalesStrategy(
        key: music.Key.g,
        scaleType: music.ScaleType.dorian,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "scale");
      expect(exercise.metadata?["key"], "G");
      expect(exercise.metadata?["scaleType"], "dorian");
      expect(exercise.metadata?["handSelection"], "right");
    });

    test("should generate different sequences for different keys", () {
      final cMajorStrategy = ScalesStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final gMajorStrategy = ScalesStrategy(
        key: music.Key.g,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final cExercise = cMajorStrategy.initializeExercise();
      final gExercise = gMajorStrategy.initializeExercise();

      expect(cExercise.steps, isNot(equals(gExercise.steps)));
    });
  });
}
