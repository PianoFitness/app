import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/skill_progression/default_skill_catalogue.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
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
      expect(DefaultSkillCatalogue.catalogue.version, 7);
      expect(DefaultSkillCatalogue.catalogue.nodes, hasLength(19));
    });
  });

  group("DefaultSkillCatalogue content", () {
    SkillNode nodeById(String id) => DefaultSkillCatalogue.catalogue.nodes
        .firstWhere((node) => node.id == id);

    test("version 7 nests major-scale hand exercises under each key", () {
      final catalogue = DefaultSkillCatalogue.catalogue;

      expect(catalogue.version, 7);
      expect(
        catalogue.nodes.map((node) => node.id),
        isNot(contains("major-scale-apart")),
      );

      final majorScale = nodeById("major-scale");
      expect(majorScale.checkpoints, hasLength(music.Key.values.length));
      for (final key in music.Key.values) {
        final checkpoint = majorScale.checkpoints.singleWhere(
          (candidate) => candidate.id == "major-scale-${key.name}",
        );
        expect(checkpoint.exercises.map((exercise) => exercise.id), [
          "major-scale-${key.name}-left",
          "major-scale-${key.name}-right",
          "major-scale-${key.name}-both",
        ]);
        expect(
          checkpoint.exercises.map(
            (exercise) => exercise.configuration.handSelection,
          ),
          [HandSelection.left, HandSelection.right, HandSelection.both],
        );
        for (final exercise in checkpoint.exercises) {
          expect(exercise.configuration.practiceMode, PracticeMode.scales);
          expect(exercise.configuration.key, key);
          expect(exercise.configuration.scaleType, music.ScaleType.major);
        }
      }
    });

    test("scale and mode nodes cover every key and hand selection", () {
      final expectations = <String, music.ScaleType>{
        "major-scale": music.ScaleType.major,
        "natural-minor": music.ScaleType.minor,
        "dorian-mode": music.ScaleType.dorian,
        "phrygian-mode": music.ScaleType.phrygian,
        "lydian-mode": music.ScaleType.lydian,
        "mixolydian-mode": music.ScaleType.mixolydian,
        "locrian-mode": music.ScaleType.locrian,
      };

      for (final MapEntry(key: nodeId, value: expected)
          in expectations.entries) {
        final node = nodeById(nodeId);
        expect(
          node.checkpoints,
          hasLength(music.Key.values.length),
          reason: "$nodeId should cover every key",
        );
        for (final checkpoint in node.checkpoints) {
          final exercises = checkpoint.exercises;
          expect(exercises, hasLength(3));
          expect(
            exercises.map((e) => e.configuration.handSelection),
            [HandSelection.left, HandSelection.right, HandSelection.both],
            reason: "$nodeId should offer every hand option per key",
          );
          for (final exercise in exercises) {
            expect(exercise.configuration.practiceMode, PracticeMode.scales);
            expect(exercise.configuration.scaleType, expected);
            expect(exercise.configuration.validate, returnsNormally);
          }
        }
      }
    });

    test(
      "chord-vocabulary nodes cover every key with the correct configuration",
      () {
        final progressionNodes = <String, String>{
          "i-iv-v-i": "I - IV - V - I",
          "i-v-vi-iv": "I - V - vi - IV",
          "i-vi-iv-v": "I - vi - IV - V",
          "ii-v-i": "ii - V - I",
        };

        for (final MapEntry(key: nodeId, value: progressionId)
            in progressionNodes.entries) {
          expect(
            ChordProgressionLibrary.getProgressionByName(progressionId),
            isNotNull,
            reason:
                "$progressionId must exist in ChordProgressionLibrary for $nodeId",
          );
          final node = nodeById(nodeId);
          expect(node.checkpoints, hasLength(music.Key.values.length));
          for (final key in music.Key.values) {
            final checkpoint = node.checkpoints.singleWhere(
              (checkpoint) => checkpoint.id == "$nodeId-${key.name}",
            );
            final exercise = checkpoint.exercises.single;
            expect(checkpoint.name, "${key.displayName} major");
            expect(
              exercise.configuration.practiceMode,
              PracticeMode.chordProgressions,
            );
            expect(exercise.configuration.key, key);
            expect(exercise.configuration.handSelection, HandSelection.both);
            expect(exercise.configuration.chordProgressionId, progressionId);
            expect(exercise.configuration.validate, returnsNormally);
          }
        }

        final diatonicTriads = nodeById("diatonic-triads");
        expect(diatonicTriads.name, "Foundational triads");
        expect(diatonicTriads.checkpoints, hasLength(music.Key.values.length));
        for (final key in music.Key.values) {
          final checkpoint = diatonicTriads.checkpoints.singleWhere(
            (checkpoint) => checkpoint.id == "diatonic-triads-${key.name}",
          );
          final exercise = checkpoint.exercises.single;
          expect(checkpoint.name, "${key.displayName} major");
          expect(exercise.configuration.practiceMode, PracticeMode.chordsByKey);
          expect(exercise.configuration.key, key);
          expect(exercise.configuration.scaleType, music.ScaleType.major);
          expect(exercise.configuration.handSelection, HandSelection.both);
          expect(exercise.configuration.includeSeventhChords, isFalse);
          expect(exercise.configuration.validate, returnsNormally);
        }

        final dominantCadence = nodeById("dominant-cadence");
        expect(dominantCadence.checkpoints, hasLength(music.Key.values.length));
        for (final checkpoint in dominantCadence.checkpoints) {
          final exercise = checkpoint.exercises.single;
          expect(
            exercise.configuration.practiceMode,
            PracticeMode.dominantCadence,
          );
        }

        final cadenceNodes = <String, String>{
          "plagal-cadence": "IV - I",
          "half-cadence": "I - V",
          "deceptive-cadence": "V - vi",
        };
        for (final MapEntry(key: nodeId, value: progressionId)
            in cadenceNodes.entries) {
          final node = nodeById(nodeId);
          expect(node.checkpoints, hasLength(music.Key.values.length));
          for (final key in music.Key.values) {
            final checkpoint = node.checkpoints.singleWhere(
              (checkpoint) => checkpoint.id == "$nodeId-${key.name}",
            );
            final exercise = checkpoint.exercises.single;
            expect(
              exercise.configuration.practiceMode,
              PracticeMode.chordProgressions,
            );
            expect(exercise.configuration.key, key);
            expect(exercise.configuration.chordProgressionId, progressionId);
            expect(exercise.configuration.validate, returnsNormally);
          }
        }
      },
    );

    test("core technique nodes use the intended chord types in all keys", () {
      final expectations = <String, List<(ChordType, bool)>>{
        "suspended-chords": [
          (ChordType.suspended2, false),
          (ChordType.suspended4, false),
        ],
        "altered-triads": [
          (ChordType.augmented, true),
          (ChordType.diminished, true),
        ],
      };

      for (final entry in expectations.entries) {
        final node = nodeById(entry.key);
        expect(node.checkpoints, hasLength(entry.value.length));
        for (final expectation in entry.value) {
          final checkpoint = node.checkpoints.singleWhere(
            (checkpoint) =>
                checkpoint.id == "${entry.key}-${expectation.$1.name}",
          );
          final exercise = checkpoint.exercises.single;
          expect(
            exercise.configuration.practiceMode,
            PracticeMode.chordsByType,
          );
          expect(exercise.configuration.chordType, expectation.$1);
          expect(exercise.configuration.includeInversions, expectation.$2);
          expect(exercise.configuration.handSelection, HandSelection.both);
          expect(exercise.configuration.validate, returnsNormally);
        }
      }
    });

    test("relations point at real nodes with the expected type", () {
      final expectedRelations = <String, List<(SkillRelationType, String)>>{
        "major-scale": [],
        "natural-minor": [
          (SkillRelationType.recommendedPrerequisite, "major-scale"),
        ],
        "dorian-mode": [(SkillRelationType.variation, "natural-minor")],
        "phrygian-mode": [(SkillRelationType.variation, "natural-minor")],
        "lydian-mode": [(SkillRelationType.variation, "major-scale")],
        "mixolydian-mode": [(SkillRelationType.variation, "major-scale")],
        "locrian-mode": [(SkillRelationType.variation, "natural-minor")],
        "major-arpeggio": [(SkillRelationType.related, "major-scale")],
        "diatonic-triads": [
          (SkillRelationType.recommendedPrerequisite, "major-scale"),
        ],
        "i-iv-v-i": [(SkillRelationType.appliesIn, "diatonic-triads")],
        "i-v-vi-iv": [(SkillRelationType.appliesIn, "diatonic-triads")],
        "i-vi-iv-v": [(SkillRelationType.appliesIn, "diatonic-triads")],
        "ii-v-i": [
          (SkillRelationType.recommendedPrerequisite, "diatonic-triads"),
        ],
        "dominant-cadence": [
          (SkillRelationType.recommendedPrerequisite, "diatonic-triads"),
        ],
        "plagal-cadence": [
          (SkillRelationType.recommendedPrerequisite, "diatonic-triads"),
        ],
        "half-cadence": [
          (SkillRelationType.recommendedPrerequisite, "diatonic-triads"),
        ],
        "deceptive-cadence": [
          (SkillRelationType.recommendedPrerequisite, "diatonic-triads"),
        ],
        "suspended-chords": [
          (SkillRelationType.recommendedPrerequisite, "diatonic-triads"),
        ],
        "altered-triads": [
          (SkillRelationType.recommendedPrerequisite, "diatonic-triads"),
        ],
      };

      for (final MapEntry(key: nodeId, value: expected)
          in expectedRelations.entries) {
        final node = nodeById(nodeId);
        final actual = node.relations
            .map((relation) => (relation.type, relation.nodeId))
            .toList();
        expect(actual, expected, reason: "unexpected relations for $nodeId");
      }
    });

    test("groups reference the expected node ids", () {
      final groupsById = {
        for (final group in DefaultSkillCatalogue.catalogue.groups)
          group.id: group,
      };

      expect(groupsById["key-foundations"]!.nodeIds, [
        "major-scale",
        "natural-minor",
        "major-arpeggio",
      ]);
      expect(groupsById["modes"]!.nodeIds, [
        "dorian-mode",
        "phrygian-mode",
        "lydian-mode",
        "mixolydian-mode",
        "locrian-mode",
      ]);
      expect(groupsById["chord-vocabulary"]!.nodeIds, [
        "diatonic-triads",
        "i-iv-v-i",
        "i-v-vi-iv",
        "i-vi-iv-v",
        "ii-v-i",
        "dominant-cadence",
        "plagal-cadence",
        "half-cadence",
        "deceptive-cadence",
      ]);
      expect(groupsById["core-technique"]!.nodeIds, [
        "suspended-chords",
        "altered-triads",
      ]);
    });
  });

  group("SkillCatalogueValidator", () {
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
          bpm: 140,
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
      expect(proficiency.matchingAttemptCount, 3);
      expect(proficiency.hasEstablishedProficiency, isFalse);
      expect(proficiency.recentAverageMeasuredBpm, isNull);
    });

    test("does not mix pre-correction scale tempo with version 3 scales", () {
      final scaleNode = DefaultSkillCatalogue.catalogue.nodes.firstWhere(
        (node) => node.id == "major-scale",
      );
      final scaleExercise = scaleNode.checkpoints.first.exercises.firstWhere(
        (exercise) =>
            exercise.configuration.handSelection == HandSelection.both,
      );
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
