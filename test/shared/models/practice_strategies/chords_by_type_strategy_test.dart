import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/practice_strategies/chords_by_type_strategy.dart";
import "package:piano_fitness/shared/utils/chords.dart";

void main() {
  group("ChordsByTypeStrategy", () {
    test("should initialize major chord type exercise without inversions", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.major,
        includeInversions: false,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "major");
      expect(strategy.exercise, isNotNull);
      // 12 keys without inversions
      expect(exercise.steps.length, 12);
    });

    test("should initialize minor chord type exercise with inversions", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.minor,
        includeInversions: true,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "minor");
      expect(strategy.exercise, isNotNull);
      // 12 keys * 3 inversions = 36 chords
      expect(exercise.steps.length, 36);
    });

    test("should initialize diminished chord type exercise", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.diminished,
        includeInversions: false,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "diminished");
      expect(exercise.steps.length, 12);
    });

    test("should initialize augmented chord type exercise", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.augmented,
        includeInversions: false,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "augmented");
      expect(exercise.steps.length, 12);
    });

    test("should populate exercise property after initialization", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.major,
        includeInversions: false,
        startOctave: 4,
      );

      expect(strategy.exercise, isNull);

      strategy.initializeExercise();

      expect(strategy.exercise, isNotNull);
      expect(strategy.exercise!.type, ChordType.major);
    });
  });
}
