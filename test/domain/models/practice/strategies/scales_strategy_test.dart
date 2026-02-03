import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/scales_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

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

    test("should generate correct MIDI notes for C major scale (right hand)", () {
      final strategy = ScalesStrategy(
        key: music.Key.c,
        scaleType: music.ScaleType.major,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      // C major scale in octave 4: C(60), D(62), E(64), F(65), G(67), A(69), B(71), C(72)
      // Full sequence goes up and back down (excluding duplicate top note)
      final expectedNotes = [
        60,
        62,
        64,
        65,
        67,
        69,
        71,
        72,
        71,
        69,
        67,
        65,
        64,
        62,
        60,
      ];

      expect(exercise.steps.length, equals(expectedNotes.length));

      for (var i = 0; i < exercise.steps.length; i++) {
        expect(
          exercise.steps[i].notes,
          equals([expectedNotes[i]]),
          reason: "Step $i should contain MIDI note ${expectedNotes[i]}",
        );
        expect(exercise.steps[i].type, equals(StepType.sequential));
        expect(exercise.steps[i].metadata?["hand"], equals("right"));
      }
    });

    test(
      "should generate correct MIDI notes for G major scale (left hand)",
      () {
        final strategy = ScalesStrategy(
          key: music.Key.g,
          scaleType: music.ScaleType.major,
          handSelection: HandSelection.left,
          startOctave: 4,
        );

        final exercise = strategy.initializeExercise();

        // G major scale in octave 3 (left hand plays octave lower):
        // G(55), A(57), B(59), C(60), D(62), E(64), F#(66), G(67)
        // Full sequence goes up and back down
        final expectedNotes = [
          55,
          57,
          59,
          60,
          62,
          64,
          66,
          67,
          66,
          64,
          62,
          60,
          59,
          57,
          55,
        ];

        expect(exercise.steps.length, equals(expectedNotes.length));

        for (var i = 0; i < exercise.steps.length; i++) {
          expect(
            exercise.steps[i].notes,
            equals([expectedNotes[i]]),
            reason: "Step $i should contain MIDI note ${expectedNotes[i]}",
          );
          expect(exercise.steps[i].type, equals(StepType.sequential));
          expect(exercise.steps[i].metadata?["hand"], equals("left"));
        }
      },
    );

    test(
      "should generate correct MIDI note pairs for C major scale (both hands)",
      () {
        final strategy = ScalesStrategy(
          key: music.Key.c,
          scaleType: music.ScaleType.major,
          handSelection: HandSelection.both,
          startOctave: 4,
        );

        final exercise = strategy.initializeExercise();

        // Both hands: Left hand in octave 3, right hand in octave 4
        // Each step contains [left note, right note] for simultaneous play
        final expectedPairs = [
          [48, 60], // C3, C4
          [50, 62], // D3, D4
          [52, 64], // E3, E4
          [53, 65], // F3, F4
          [55, 67], // G3, G4
          [57, 69], // A3, A4
          [59, 71], // B3, B4
          [60, 72], // C4, C5
          [59, 71], // B3, B4 (descending)
          [57, 69], // A3, A4
          [55, 67], // G3, G4
          [53, 65], // F3, F4
          [52, 64], // E3, E4
          [50, 62], // D3, D4
          [48, 60], // C3, C4 (end)
        ];

        expect(exercise.steps.length, equals(expectedPairs.length));

        for (var i = 0; i < exercise.steps.length; i++) {
          expect(
            exercise.steps[i].notes,
            equals(expectedPairs[i]),
            reason: "Step $i should contain paired notes ${expectedPairs[i]}",
          );
          expect(exercise.steps[i].type, equals(StepType.paired));
          expect(exercise.steps[i].metadata?["hand"], equals("both"));
        }
      },
    );

    test("should generate correct MIDI notes for D minor scale (right hand)", () {
      final strategy = ScalesStrategy(
        key: music.Key.d,
        scaleType: music.ScaleType.minor,
        handSelection: HandSelection.right,
        startOctave: 4,
      );

      final exercise = strategy.initializeExercise();

      // D natural minor scale in octave 4: D(62), E(64), F(65), G(67), A(69), Bb(70), C(72), D(74)
      // Full sequence goes up and back down
      final expectedNotes = [
        62,
        64,
        65,
        67,
        69,
        70,
        72,
        74,
        72,
        70,
        69,
        67,
        65,
        64,
        62,
      ];

      expect(exercise.steps.length, equals(expectedNotes.length));

      for (var i = 0; i < exercise.steps.length; i++) {
        expect(
          exercise.steps[i].notes,
          equals([expectedNotes[i]]),
          reason: "Step $i should contain MIDI note ${expectedNotes[i]}",
        );
      }
    });

    test(
      "should generate correct MIDI notes for F# major scale (right hand)",
      () {
        final strategy = ScalesStrategy(
          key: music.Key.fSharp,
          scaleType: music.ScaleType.major,
          handSelection: HandSelection.right,
          startOctave: 4,
        );

        final exercise = strategy.initializeExercise();

        // F# major scale in octave 4: F#(66), G#(68), A#(70), B(71), C#(73), D#(75), E#(77), F#(78)
        // Full sequence goes up and back down
        final expectedNotes = [
          66,
          68,
          70,
          71,
          73,
          75,
          77,
          78,
          77,
          75,
          73,
          71,
          70,
          68,
          66,
        ];

        expect(exercise.steps.length, equals(expectedNotes.length));

        for (var i = 0; i < exercise.steps.length; i++) {
          expect(
            exercise.steps[i].notes,
            equals([expectedNotes[i]]),
            reason: "Step $i should contain MIDI note ${expectedNotes[i]}",
          );
        }
      },
    );
  });
}
