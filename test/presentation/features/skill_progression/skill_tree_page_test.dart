import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_step_note_value.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/features/skill_progression/skill_tree_page.dart";
import "package:provider/provider.dart";

import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  final catalogue = SkillCatalogue(
    id: "test-curriculum",
    version: 1,
    nodes: [
      SkillNode(
        id: "major-scale",
        name: "Major scale",
        description: "Build scale technique one hand at a time, then together.",
        checkpoints: [
          _scaleCheckpoint(music.Key.c),
          _scaleCheckpoint(music.Key.cSharp),
        ],
        proficiencyRule: SkillProficiencyRule(),
      ),
    ],
  );

  testWidgets("lists each key with left, right, and together choices", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profiles = MockIUserProfileRepository();
    final history = MockIExerciseHistoryRepository();
    when(profiles.getActiveProfileId()).thenAnswer((_) async => null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IUserProfileRepository>.value(value: profiles),
          Provider<IExerciseHistoryRepository>.value(value: history),
        ],
        child: MaterialApp(home: SkillTreePage(catalogue: catalogue)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("skill_node_major-scale")));
    await tester.pumpAndSettle();

    expect(find.text("C major"), findsOneWidget);
    expect(find.text("D♭ major"), findsOneWidget);
    expect(find.widgetWithText(TextButton, "Left"), findsNWidgets(2));
    expect(find.widgetWithText(TextButton, "Right"), findsNWidgets(2));
    expect(find.widgetWithText(TextButton, "Together"), findsNWidgets(2));
    expect(
      find.byKey(const Key("practice_major-scale-c-left")),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key("practice_major-scale-c-right")),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key("practice_major-scale-c-both")),
      findsOneWidget,
    );
    for (final hand in HandSelection.values) {
      for (var index = 0; index < 3; index++) {
        expect(
          find.byKey(Key("progress_major-scale-c-${hand.name}_$index")),
          findsOneWidget,
        );
      }
    }
    expect(find.textContaining("qualifying attempts"), findsNothing);
    expect(find.textContaining("Tempo evidence"), findsNothing);
    expect(find.textContaining("Tempo not recorded"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("shows BPM only after tempo has been recorded", (tester) async {
    final profiles = MockIUserProfileRepository();
    final history = MockIExerciseHistoryRepository();
    final entry = ExerciseHistoryEntry.fromConfiguration(
      id: "tempo-entry",
      profileId: "profile",
      completedAt: DateTime(2026, 8, 14),
      config: _configuration(music.Key.c, HandSelection.left),
      accuracyPercentage: 96,
      measuredTempoBpm: 88,
      tempoMeasurementQuality: TempoMeasurementQuality.reliable,
      tempoMeasurementVersion: TempoMeasurementVersions.current,
      tempoStepNoteValue: PracticeStepNoteValue.eighth,
    );
    when(profiles.getActiveProfileId()).thenAnswer((_) async => "profile");
    when(
      history.watchEntriesForProfile("profile"),
    ).thenAnswer((_) => Stream.value([entry]));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IUserProfileRepository>.value(value: profiles),
          Provider<IExerciseHistoryRepository>.value(value: history),
        ],
        child: MaterialApp(home: SkillTreePage(catalogue: catalogue)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("curriculum_continue")), findsOneWidget);
    expect(find.byKey(const Key("curriculum_continue_button")), findsOneWidget);
    await tester.tap(find.byKey(const Key("skill_node_major-scale")));
    await tester.pumpAndSettle();

    expect(find.text("88 BPM"), findsOneWidget);
    expect(find.textContaining("Tempo evidence"), findsNothing);
  });

  testWidgets("marks recorded practice without compatible tempo evidence", (
    tester,
  ) async {
    final profiles = MockIUserProfileRepository();
    final history = MockIExerciseHistoryRepository();
    final entry = ExerciseHistoryEntry.fromConfiguration(
      id: "older-tempo-entry",
      profileId: "profile",
      completedAt: DateTime(2026, 8, 14),
      config: _configuration(music.Key.c, HandSelection.left),
      accuracyPercentage: 100,
      measuredTempoBpm: 176,
      tempoMeasurementQuality: TempoMeasurementQuality.reliable,
      tempoMeasurementVersion: TempoMeasurementVersions.declaredStepDurations,
      tempoStepNoteValue: PracticeStepNoteValue.quarter,
    );
    when(profiles.getActiveProfileId()).thenAnswer((_) async => "profile");
    when(
      history.watchEntriesForProfile("profile"),
    ).thenAnswer((_) => Stream.value([entry]));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IUserProfileRepository>.value(value: profiles),
          Provider<IExerciseHistoryRepository>.value(value: history),
        ],
        child: MaterialApp(home: SkillTreePage(catalogue: catalogue)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("skill_node_major-scale")));
    await tester.pumpAndSettle();

    expect(find.byTooltip("1 of 3 practices recorded"), findsOneWidget);
    expect(find.text("176 BPM"), findsNothing);
  });
}

SkillCheckpoint _scaleCheckpoint(music.Key key) => SkillCheckpoint(
  id: key.name,
  name: "${key.displayName} major",
  exercises: HandSelection.values
      .map(
        (hand) => SkillExercise(
          id: "major-scale-${key.name}-${hand.name}",
          name: "${key.displayName} major ${hand.name}",
          configuration: _configuration(key, hand),
        ),
      )
      .toList(growable: false),
);

ExerciseConfiguration _configuration(music.Key key, HandSelection hand) =>
    ExerciseConfiguration(
      practiceMode: PracticeMode.scales,
      handSelection: hand,
      key: key,
      scaleType: music.ScaleType.major,
    );
