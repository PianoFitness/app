import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";

/// The performance evidence produced by one completed exercise attempt.
@immutable
class ExerciseCompletionResult {
  const ExerciseCompletionResult({
    required this.accuracyPercentage,
    required this.correctNoteCount,
    required this.errorCount,
    required this.tempo,
  });

  final double? accuracyPercentage;
  final int correctNoteCount;
  final int errorCount;
  final ExerciseTempoResult tempo;
}
