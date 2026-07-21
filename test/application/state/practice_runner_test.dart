import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/state/practice_runner.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";

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
        onExerciseCompleted: (accuracy, correct, errors) {
          reportedAccuracy = accuracy;
          reportedCorrect = correct;
          reportedErrors = errors;
        },
        onHighlightedNotesChanged: (notes) {
          highlightedNotes = notes;
        },
      );
    });

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
        runner.handleNotePressed(60); // Correct note for step 1
        expect(runner.practiceActive, isTrue);

        expect(runner.currentStepIndex, equals(1));
        expect(highlightedNotes, equals([62]));

        runner.handleNotePressed(65); // Wrong note for step 2
        expect(runner.wrongHeldNotes, contains(65));
        expect(runner.correctHeldNotes, isEmpty);
      },
    );

    test("handleNoteReleased when inactive does not crash", () {
      runner.handleNoteReleased(60);
      expect(runner.practiceActive, isFalse);
    });

    test("completing all steps invokes onExerciseCompleted callback", () {
      runner.handleNotePressed(60); // Step 1
      runner.handleNotePressed(62); // Step 2

      expect(runner.currentStep, isNull);
      expect(runner.correctHeldNotes, isEmpty);
      expect(runner.wrongHeldNotes, isEmpty);
      expect(reportedCorrect, equals(2));
      expect(reportedErrors, equals(0));
      expect(reportedAccuracy, equals(100.0));
    });

    test("resetPractice resets state and highlights", () {
      runner.startPractice();
      runner.handleNotePressed(60);
      expect(runner.currentStepIndex, equals(1));

      runner.resetPractice();
      expect(runner.practiceActive, isFalse);
      expect(runner.currentStepIndex, equals(0));
      expect(highlightedNotes, equals([60]));
    });

    test("triggerCompletionForTesting runs completion callback", () {
      runner.triggerCompletionForTesting();
      expect(runner.practiceActive, isFalse);
    });
  });
}
