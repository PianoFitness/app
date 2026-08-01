import "package:piano_fitness/application/state/exercise_tempo_tracker.dart";
import "package:flutter/foundation.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/exercise_completion_result.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";

/// Manages the real-time execution state of a practice exercise.
///
/// This state machine processes MIDI inputs, tracks accuracy, and advances
/// through the steps of a [PracticeExercise].
class PracticeRunner {
  PracticeRunner({
    required this.exercise,
    required this.onExerciseCompleted,
    required this.onHighlightedNotesChanged,
  });

  /// The exercise being run.
  final PracticeExercise exercise;

  /// Callback fired when a practice exercise is completed successfully.
  final void Function(ExerciseCompletionResult result) onExerciseCompleted;

  /// Callback fired when the highlighted notes on the piano should change.
  final void Function(List<int>) onHighlightedNotesChanged;

  int _currentStepIndex = 0;
  bool _practiceActive = false;
  final Set<int> _currentlyHeldNotes = {};

  int _correctNoteCount = 0;
  int _errorCount = 0;
  final ExerciseTempoTracker _tempoTracker = ExerciseTempoTracker();
  int? _tempoOnsetStepIndex;

  /// Whether the practice session is actively running.
  bool get practiceActive => _practiceActive;

  /// The index of the current step in the exercise.
  int get currentStepIndex => _currentStepIndex;

  /// The step currently being practiced.
  PracticeStep? get currentStep {
    if (_currentStepIndex >= exercise.steps.length) {
      return null;
    }
    return exercise.steps[_currentStepIndex];
  }

  /// The currently held notes that are expected for the current step.
  Set<int> get correctHeldNotes {
    final step = currentStep;
    if (step == null) return {};
    return _currentlyHeldNotes.intersection(step.expectedMidiNotes);
  }

  /// The currently held notes that are NOT expected for the current step.
  Set<int> get wrongHeldNotes {
    final step = currentStep;
    if (step == null) return {};
    return _currentlyHeldNotes.difference(step.expectedMidiNotes);
  }

  /// Starts or restarts the practice session.
  void startPractice() {
    _practiceActive = true;
    _currentStepIndex = 0;
    _currentlyHeldNotes.clear();
    _correctNoteCount = 0;
    _errorCount = 0;
    _tempoTracker.reset();
    _tempoOnsetStepIndex = null;
    _updateHighlightedNotes();
  }

  /// Stops the active session and resets all progress indicators.
  void resetPractice() {
    _practiceActive = false;
    _currentStepIndex = 0;
    _currentlyHeldNotes.clear();
    _correctNoteCount = 0;
    _errorCount = 0;
    _tempoTracker.reset();
    _tempoOnsetStepIndex = null;
    _updateHighlightedNotes();
  }

  /// Handles MIDI note press events during practice sessions.
  void handleNotePressed(
    int midiNote, {
    required Duration occurredAt,
    required ExerciseInputSource inputSource,
  }) {
    if (!_practiceActive) {
      startPractice();
    }

    if (_currentStepIndex >= exercise.steps.length) return;

    _tempoTracker.recordInputSource(inputSource);
    _currentlyHeldNotes.add(midiNote);

    final step = exercise.steps[_currentStepIndex];
    if (step.expectedMidiNotes.contains(midiNote)) {
      if (_tempoOnsetStepIndex != _currentStepIndex) {
        _tempoTracker.recordStepOnset(
          stepIndex: _currentStepIndex,
          occurredAt: occurredAt,
          source: inputSource,
        );
        _tempoOnsetStepIndex = _currentStepIndex;
      }
      _correctNoteCount++;
    } else {
      _errorCount++;
    }
    _checkStepCompletion();
  }

  /// Handles MIDI note release events during practice.
  void handleNoteReleased(int midiNote) {
    if (_practiceActive) {
      _currentlyHeldNotes.remove(midiNote);
      _checkStepCompletion();
    }
  }

  void _checkStepCompletion() {
    if (_currentStepIndex >= exercise.steps.length) return;

    final step = exercise.steps[_currentStepIndex];

    if (setEquals(_currentlyHeldNotes, step.expectedMidiNotes)) {
      _currentlyHeldNotes.clear();
      _advanceToNextStep();
    }
  }

  void _advanceToNextStep() {
    _currentStepIndex++;

    if (_currentStepIndex >= exercise.steps.length) {
      _completeExercise();
    } else {
      _updateHighlightedNotes();
    }
  }

  void _completeExercise() {
    _practiceActive = false;

    double? accuracyPercentage;
    final totalNotes = _correctNoteCount + _errorCount;
    if (totalNotes > 0) {
      accuracyPercentage = (_correctNoteCount / totalNotes) * 100;
    }

    ExerciseTempoResult tempo;
    try {
      tempo = _tempoTracker.complete(noteValue: exercise.uniformTempoNoteValue);
    } catch (_) {
      tempo = const ExerciseTempoResult(
        quality: TempoMeasurementQuality.unavailable,
        intervalCount: 0,
      );
    }

    onExerciseCompleted(
      ExerciseCompletionResult(
        accuracyPercentage: accuracyPercentage,
        correctNoteCount: _correctNoteCount,
        errorCount: _errorCount,
        tempo: tempo,
      ),
    );
  }

  void _updateHighlightedNotes() {
    if (_currentStepIndex >= exercise.steps.length) {
      onHighlightedNotesChanged([]);
      return;
    }

    final currentStep = exercise.steps[_currentStepIndex];
    onHighlightedNotesChanged(List<int>.from(currentStep.midiNotes));
  }

  /// For testing
  @visibleForTesting
  void triggerCompletionForTesting() {
    _completeExercise();
  }
}
