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
