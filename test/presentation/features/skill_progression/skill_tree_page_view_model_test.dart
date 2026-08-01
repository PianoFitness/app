import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/presentation/features/skill_progression/skill_tree_page_view_model.dart";

import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  const config = ExerciseConfiguration(
    practiceMode: PracticeMode.scales,
    handSelection: HandSelection.both,
    key: music.Key.c,
    scaleType: music.ScaleType.major,
  );
  final catalogue = SkillCatalogue(
    id: "test",
    version: 1,
    nodes: [
      SkillNode(
        id: "major-scale",
        name: "Major scale",
        description: "",
        proficiencyRule: const SkillProficiencyRule(
          tempoEvidencePolicy: TempoEvidencePolicy.optional,
        ),
        checkpoints: const [
          SkillCheckpoint(
            id: "c",
            name: "C",
            exercises: [
              SkillExercise(
                id: "c-major",
                name: "C major",
                configuration: config,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ExerciseHistoryEntry entry(String id) =>
      ExerciseHistoryEntry.fromConfiguration(
        id: id,
        profileId: "profile",
        completedAt: DateTime(2026, 8, int.parse(id.substring(1))),
        config: config,
        accuracyPercentage: 95,
      );

  test("recalculates coverage for reactive history updates", () async {
    final profiles = MockIUserProfileRepository();
    final history = MockIExerciseHistoryRepository();
    final controller = StreamController<List<ExerciseHistoryEntry>>();
    addTearDown(controller.close);
    when(profiles.getActiveProfileId()).thenAnswer((_) async => "profile");
    when(
      history.watchEntriesForProfile("profile"),
    ).thenAnswer((_) => controller.stream);

    final viewModel = SkillTreePageViewModel(
      userProfileRepository: profiles,
      exerciseHistoryRepository: history,
      catalogue: catalogue,
    );
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);

    controller.add([entry("e1"), entry("e2")]);
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.nodeProficiencies.single.establishedCheckpointCount, 0);

    controller.add([entry("e1"), entry("e2"), entry("e3")]);
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.nodeProficiencies.single.establishedCheckpointCount, 1);
  });
}
