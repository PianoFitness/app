import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/arpeggios_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

void main() {
  group("ArpeggiosStrategy", () {
    test("should initialize C major arpeggio sequence for both hands", () {
      final strategy = ArpeggiosStrategy(
        rootNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.one,
        handSelection: HandSelection.both,
        startOctave: 4,
        pattern: ChordTonePattern.straight,
        includeLeftHandRoot: false,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "arpeggio");
      expect(exercise.metadata?["rootNote"], "c");
      expect(exercise.metadata?["arpeggioType"], "major");
      expect(exercise.metadata?["handSelection"], "both");
      expect(exercise.steps.first.midiNotes, [48, 60]);
      expect(exercise.steps.first.notes.map((note) => note.hand), [
        PracticeHand.left,
        PracticeHand.right,
      ]);
      expect(exercise.steps.first.notes.map((note) => note.fingerNumber), [
        5,
        1,
      ]);
    });

    test("should initialize D minor arpeggio sequence for left hand", () {
      final strategy = ArpeggiosStrategy(
        rootNote: MusicalNote.d,
        arpeggioType: ArpeggioType.minor,
        arpeggioOctaves: ArpeggioOctaves.one,
        handSelection: HandSelection.left,
        startOctave: 4,
        pattern: ChordTonePattern.straight,
        includeLeftHandRoot: false,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "arpeggio");
      expect(exercise.metadata?["rootNote"], "d");
      expect(exercise.metadata?["arpeggioType"], "minor");
      expect(exercise.metadata?["handSelection"], "left");
      expect(
        exercise.steps.expand((step) => step.notes).map((note) => note.hand),
        everyElement(PracticeHand.left),
      );
    });

    test("should initialize two-octave arpeggio sequence", () {
      final strategy = ArpeggiosStrategy(
        rootNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.two,
        handSelection: HandSelection.both,
        startOctave: 4,
        pattern: ChordTonePattern.straight,
        includeLeftHandRoot: false,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "arpeggio");
      expect(exercise.metadata?["octaves"], "two");
    });

    test(
      "should generate different sequences for different arpeggio types",
      () {
        final majorStrategy = ArpeggiosStrategy(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          arpeggioOctaves: ArpeggioOctaves.one,
          handSelection: HandSelection.both,
          startOctave: 4,
          pattern: ChordTonePattern.straight,
          includeLeftHandRoot: false,
        );

        final minorStrategy = ArpeggiosStrategy(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.minor,
          arpeggioOctaves: ArpeggioOctaves.one,
          handSelection: HandSelection.both,
          startOctave: 4,
          pattern: ChordTonePattern.straight,
          includeLeftHandRoot: false,
        );

        final majorExercise = majorStrategy.initializeExercise();
        final minorExercise = minorStrategy.initializeExercise();

        expect(majorExercise.steps, isNot(equals(minorExercise.steps)));
      },
    );

    test("should support three and four octave arpeggios (straight)", () {
      for (final octaves in [ArpeggioOctaves.three, ArpeggioOctaves.four]) {
        final strategy = ArpeggiosStrategy(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          arpeggioOctaves: octaves,
          handSelection: HandSelection.right,
          startOctave: 4,
          pattern: ChordTonePattern.straight,
          includeLeftHandRoot: false,
        );

        final exercise = strategy.initializeExercise();
        expect(exercise.steps, isNotEmpty);
        expect(exercise.metadata?["octaves"], octaves.name);
        expect(exercise.metadata?["pattern"], "straight");
      }
    });

    group("rolling pattern", () {
      test(
        "right hand only: rotates through chord-tone groups as it climbs",
        () {
          final strategy = ArpeggiosStrategy(
            rootNote: MusicalNote.c,
            arpeggioType: ArpeggioType.major,
            arpeggioOctaves: ArpeggioOctaves.one,
            handSelection: HandSelection.right,
            startOctave: 4,
            pattern: ChordTonePattern.rolling,
            includeLeftHandRoot: false,
          );

          final exercise = strategy.initializeExercise();

          expect(exercise.metadata?["pattern"], "rolling");
          expect(
            exercise.steps.map((s) => s.notes.single.pitch.value).toList(),
            [60, 64, 67, 64, 67, 72, 67, 64, 67, 64, 60],
          );
          expect(
            exercise.steps.map((s) => s.notes.single.fingerNumber).toList(),
            [1, 3, 5, 1, 3, 5, 3, 1, 5, 3, 1],
          );
          expect(
            exercise.steps.every((s) => s.notes.single.hand == PracticeHand.right),
            isTrue,
          );
        },
      );

      test(
        "left-hand root tap: LH plays only the chord root, once per group",
        () {
          final strategy = ArpeggiosStrategy(
            rootNote: MusicalNote.c,
            arpeggioType: ArpeggioType.major,
            arpeggioOctaves: ArpeggioOctaves.one,
            handSelection: HandSelection.right,
            startOctave: 4,
            pattern: ChordTonePattern.rolling,
            includeLeftHandRoot: true,
          );

          final exercise = strategy.initializeExercise();

          expect(exercise.metadata?["includeLeftHandRoot"], isTrue);
          expect(exercise.steps.length, 11);

          // Group boundaries: LH taps at steps 0, 3, 7, 10.
          const stepsWithLeftHand = {0, 3, 7, 10};
          for (var i = 0; i < exercise.steps.length; i++) {
            final leftNotes = exercise.steps[i].notes.where(
              (n) => n.hand == PracticeHand.left,
            );
            if (stepsWithLeftHand.contains(i)) {
              expect(leftNotes, hasLength(1), reason: "step $i");
              expect(leftNotes.single.pitch.value, 48, reason: "step $i"); // C3
              expect(leftNotes.single.fingerNumber, 5, reason: "step $i");
            } else {
              expect(leftNotes, isEmpty, reason: "step $i");
            }
          }

          // RH content is unaffected by the LH taps.
          expect(
            exercise.steps
                .map(
                  (s) => s.notes
                      .firstWhere((n) => n.hand == PracticeHand.right)
                      .pitch
                      .value,
                )
                .toList(),
            [60, 64, 67, 64, 67, 72, 67, 64, 67, 64, 60],
          );
        },
      );

      test("includeLeftHandRoot is a no-op outside right-hand-only", () {
        final bothHands = ArpeggiosStrategy(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          arpeggioOctaves: ArpeggioOctaves.one,
          handSelection: HandSelection.both,
          startOctave: 4,
          pattern: ChordTonePattern.rolling,
          includeLeftHandRoot: true,
        );

        final exercise = bothHands.initializeExercise();

        // "both" mode mirrors every note into both hands; no sparse taps.
        for (final step in exercise.steps) {
          expect(step.notes, hasLength(2));
          expect(
            step.notes.map((n) => n.hand),
            containsAll([PracticeHand.left, PracticeHand.right]),
          );
        }
      });

      test("both hands: mirrors the rolling pattern with an octave offset", () {
        final strategy = ArpeggiosStrategy(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          arpeggioOctaves: ArpeggioOctaves.one,
          handSelection: HandSelection.both,
          startOctave: 4,
          pattern: ChordTonePattern.rolling,
          includeLeftHandRoot: false,
        );

        final exercise = strategy.initializeExercise();

        for (final step in exercise.steps) {
          final left = step.notes.firstWhere((n) => n.hand == PracticeHand.left);
          final right = step.notes.firstWhere(
            (n) => n.hand == PracticeHand.right,
          );
          expect(left.pitch.value, right.pitch.value - 12);
        }
      });

      test("supports three and four octave rolling arpeggios", () {
        for (final octaves in [ArpeggioOctaves.three, ArpeggioOctaves.four]) {
          final strategy = ArpeggiosStrategy(
            rootNote: MusicalNote.c,
            arpeggioType: ArpeggioType.major,
            arpeggioOctaves: octaves,
            handSelection: HandSelection.right,
            startOctave: 4,
            pattern: ChordTonePattern.rolling,
            includeLeftHandRoot: false,
          );

          final exercise = strategy.initializeExercise();
          expect(exercise.steps, isNotEmpty);
          for (final step in exercise.steps) {
            expect(step.notes.single.pitch.value, inInclusiveRange(0, 127));
          }
        }
      });
    });
  });
}
