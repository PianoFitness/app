import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";

/// Strategy interface for initializing practice exercises.
///
/// Each practice mode (scales, arpeggios, chords, etc.) implements this
/// interface to provide its own exercise initialization logic. This follows
/// the Strategy pattern to eliminate conditional logic in PracticeSession.
///
/// All strategies return a unified [PracticeExercise] representation,
/// making the exercise data serializable and mode-agnostic.
abstract class PracticeStrategy {
  /// Initializes and returns the practice exercise for this strategy.
  ///
  /// This method generates a [PracticeExercise] with all the steps
  /// needed for the specific practice mode. The exercise structure
  /// is unified across all modes, containing steps with notes and metadata.
  PracticeExercise initializeExercise();
}

/// Helper to validate that [startOctave] is sufficient when left hand is active.
void validateLeftHandStartOctave(
  int startOctave, {
  required HandSelection handSelection,
  bool includeLeftHandRoot = false,
}) {
  if ((handSelection == HandSelection.both ||
          handSelection == HandSelection.left ||
          includeLeftHandRoot) &&
      startOctave < 1) {
    throw ArgumentError(
      "startOctave must be >= 1 for both hands, left hand, or left-hand "
      "root taps (left hand plays at startOctave - 1), got: $startOctave",
    );
  }
}
