import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";

/// A versioned, curated collection of piano skills.
@immutable
class SkillCatalogue {
  const SkillCatalogue({
    required this.id,
    required this.version,
    required this.nodes,
    this.groups = const [],
  });

  final String id;
  final int version;
  final List<SkillNode> nodes;
  final List<SkillGraphGroup> groups;
}

/// Presentation-only grouping for related skill nodes.
@immutable
class SkillGraphGroup {
  const SkillGraphGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.nodeIds,
    this.displayOrder,
  });

  final String id;
  final String name;
  final String description;
  final List<String> nodeIds;
  final int? displayOrder;
}

/// A freely accessible technique in the skill catalogue.
@immutable
class SkillNode {
  const SkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.checkpoints,
    required this.proficiencyRule,
    this.tempoProgression,
    this.relations = const [],
    this.groupIds = const [],
  });

  final String id;
  final String name;
  final String description;
  final List<SkillCheckpoint> checkpoints;
  final SkillProficiencyRule proficiencyRule;
  final TempoProgression? tempoProgression;
  final List<SkillRelation> relations;
  final List<String> groupIds;
}

/// A separately tracked variation of a skill, usually a musical key.
@immutable
class SkillCheckpoint {
  const SkillCheckpoint({
    required this.id,
    required this.name,
    required this.exercises,
  });

  final String id;
  final String name;
  final List<SkillExercise> exercises;
}

/// An exact existing exercise configuration that can be opened for practice.
@immutable
class SkillExercise {
  const SkillExercise({
    required this.id,
    required this.name,
    required this.configuration,
  });

  final String id;
  final String name;
  final ExerciseConfiguration configuration;
}

/// The non-blocking relationship between two skills.
@immutable
class SkillRelation {
  const SkillRelation({
    required this.type,
    required this.nodeId,
    this.description,
  });

  final SkillRelationType type;
  final String nodeId;
  final String? description;
}

enum SkillRelationType {
  recommendedPrerequisite,
  variation,
  related,
  appliesIn,
}

/// Determines whether reliable measured tempo is needed for proficiency.
enum TempoEvidencePolicy { required, optional, notApplicable }

/// The positive evidence required to establish proficiency for a skill.
@immutable
class SkillProficiencyRule {
  const SkillProficiencyRule({
    this.minimumAccuracy = 90,
    this.evidenceAttemptCount = 3,
    this.tempoEvidencePolicy = TempoEvidencePolicy.required,
    this.supportedTempoMeasurementVersions = const {
      TempoMeasurementVersions.current,
    },
    this.referenceTempoBpm,
  });

  final double minimumAccuracy;
  final int evidenceAttemptCount;
  final TempoEvidencePolicy tempoEvidencePolicy;
  final Set<int> supportedTempoMeasurementVersions;
  final double? referenceTempoBpm;
}

/// Optional, non-blocking tempo recommendation metadata.
@immutable
class TempoProgression {
  const TempoProgression({
    required this.incrementBpm,
    this.minimumBpm,
    this.referenceBpm,
  });

  final int incrementBpm;
  final int? minimumBpm;
  final int? referenceBpm;
}
