import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";

/// Derived proficiency for one exact exercise configuration.
@immutable
class SkillExerciseProficiency {
  const SkillExerciseProficiency({
    required this.exercise,
    required this.evidence,
    required this.recentAverageAccuracy,
    required this.tempo,
    required this.hasSufficientAccuracyEvidence,
    required this.hasSufficientTempoEvidence,
    required this.hasEstablishedProficiency,
    required this.positiveScore,
  });

  final SkillExercise exercise;
  final SkillEvidenceCounts evidence;
  final double? recentAverageAccuracy;
  final SkillTempoEvidence tempo;
  final bool hasSufficientAccuracyEvidence;
  final bool hasSufficientTempoEvidence;
  final bool hasEstablishedProficiency;
  final double positiveScore;

  int get accuracyQualifyingAttemptCount => evidence.accuracyQualifying;
  int get reliableTempoAttemptCount => evidence.reliableTempo;
  int get progressionQualifyingAttemptCount => evidence.progressionQualifying;
  double? get recentAverageMeasuredBpm => tempo.recentAverageMeasuredBpm;
  double? get historicalBestMeasuredBpm => tempo.historicalBestMeasuredBpm;
  double? get suggestedNextTempoBpm => tempo.suggestedNextTempoBpm;
}

/// Counts of qualifying historical attempts for one skill exercise.
@immutable
class SkillEvidenceCounts {
  const SkillEvidenceCounts({
    required this.accuracyQualifying,
    required this.reliableTempo,
    required this.progressionQualifying,
  });

  final int accuracyQualifying;
  final int reliableTempo;
  final int progressionQualifying;
}

/// Compatible reliable tempo evidence for one skill exercise.
@immutable
class SkillTempoEvidence {
  const SkillTempoEvidence({
    required this.recentAverageMeasuredBpm,
    required this.historicalBestMeasuredBpm,
    required this.suggestedNextTempoBpm,
  });

  final double? recentAverageMeasuredBpm;
  final double? historicalBestMeasuredBpm;
  final double? suggestedNextTempoBpm;
}

/// Derived proficiency for all exercises in a checkpoint.
@immutable
class SkillCheckpointProficiency {
  SkillCheckpointProficiency({
    required this.checkpoint,
    required List<SkillExerciseProficiency> exerciseProficiencies,
    required this.hasEstablishedProficiency,
    required this.positiveScore,
  }) : exerciseProficiencies = List.unmodifiable(exerciseProficiencies);

  final SkillCheckpoint checkpoint;
  final List<SkillExerciseProficiency> exerciseProficiencies;
  final bool hasEstablishedProficiency;
  final double positiveScore;
}

/// Derived proficiency and key coverage for a catalogue node.
@immutable
class SkillNodeProficiency {
  SkillNodeProficiency({
    required this.node,
    required List<SkillCheckpointProficiency> checkpointProficiencies,
    required this.establishedCheckpointCount,
    required this.recentAverageAccuracy,
    required this.recentAverageMeasuredBpm,
    required this.positiveScore,
  }) : checkpointProficiencies = List.unmodifiable(checkpointProficiencies);

  final SkillNode node;
  final List<SkillCheckpointProficiency> checkpointProficiencies;
  final int establishedCheckpointCount;
  final double? recentAverageAccuracy;
  final double? recentAverageMeasuredBpm;
  final double positiveScore;

  int get checkpointCount => checkpointProficiencies.length;
}
