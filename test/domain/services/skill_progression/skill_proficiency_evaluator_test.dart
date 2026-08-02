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
  const dConfig = ExerciseConfiguration(
    practiceMode: PracticeMode.scales,
    handSelection: HandSelection.both,
    key: music.Key.d,
    scaleType: music.ScaleType.major,
  );
  const dExercise = SkillExercise(
    id: "d-major",
    name: "D major",
    configuration: dConfig,
  );

  SkillNode node(TempoEvidencePolicy policy) => SkillNode(
    id: "major-scale",
    name: "Major scale",
    description: "",
    checkpoints: [],
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
    DateTime? completedAt,
    ExerciseConfiguration? exerciseConfiguration,
    double accuracy = 95,
    TempoMeasurementQuality? quality,
    int? version,
    double? bpm,
    PracticeStepNoteValue? tempoStepNoteValue,
  }) => ExerciseHistoryEntry.fromConfiguration(
    id: id,
    profileId: "profile",
    completedAt: completedAt ?? DateTime(2026, 8),
    config: exerciseConfiguration ?? config,
    accuracyPercentage: accuracy,
    tempoMeasurementQuality: quality,
    tempoMeasurementVersion: version,
    measuredTempoBpm: bpm,
    tempoStepNoteValue: bpm == null
        ? null
        : tempoStepNoteValue ?? PracticeStepNoteValue.quarter,
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

    test("distinguishes null and empty free-form values", () {
      final emptyProgression = const ExerciseConfiguration(
        practiceMode: PracticeMode.chordProgressions,
        handSelection: HandSelection.both,
        key: music.Key.c,
        chordProgressionId: "",
      );
      final nullProgression = const ExerciseConfiguration(
        practiceMode: PracticeMode.scales,
        handSelection: HandSelection.both,
        key: music.Key.c,
        scaleType: music.ScaleType.major,
      );

      expect(
        ExerciseConfigurationIdentity.fromConfiguration(emptyProgression),
        isNot(ExerciseConfigurationIdentity.fromConfiguration(nullProgression)),
      );
    });
  });

  group("SkillCatalogueValidator", () {
    test("validates the shipped first-slice catalogue", () {
      SkillCatalogueValidator.validate(DefaultSkillCatalogue.catalogue);
      expect(DefaultSkillCatalogue.catalogue.version, 3);
      expect(DefaultSkillCatalogue.catalogue.nodes, hasLength(14));
    });

    test("rejects nodes without checkpoints and self-relations", () {
      final noCheckpoint = SkillCatalogue(
        id: "test",
        version: 1,
        nodes: [
          SkillNode(
            id: "node",
            name: "Node",
            description: "",
            proficiencyRule: SkillProficiencyRule(),
            checkpoints: [],
          ),
        ],
      );
      final selfRelation = SkillCatalogue(
        id: "test",
        version: 1,
        nodes: [
          SkillNode(
            id: "node",
            name: "Node",
            description: "",
            proficiencyRule: SkillProficiencyRule(),
            checkpoints: [
              SkillCheckpoint(id: "c", name: "C", exercises: [exercise]),
            ],
            relations: const [
              SkillRelation(type: SkillRelationType.related, nodeId: "node"),
            ],
          ),
        ],
      );

      expect(
        () => SkillCatalogueValidator.validate(noCheckpoint),
        throwsArgumentError,
      );
      expect(
        () => SkillCatalogueValidator.validate(selfRelation),
        throwsArgumentError,
      );
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
            proficiencyRule: SkillProficiencyRule(),
            checkpoints: [
              SkillCheckpoint(id: "c", name: "C", exercises: [exercise]),
            ],
          ),
          SkillNode(
            id: "two",
            name: "Two",
            description: "",
            proficiencyRule: SkillProficiencyRule(),
            checkpoints: [
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

    test("does not retain mutable catalogue collections", () {
      final nodes = <SkillNode>[];
      final catalogue = SkillCatalogue(id: "test", version: 1, nodes: nodes);

      nodes.add(
        SkillNode(
          id: "later",
          name: "Later",
          description: "",
          proficiencyRule: SkillProficiencyRule(),
          checkpoints: [],
        ),
      );

      expect(catalogue.nodes, isEmpty);
      expect(() => catalogue.nodes.add(nodes.single), throwsUnsupportedError);
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

    test("omits node BPM when qualifying tempo step values differ", () {
      final proficiencyNode = SkillNode(
        id: "two-keys",
        name: "Two keys",
        description: "",
        proficiencyRule: SkillProficiencyRule(),
        checkpoints: [
          SkillCheckpoint(id: "c", name: "C", exercises: [exercise]),
          SkillCheckpoint(id: "d", name: "D", exercises: [dExercise]),
        ],
      );
      final history = [
        entry(
          "c",
          quality: TempoMeasurementQuality.reliable,
          version: TempoMeasurementVersions.current,
          bpm: 100,
        ),
        entry(
          "d",
          exerciseConfiguration: dConfig,
          quality: TempoMeasurementQuality.reliable,
          version: TempoMeasurementVersions.current,
          bpm: 100,
          tempoStepNoteValue: PracticeStepNoteValue.eighth,
        ),
      ];

      final proficiency = SkillProficiencyEvaluator.evaluateNode(
        proficiencyNode,
        history,
      );

      expect(proficiency.recentAverageMeasuredBpm, isNull);
    });

    test("omits node BPM without qualifying tempo evidence", () {
      final proficiencyNode = SkillNode(
        id: "one-key",
        name: "One key",
        description: "",
        proficiencyRule: SkillProficiencyRule(),
        checkpoints: [
          SkillCheckpoint(id: "c", name: "C", exercises: [exercise]),
        ],
      );

      final proficiency =
          SkillProficiencyEvaluator.evaluateNode(proficiencyNode, [
            entry(
              "low-accuracy",
              accuracy: 20,
              quality: TempoMeasurementQuality.reliable,
              version: TempoMeasurementVersions.current,
              bpm: 100,
            ),
          ]);

      expect(proficiency.recentAverageMeasuredBpm, isNull);
    });
  });
}
