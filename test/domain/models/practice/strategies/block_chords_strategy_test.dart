import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/block_chords_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

void main() {
  group("BlockChordsStrategy", () {
    test("straight pattern: one blocked chord per octave, root position", () {
      final strategy = BlockChordsStrategy(
        rootNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.three,
        handSelection: HandSelection.right,
        startOctave: 3,
        pattern: ChordTonePattern.straight,
        includeLeftHandRoot: false,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.metadata?["exerciseType"], "blockChords");
      expect(exercise.metadata?["pattern"], "straight");
      expect(exercise.steps.length, 5); // 3 up, mirrored minus the top

      final chordPitches = exercise.steps
          .map((s) => s.notes.map((n) => n.pitch.value).toList())
          .toList();
      expect(chordPitches, [
        [48, 52, 55], // C3 E3 G3
        [60, 64, 67], // C4 E4 G4
        [72, 76, 79], // C5 E5 G5
        [60, 64, 67],
        [48, 52, 55],
      ]);

      for (final step in exercise.steps) {
        expect(step.notes.map((n) => n.fingerNumber).toList(), [1, 3, 5]);
        expect(step.notes.every((n) => n.hand == PracticeHand.right), isTrue);
      }
    });

    test("rolling pattern: rotates through inversions, blocked each step", () {
      final strategy = BlockChordsStrategy(
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
      final chordPitches = exercise.steps
          .map((s) => s.notes.map((n) => n.pitch.value).toList())
          .toList();
      expect(chordPitches, [
        [60, 64, 67], // root position: C4 E4 G4
        [64, 67, 72], // first inversion: E4 G4 C5
        [60, 64, 67],
      ]);

      for (final step in exercise.steps) {
        expect(step.notes.map((n) => n.fingerNumber).toList(), [1, 3, 5]);
      }
    });

    test("left-hand root tap: LH plays the root on every blocked step", () {
      final strategy = BlockChordsStrategy(
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
      for (final step in exercise.steps) {
        final leftNotes = step.notes.where((n) => n.hand == PracticeHand.left);
        final rightNotes = step.notes.where(
          (n) => n.hand == PracticeHand.right,
        );
        expect(leftNotes, hasLength(1));
        expect(leftNotes.single.pitch.value, 48); // C3
        expect(leftNotes.single.fingerNumber, 5);
        expect(rightNotes, hasLength(3));
      }
    });

    test("both hands: mirrors the same blocked chord one octave apart", () {
      final strategy = BlockChordsStrategy(
        rootNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.one,
        handSelection: HandSelection.both,
        startOctave: 4,
        pattern: ChordTonePattern.straight,
        includeLeftHandRoot: false,
      );

      final exercise = strategy.initializeExercise();

      for (final step in exercise.steps) {
        final left = step.notes
            .where((n) => n.hand == PracticeHand.left)
            .map((n) => n.pitch.value)
            .toList();
        final right = step.notes
            .where((n) => n.hand == PracticeHand.right)
            .map((n) => n.pitch.value)
            .toList();
        expect(left, hasLength(3));
        expect(right, hasLength(3));
        expect(left, equals(right.map((p) => p - 12).toList()));
      }
    });

    test("supports seventh chords (4-note blocked voicings)", () {
      final strategy = BlockChordsStrategy(
        rootNote: MusicalNote.c,
        arpeggioType: ArpeggioType.dominant7,
        arpeggioOctaves: ArpeggioOctaves.one,
        handSelection: HandSelection.right,
        startOctave: 4,
        pattern: ChordTonePattern.straight,
        includeLeftHandRoot: false,
      );

      final exercise = strategy.initializeExercise();
      for (final step in exercise.steps) {
        expect(step.notes, hasLength(4));
        expect(step.notes.map((n) => n.fingerNumber).toList(), [1, 2, 3, 5]);
      }
    });

    test("supports three and four octave block chord patterns", () {
      for (final octaves in [ArpeggioOctaves.three, ArpeggioOctaves.four]) {
        for (final pattern in ChordTonePattern.values) {
          final strategy = BlockChordsStrategy(
            rootNote: MusicalNote.c,
            arpeggioType: ArpeggioType.major,
            arpeggioOctaves: octaves,
            handSelection: HandSelection.right,
            startOctave: 3,
            pattern: pattern,
            includeLeftHandRoot: false,
          );

          final exercise = strategy.initializeExercise();
          expect(exercise.steps, isNotEmpty);
          for (final step in exercise.steps) {
            for (final note in step.notes) {
              expect(note.pitch.value, inInclusiveRange(0, 127));
            }
          }
        }
      }
    });

    test("throws when startOctave is too low for both hands", () {
      final strategy = BlockChordsStrategy(
        rootNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.one,
        handSelection: HandSelection.both,
        startOctave: 0,
        pattern: ChordTonePattern.straight,
        includeLeftHandRoot: false,
      );

      expect(
        () => strategy.initializeExercise(),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
