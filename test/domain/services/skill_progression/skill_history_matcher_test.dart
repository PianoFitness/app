import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/skill_progression/default_skill_catalogue.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_history_matcher.dart";

void main() {
  ExerciseHistoryEntry entry({
    required String id,
    required DateTime completedAt,
    required ExerciseConfiguration configuration,
  }) => ExerciseHistoryEntry.fromConfiguration(
    id: id,
    profileId: "profile",
    completedAt: completedAt,
    config: configuration,
  );

  test("finds the newest history entry represented in the catalogue", () {
    final catalogue = DefaultSkillCatalogue.catalogue;
    final olderExercise = catalogue.nodes
        .firstWhere((node) => node.id == "major-scale")
        .checkpoints
        .first
        .exercises
        .first;
    final newerCheckpoint = catalogue.nodes
        .firstWhere((node) => node.id == "natural-minor")
        .checkpoints
        .last;
    final newerExercise = newerCheckpoint.exercises.last;

    final result = SkillHistoryMatcher.findMostRecentPractice([
      entry(
        id: "newer",
        completedAt: DateTime(2026, 8, 15),
        configuration: newerExercise.configuration,
      ),
      entry(
        id: "older",
        completedAt: DateTime(2026, 8, 14),
        configuration: olderExercise.configuration,
      ),
    ], catalogue);

    expect(result?.entry.id, "newer");
    expect(result?.node.id, "natural-minor");
    expect(result?.checkpoint.id, newerCheckpoint.id);
    expect(result?.exercise.id, newerExercise.id);
  });

  test("returns null when history is not represented in the catalogue", () {
    const uncatalogued = ExerciseConfiguration(
      practiceMode: PracticeMode.scales,
      handSelection: HandSelection.both,
      key: music.Key.c,
      scaleType: music.ScaleType.aeolian,
    );

    final result = SkillHistoryMatcher.findMostRecentPractice([
      entry(
        id: "uncatalogued",
        completedAt: DateTime(2026, 8, 15),
        configuration: uncatalogued,
      ),
    ], DefaultSkillCatalogue.catalogue);

    expect(result, isNull);
  });
}
