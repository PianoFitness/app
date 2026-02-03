import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
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
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "arpeggio");
      expect(exercise.metadata?["rootNote"], "c");
      expect(exercise.metadata?["arpeggioType"], "major");
      expect(exercise.metadata?["handSelection"], "both");
    });

    test("should initialize D minor arpeggio sequence for left hand", () {
      final strategy = ArpeggiosStrategy(
        rootNote: MusicalNote.d,
        arpeggioType: ArpeggioType.minor,
        arpeggioOctaves: ArpeggioOctaves.one,
        handSelection: HandSelection.left,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      expect(exercise.steps, isNotEmpty);
      expect(exercise.metadata?["exerciseType"], "arpeggio");
      expect(exercise.metadata?["rootNote"], "d");
      expect(exercise.metadata?["arpeggioType"], "minor");
      expect(exercise.metadata?["handSelection"], "left");
    });

    test("should initialize two-octave arpeggio sequence", () {
      final strategy = ArpeggiosStrategy(
        rootNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.two,
        handSelection: HandSelection.both,
        startOctave: 4,
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
        );

        final minorStrategy = ArpeggiosStrategy(
          rootNote: MusicalNote.c,
          arpeggioType: ArpeggioType.minor,
          arpeggioOctaves: ArpeggioOctaves.one,
          handSelection: HandSelection.both,
          startOctave: 4,
        );

        final majorExercise = majorStrategy.initializeExercise();
        final minorExercise = minorStrategy.initializeExercise();

        expect(majorExercise.steps, isNot(equals(minorExercise.steps)));
      },
    );
  });
}
