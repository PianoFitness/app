import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/services/skill_progression/exercise_configuration_identity.dart";

/// A history entry matched to its owning curriculum location.
class SkillHistoryMatch {
  const SkillHistoryMatch({
    required this.node,
    required this.checkpoint,
    required this.exercise,
    required this.entry,
  });

  final SkillNode node;
  final SkillCheckpoint checkpoint;
  final SkillExercise exercise;
  final ExerciseHistoryEntry entry;
}

/// Matches persisted attempts to catalogue exercises using completed settings.
class SkillHistoryMatcher {
  const SkillHistoryMatcher._();

  static List<ExerciseHistoryEntry> entriesForExercise(
    Iterable<ExerciseHistoryEntry> entries,
    SkillExercise exercise,
  ) {
    final identity = ExerciseConfigurationIdentity.fromConfiguration(
      exercise.configuration,
    );
    return entries
        .where(
          (entry) =>
              ExerciseConfigurationIdentity.fromHistory(entry) == identity,
        )
        .toList(growable: false);
  }

  /// Returns the newest history entry represented in [catalogue].
  static SkillHistoryMatch? findMostRecentPractice(
    Iterable<ExerciseHistoryEntry> entries,
    SkillCatalogue catalogue,
  ) {
    final orderedEntries = entries.toList(growable: false)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    for (final entry in orderedEntries) {
      final entryIdentity = ExerciseConfigurationIdentity.fromHistory(entry);
      for (final node in catalogue.nodes) {
        for (final checkpoint in node.checkpoints) {
          for (final exercise in checkpoint.exercises) {
            if (ExerciseConfigurationIdentity.fromConfiguration(
                  exercise.configuration,
                ) ==
                entryIdentity) {
              return SkillHistoryMatch(
                node: node,
                checkpoint: checkpoint,
                exercise: exercise,
                entry: entry,
              );
            }
          }
        }
      }
    }
    return null;
  }
}
