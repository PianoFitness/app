import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/chord_progressions_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

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
      expect(
        exercise.steps.map((step) => step.noteValue),
        everyElement(PracticeStepNoteValue.whole),
      );
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

    test("generates every foundational progression in every supported key", () {
      const foundationalProgressions = <String, int>{
        "I - IV - V - I": 4,
        "I - V - vi - IV": 4,
        "I - vi - IV - V": 4,
        "ii - V - I": 3,
      };

      for (final entry in foundationalProgressions.entries) {
        final progression = ChordProgressionLibrary.getProgressionByName(
          entry.key,
        )!;
        for (final key in music.Key.values) {
          final exercise = ChordProgressionsStrategy(
            key: key,
            chordProgression: progression,
            handSelection: HandSelection.both,
            startOctave: 4,
          ).initializeExercise();

          expect(exercise.metadata?["key"], key.displayName);
          expect(exercise.metadata?["progressionName"], entry.key);
          expect(exercise.steps, hasLength(entry.value));
          for (final step in exercise.steps) {
            expect(step.notes, hasLength(4));
            expect(step.notes.first.hand, PracticeHand.left);
            expect(
              step.notes.skip(1).map((note) => note.hand),
              everyElement(PracticeHand.right),
            );
            expect(
              step.midiNotes,
              everyElement(inInclusiveRange(0, 127)),
              reason:
                  "${entry.key} in ${key.displayName} must produce valid MIDI notes",
            );
          }
        }
      }
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

      // The left hand establishes the root bass note one octave lower: C3.
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 1);
      expect(firstStep.midiNotes, [48]); // C3
      expect(
        firstStep.notes.map((note) => note.hand),
        everyElement(PracticeHand.left),
      );
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
      expect(firstStep.midiNotes, [60, 64, 67]); // C4, E4, G4
      expect(
        firstStep.notes.map((note) => note.hand),
        everyElement(PracticeHand.right),
      );
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

      // The left hand plays C3 while the right hand plays the C major triad.
      final firstStep = exercise.steps.first;
      expect(firstStep.notes.length, 4);
      expect(firstStep.midiNotes, [48, 60, 64, 67]);
      expect(firstStep.notes.take(1).map((note) => note.hand), [
        PracticeHand.left,
      ]);
      expect(firstStep.notes.skip(1).map((note) => note.hand), [
        PracticeHand.right,
        PracticeHand.right,
        PracticeHand.right,
      ]);
    });
  });
}
