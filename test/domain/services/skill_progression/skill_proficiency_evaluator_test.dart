import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/skill_progression/default_skill_catalogue.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/practice/practice_step_note_value.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/services/skill_progression/exercise_configuration_identity.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_catalogue_validator.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_proficiency_evaluator.dart";

void main() {
  const config = ExerciseConfiguration(
    practiceMode: PracticeMode.scales,
    handSelection: HandSelection.both,
    key: music.Key.c,
    scaleType: music.ScaleType.major,
  );
  const exercise = SkillExercise(
    id: "c-major",
    name: "C major",
    configuration: config,
  );

  SkillNode node(TempoEvidencePolicy policy) => SkillNode(
    id: "major-scale",
    name: "Major scale",
    description: "",
    checkpoints: const [],
    proficiencyRule: SkillProficiencyRule(
      tempoEvidencePolicy: policy,
      supportedTempoMeasurementVersions:
          policy == TempoEvidencePolicy.notApplicable
          ? const {}
          : const {TempoMeasurementVersions.current},
      referenceTempoBpm: policy == TempoEvidencePolicy.notApplicable
          ? null
          : 100,
    ),
  );

  ExerciseHistoryEntry entry(
    String id, {
    double accuracy = 95,
    TempoMeasurementQuality? quality,
    int? version,
    double? bpm,
  }) => ExerciseHistoryEntry.fromConfiguration(
    id: id,
    profileId: "profile",
    completedAt: DateTime(2026, 8, int.parse(id.substring(1))),
    config: config,
    accuracyPercentage: accuracy,
    tempoMeasurementQuality: quality,
    tempoMeasurementVersion: version,
    measuredTempoBpm: bpm,
    tempoStepNoteValue: bpm == null ? null : PracticeStepNoteValue.quarter,
  );

  group("ExerciseConfigurationIdentity", () {
    test("normalizes nullable historical defaults", () {
      final history = ExerciseHistoryEntry.fromConfiguration(
        id: "e1",
        profileId: "profile",
        completedAt: DateTime(2026),
        config: config,
      );

      expect(
        ExerciseConfigurationIdentity.fromHistory(history),
        ExerciseConfigurationIdentity.fromConfiguration(config),
      );
    });
  });

  group("SkillCatalogueValidator", () {
    test("validates the shipped first-slice catalogue", () {
      expect(DefaultSkillCatalogue.catalogue.version, 2);
      expect(DefaultSkillCatalogue.catalogue.nodes, hasLength(7));
    });

    test("rejects duplicate exercise configurations", () {
      final catalogue = SkillCatalogue(
        id: "test",
        version: 1,
        nodes: [
          SkillNode(
            id: "one",
            name: "One",
            description: "",
            proficiencyRule: const SkillProficiencyRule(),
            checkpoints: const [
              SkillCheckpoint(id: "c", name: "C", exercises: [exercise]),
            ],
          ),
          SkillNode(
            id: "two",
            name: "Two",
            description: "",
            proficiencyRule: const SkillProficiencyRule(),
            checkpoints: const [
              SkillCheckpoint(id: "d", name: "D", exercises: [exercise]),
            ],
          ),
        ],
      );

      expect(
        () => SkillCatalogueValidator.validate(catalogue),
        throwsArgumentError,
      );
    });
  });

  group("SkillProficiencyEvaluator", () {
    test("required policy establishes only from reliable compatible tempo", () {
      final history = [
        entry(
          "e1",
          quality: TempoMeasurementQuality.reliable,
          version: TempoMeasurementVersions.current,
          bpm: 80,
        ),
        entry(
          "e2",
          quality: TempoMeasurementQuality.reliable,
          version: TempoMeasurementVersions.current,
          bpm: 90,
        ),
        entry(
          "e3",
          quality: TempoMeasurementQuality.reliable,
          version: TempoMeasurementVersions.current,
          bpm: 100,
        ),
        entry(
          "e4",
          quality: TempoMeasurementQuality.inconsistent,
          version: TempoMeasurementVersions.current,
        ),
      ];

      final proficiency = SkillProficiencyEvaluator.evaluateExercise(
        node(TempoEvidencePolicy.required),
        exercise,
        history,
      );

      expect(proficiency.hasEstablishedProficiency, isTrue);
      expect(proficiency.reliableTempoAttemptCount, 3);
      expect(proficiency.recentAverageMeasuredBpm, 90);
      expect(proficiency.historicalBestMeasuredBpm, 100);
    });

    test("required policy ignores incompatible tempo versions", () {
      final history = List.generate(
        3,
        (index) => entry(
          "e${index + 1}",
          quality: TempoMeasurementQuality.reliable,
          version: 1,
          bpm: 80,
        ),
      );

      final proficiency = SkillProficiencyEvaluator.evaluateExercise(
        node(TempoEvidencePolicy.required),
        exercise,
        history,
      );

      expect(proficiency.hasSufficientAccuracyEvidence, isTrue);
      expect(proficiency.hasEstablishedProficiency, isFalse);
      expect(proficiency.recentAverageMeasuredBpm, isNull);
    });

    test("does not mix pre-correction scale tempo with version 3 scales", () {
      final scaleNode = DefaultSkillCatalogue.catalogue.nodes.firstWhere(
        (node) => node.id == "major-scale",
      );
      final scaleExercise = scaleNode.checkpoints.first.exercises.first;
      final history = List.generate(
        3,
        (index) => entry(
          "e${index + 1}",
          quality: TempoMeasurementQuality.reliable,
          version: TempoMeasurementVersions.declaredStepDurations,
          bpm: 280,
        ),
      );

      final proficiency = SkillProficiencyEvaluator.evaluateExercise(
        scaleNode,
        scaleExercise,
        history,
      );

      expect(proficiency.hasSufficientAccuracyEvidence, isTrue);
      expect(proficiency.reliableTempoAttemptCount, 0);
      expect(proficiency.hasEstablishedProficiency, isFalse);
    });

    test(
      "optional policy establishes from accurate attempts without tempo",
      () {
        final proficiency = SkillProficiencyEvaluator.evaluateExercise(
          node(TempoEvidencePolicy.optional),
          exercise,
          [entry("e1"), entry("e2"), entry("e3")],
        );

        expect(proficiency.hasEstablishedProficiency, isTrue);
        expect(proficiency.reliableTempoAttemptCount, 0);
        expect(proficiency.recentAverageMeasuredBpm, isNull);
      },
    );

    test("not-applicable policy does not use tempo evidence", () {
      final proficiency = SkillProficiencyEvaluator.evaluateExercise(
        node(TempoEvidencePolicy.notApplicable),
        exercise,
        [
          entry(
            "e1",
            quality: TempoMeasurementQuality.reliable,
            version: TempoMeasurementVersions.current,
            bpm: 80,
          ),
          entry("e2"),
          entry("e3"),
        ],
      );

      expect(proficiency.hasEstablishedProficiency, isTrue);
      expect(proficiency.progressionQualifyingAttemptCount, 3);
      expect(proficiency.recentAverageMeasuredBpm, isNull);
    });

    test("below-threshold attempts never reduce positive evidence", () {
      final proficiency = SkillProficiencyEvaluator.evaluateExercise(
        node(TempoEvidencePolicy.optional),
        exercise,
        [entry("e1"), entry("e2"), entry("e3"), entry("e4", accuracy: 50)],
      );

      expect(proficiency.hasEstablishedProficiency, isTrue);
      expect(proficiency.accuracyQualifyingAttemptCount, 3);
      expect(proficiency.positiveScore, greaterThan(0));
    });
  });
}
