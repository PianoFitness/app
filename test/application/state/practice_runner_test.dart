import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/state/practice_runner.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/exercise_completion_result.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";

void main() {
  group("PracticeRunner Unit Tests", () {
    late PracticeExercise exercise;
    late PracticeRunner runner;

    double? reportedAccuracy;
    int? reportedCorrect;
    int? reportedErrors;
    List<int> highlightedNotes = [];

    setUp(() {
      reportedAccuracy = null;
      reportedCorrect = null;
      reportedErrors = null;
      highlightedNotes = [];

      final step1 = PracticeStep(
        notes: [PracticeNote(pitch: MidiNote(60), hand: PracticeHand.right)],
      );
      final step2 = PracticeStep(
        notes: [PracticeNote(pitch: MidiNote(62), hand: PracticeHand.right)],
      );

      exercise = PracticeExercise(steps: [step1, step2]);

      runner = PracticeRunner(
        exercise: exercise,
        onExerciseCompleted: (result) {
          reportedAccuracy = result.accuracyPercentage;
          reportedCorrect = result.correctNoteCount;
          reportedErrors = result.errorCount;
        },
        onHighlightedNotesChanged: (notes) {
          highlightedNotes = notes;
        },
      );
    });

    void press(int midiNote) {
      runner.handleNotePressed(
        midiNote,
        occurredAt: Duration.zero,
        inputSource: ExerciseInputSource.externalMidi,
      );
    }

    test("initial state is inactive with currentStep at 0", () {
      expect(runner.practiceActive, isFalse);
      expect(runner.currentStepIndex, equals(0));
      expect(runner.currentStep, equals(exercise.steps[0]));
      expect(runner.correctHeldNotes, isEmpty);
      expect(runner.wrongHeldNotes, isEmpty);
    });

    test(
      "handleNotePressed starts practice and tracks correct vs wrong notes",
      () {
        press(60); // Correct note for step 1
        expect(runner.practiceActive, isTrue);

        expect(runner.currentStepIndex, equals(1));
        expect(highlightedNotes, equals([62]));

        press(65); // Wrong note for step 2
        expect(runner.wrongHeldNotes, contains(65));
        expect(runner.correctHeldNotes, isEmpty);
      },
    );

    test("handleNoteReleased when inactive does not crash", () {
      runner.handleNoteReleased(60);
      expect(runner.practiceActive, isFalse);
    });

    test("completing all steps invokes onExerciseCompleted callback", () {
      press(60); // Step 1
      press(62); // Step 2

      expect(runner.currentStep, isNull);
      expect(runner.correctHeldNotes, isEmpty);
      expect(runner.wrongHeldNotes, isEmpty);
      expect(reportedCorrect, equals(2));
      expect(reportedErrors, equals(0));
      expect(reportedAccuracy, equals(100.0));
    });

    test("resetPractice resets state and highlights", () {
      runner.startPractice();
      press(60);
      expect(runner.currentStepIndex, equals(1));

      runner.resetPractice();
      expect(runner.practiceActive, isFalse);
      expect(runner.currentStepIndex, equals(0));
      expect(highlightedNotes, equals([60]));
    });

    test("triggerCompletionForTesting runs completion callback", () {
      runner.triggerCompletionForTesting();
      expect(runner.practiceActive, isFalse);
      // Verify observable results are reported correctly
      expect(reportedAccuracy, isNull);
      expect(reportedCorrect, equals(0));
      expect(reportedErrors, equals(0));
    });

    test("reports reliable external-MIDI tempo evidence on completion", () {
      ExerciseCompletionResult? completion;
      final tempoExercise = PracticeExercise(
        steps: List.generate(
          6,
          (index) => PracticeStep(
            notes: [
              PracticeNote(
                pitch: MidiNote(60 + index),
                hand: PracticeHand.right,
              ),
            ],
          ),
        ),
      );
      final tempoRunner = PracticeRunner(
        exercise: tempoExercise,
        onExerciseCompleted: (result) => completion = result,
        onHighlightedNotesChanged: (_) {},
      );

      for (var index = 0; index < 6; index++) {
        tempoRunner.handleNotePressed(
          60 + index,
          occurredAt: Duration(milliseconds: index * 400),
          inputSource: ExerciseInputSource.externalMidi,
        );
      }

      expect(completion, isNotNull);
      expect(completion!.tempo.quality, TempoMeasurementQuality.reliable);
      expect(completion!.tempo.measuredTempoBpm, closeTo(150, 0.000001));
      expect(completion!.tempo.intervalCount, 5);
    });

    test("completes mixed-duration exercises without tempo evidence", () {
      ExerciseCompletionResult? completion;
      final mixedExercise = PracticeExercise(
        steps: List.generate(
          6,
          (index) => PracticeStep(
            notes: [
              PracticeNote(
                pitch: MidiNote(60 + index),
                hand: PracticeHand.right,
              ),
            ],
            noteValue: index.isEven
                ? PracticeStepNoteValue.quarter
                : PracticeStepNoteValue.eighth,
          ),
        ),
      );
      final mixedRunner = PracticeRunner(
        exercise: mixedExercise,
        onExerciseCompleted: (result) => completion = result,
        onHighlightedNotesChanged: (_) {},
      );

      for (var index = 0; index < 6; index++) {
        mixedRunner.handleNotePressed(
          60 + index,
          occurredAt: Duration(milliseconds: index * 400),
          inputSource: ExerciseInputSource.externalMidi,
        );
      }

      expect(completion!.accuracyPercentage, 100);
      expect(completion!.tempo.quality, TempoMeasurementQuality.unavailable);
      expect(completion!.tempo.measuredTempoBpm, isNull);
    });
  });
}
