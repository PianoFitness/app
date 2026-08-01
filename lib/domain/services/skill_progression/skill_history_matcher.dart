import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/services/skill_progression/exercise_configuration_identity.dart";

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
}
