import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/services/skill_progression/exercise_configuration_identity.dart";

/// Validates catalogue integrity before it is shown to learners.
class SkillCatalogueValidator {
  const SkillCatalogueValidator._();

  static void validate(SkillCatalogue catalogue) {
    if (catalogue.id.isEmpty || catalogue.version < 1) {
      throw ArgumentError("A catalogue needs an id and a positive version.");
    }

    final nodeIds = <String>{};
    final configurationIdentities = <ExerciseConfigurationIdentity>{};
    for (final node in catalogue.nodes) {
      if (node.id.isEmpty || !nodeIds.add(node.id)) {
        throw ArgumentError("Skill node ids must be non-empty and unique.");
      }
      _validateRule(node.proficiencyRule);
      final checkpointIds = <String>{};
      for (final checkpoint in node.checkpoints) {
        if (checkpoint.id.isEmpty || !checkpointIds.add(checkpoint.id)) {
          throw ArgumentError("Checkpoint ids must be unique within a node.");
        }
        if (checkpoint.exercises.isEmpty) {
          throw ArgumentError("Every checkpoint must contain an exercise.");
        }
        final exerciseIds = <String>{};
        for (final exercise in checkpoint.exercises) {
          if (exercise.id.isEmpty || !exerciseIds.add(exercise.id)) {
            throw ArgumentError(
              "Exercise ids must be unique within a checkpoint.",
            );
          }
          exercise.configuration.validate();
          if (!configurationIdentities.add(
            ExerciseConfigurationIdentity.fromConfiguration(
              exercise.configuration,
            ),
          )) {
            throw ArgumentError(
              "Each catalogue exercise must have a unique configuration.",
            );
          }
        }
      }
    }

    for (final node in catalogue.nodes) {
      for (final relation in node.relations) {
        if (!nodeIds.contains(relation.nodeId)) {
          throw ArgumentError(
            "Skill relation targets must exist in the catalogue.",
          );
        }
      }
    }

    final groupIds = <String>{};
    for (final group in catalogue.groups) {
      if (group.id.isEmpty || !groupIds.add(group.id)) {
        throw ArgumentError(
          "Skill graph group ids must be non-empty and unique.",
        );
      }
      for (final nodeId in group.nodeIds) {
        if (!nodeIds.contains(nodeId)) {
          throw ArgumentError(
            "Skill graph groups may only reference known nodes.",
          );
        }
      }
    }
  }

  static void _validateRule(SkillProficiencyRule rule) {
    if (rule.minimumAccuracy < 0 || rule.minimumAccuracy > 100) {
      throw ArgumentError("Minimum accuracy must be between 0 and 100.");
    }
    if (rule.evidenceAttemptCount < 1) {
      throw ArgumentError("At least one evidence attempt is required.");
    }
    if (rule.tempoEvidencePolicy == TempoEvidencePolicy.required &&
        rule.supportedTempoMeasurementVersions.isEmpty) {
      throw ArgumentError("Required tempo evidence needs a supported version.");
    }
    if (rule.tempoEvidencePolicy == TempoEvidencePolicy.notApplicable &&
        rule.referenceTempoBpm != null) {
      throw ArgumentError(
        "Tempo-inapplicable skills cannot declare a reference BPM.",
      );
    }
    if (rule.referenceTempoBpm != null && rule.referenceTempoBpm! <= 0) {
      throw ArgumentError("Reference BPM must be positive.");
    }
  }
}
