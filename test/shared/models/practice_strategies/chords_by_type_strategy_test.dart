import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/strategies/chords_by_type_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";

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

      // Verify first chord (C major) has full triad (3 notes) in left hand octave
      // Left hand plays one octave lower: C3, E3, G3
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 3);
      expect(firstStep.notes, containsAll([48, 52, 55])); // C3, E3, G3
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

      // Verify first chord (C major) has full triad (3 notes) in right hand octave
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 3);
      expect(firstStep.notes, containsAll([60, 64, 67])); // C4, E4, G4
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
