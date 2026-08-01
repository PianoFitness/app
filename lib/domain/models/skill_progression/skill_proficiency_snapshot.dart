import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";

/// Derived proficiency for one exact exercise configuration.
@immutable
class SkillExerciseProficiency {
  const SkillExerciseProficiency({
    required this.exercise,
    required this.accuracyQualifyingAttemptCount,
    required this.reliableTempoAttemptCount,
    required this.progressionQualifyingAttemptCount,
    required this.recentAverageAccuracy,
    required this.recentAverageMeasuredBpm,
    required this.historicalBestMeasuredBpm,
    required this.hasSufficientAccuracyEvidence,
    required this.hasSufficientTempoEvidence,
    required this.hasEstablishedProficiency,
    required this.positiveScore,
    required this.suggestedNextTempoBpm,
  });

  final SkillExercise exercise;
  final int accuracyQualifyingAttemptCount;
  final int reliableTempoAttemptCount;
  final int progressionQualifyingAttemptCount;
  final double? recentAverageAccuracy;
  final double? recentAverageMeasuredBpm;
  final double? historicalBestMeasuredBpm;
  final bool hasSufficientAccuracyEvidence;
  final bool hasSufficientTempoEvidence;
  final bool hasEstablishedProficiency;
  final double positiveScore;
  final double? suggestedNextTempoBpm;
}

/// Derived proficiency for all exercises in a checkpoint.
@immutable
class SkillCheckpointProficiency {
  const SkillCheckpointProficiency({
    required this.checkpoint,
    required this.exerciseProficiencies,
    required this.hasEstablishedProficiency,
    required this.positiveScore,
  });

  final SkillCheckpoint checkpoint;
  final List<SkillExerciseProficiency> exerciseProficiencies;
  final bool hasEstablishedProficiency;
  final double positiveScore;
}

/// Derived proficiency and key coverage for a catalogue node.
@immutable
class SkillNodeProficiency {
  const SkillNodeProficiency({
    required this.node,
    required this.checkpointProficiencies,
    required this.establishedCheckpointCount,
    required this.recentAverageAccuracy,
    required this.recentAverageMeasuredBpm,
    required this.positiveScore,
  });

  final SkillNode node;
  final List<SkillCheckpointProficiency> checkpointProficiencies;
  final int establishedCheckpointCount;
  final double? recentAverageAccuracy;
  final double? recentAverageMeasuredBpm;
  final double positiveScore;

  int get checkpointCount => checkpointProficiencies.length;
}
