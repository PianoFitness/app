import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_strategies/chords_by_type_strategy.dart";
import "package:piano_fitness/shared/utils/chords.dart";

void main() {
  group("ChordsByTypeStrategy", () {
    test("should initialize major chord type exercise without inversions", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.major,
        includeInversions: false,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "major");
      expect(exercise.metadata?["handSelection"], "both");
      expect(strategy.exercise, isNotNull);
      // 12 keys without inversions
      expect(exercise.steps.length, 12);
    });

    test("should initialize minor chord type exercise with inversions", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.minor,
        includeInversions: true,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "minor");
      expect(exercise.metadata?["handSelection"], "right");
      expect(strategy.exercise, isNotNull);
      // 12 keys * 3 inversions = 36 chords
      expect(exercise.steps.length, 36);
    });

    test("should initialize diminished chord type exercise", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.diminished,
        includeInversions: false,
        handSelection: HandSelection.left,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "diminished");
      expect(exercise.metadata?["handSelection"], "left");
      expect(exercise.steps.length, 12);
    });

    test("should initialize augmented chord type exercise", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.augmented,
        includeInversions: false,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "chordsByType");
      expect(exercise.metadata?["chordType"], "augmented");
      expect(exercise.metadata?["handSelection"], "both");
      expect(exercise.steps.length, 12);
    });

    test("should populate exercise property after initialization", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.major,
        includeInversions: false,
        handSelection: HandSelection.both,
        startOctave: 4,
      );

      expect(strategy.exercise, isNull);

      strategy.initializeExercise();

      expect(strategy.exercise, isNotNull);
      expect(strategy.exercise!.type, ChordType.major);
    });

    test("should handle left hand selection correctly", () {
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.major,
        includeInversions: false,
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
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.major,
        includeInversions: false,
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
      final strategy = ChordsByTypeStrategy(
        chordType: ChordType.major,
        includeInversions: false,
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
