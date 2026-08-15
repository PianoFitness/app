import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/broken_chord_pattern.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/broken_chord_accompaniment_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

void main() {
  final progression = ChordProgressionLibrary.getProgressionByName(
    "I - IV - V - I",
  )!;

  group("BrokenChordAccompanimentStrategy", () {
    test("generates a 1-5-3-5 accompaniment with an initial harmony cue", () {
      final exercise = BrokenChordAccompanimentStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.both,
        startOctave: 4,
        pattern: BrokenChordPattern.rootFifthThirdFifth,
      ).initializeExercise();

      expect(exercise.metadata?["exerciseType"], "brokenChordAccompaniment");
      expect(exercise.metadata?["progressionName"], "I - IV - V - I");
      expect(exercise.metadata?["pattern"], "rootFifthThirdFifth");
      expect(exercise.steps, hasLength(16));
      expect(
        exercise.steps.map((step) => step.noteValue),
        everyElement(PracticeStepNoteValue.quarter),
      );

      expect(exercise.steps[0].midiNotes, [48, 60, 64, 67]); // C3 + C major
      expect(exercise.steps[1].midiNotes, [55]); // G3
      expect(exercise.steps[2].midiNotes, [52]); // E3
      expect(exercise.steps[3].midiNotes, [55]); // G3
      expect(exercise.steps[0].metadata?["romanNumeral"], "I");
      expect(exercise.steps[0].metadata?["beatInChord"], 1);
    });

    test("supports left-hand pattern practice without right-hand cues", () {
      final exercise = BrokenChordAccompanimentStrategy(
        key: music.Key.c,
        chordProgression: progression,
        handSelection: HandSelection.left,
        startOctave: 4,
        pattern: BrokenChordPattern.rootThirdFifthThird,
      ).initializeExercise();

      expect(exercise.steps.take(4).map((step) => step.midiNotes), [
        [48], // C3
        [52], // E3
        [55], // G3
        [52], // E3
      ]);
      expect(
        exercise.steps.expand((step) => step.notes).map((note) => note.hand),
        everyElement(PracticeHand.left),
      );
    });

    test("uses a fallback label when roman numerals are incomplete", () {
      const incompleteProgression = ChordProgression(
        name: "Incomplete labels",
        romanNumerals: ["I"],
        chords: [
          [0, 4, 7],
          [5, 9, 12],
        ],
        difficulty: ProgressionDifficulty.beginner,
      );
      final exercise = BrokenChordAccompanimentStrategy(
        key: music.Key.c,
        chordProgression: incompleteProgression,
        handSelection: HandSelection.left,
        startOctave: 4,
        pattern: BrokenChordPattern.rootFifthThirdFifth,
      ).initializeExercise();

      expect(exercise.steps[4].metadata?["romanNumeral"], "?");
      expect(exercise.steps[4].metadata?["displayName"], "? · beat 1");
    });

    test(
      "stays in range through the foundational progression in every key",
      () {
        for (final key in music.Key.values) {
          final exercise = BrokenChordAccompanimentStrategy(
            key: key,
            chordProgression: progression,
            handSelection: HandSelection.both,
            startOctave: 4,
            pattern: BrokenChordPattern.rootFifthThirdFifth,
          ).initializeExercise();

          expect(exercise.steps, hasLength(16));
          for (final step in exercise.steps) {
            expect(step.midiNotes, everyElement(inInclusiveRange(0, 127)));
          }
        }
      },
    );
  });
}
