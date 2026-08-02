import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_step_note_value.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_proficiency_snapshot.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_history_matcher.dart";

/// Derives positive skill proficiency from persisted exercise attempts.
///
/// This deliberately consumes stored tempo classifications rather than
/// recalculating timing from MIDI events.
class SkillProficiencyEvaluator {
  const SkillProficiencyEvaluator._();

  static SkillExerciseProficiency evaluateExercise(
    SkillNode node,
    SkillExercise exercise,
    Iterable<ExerciseHistoryEntry> history,
  ) {
    final rule = node.proficiencyRule;
    final entries = SkillHistoryMatcher.entriesForExercise(history, exercise)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final accurate = entries
        .where(
          (entry) => (entry.accuracyPercentage ?? 0) >= rule.minimumAccuracy,
        )
        .toList(growable: false);
    final reliableTempo = accurate
        .where((entry) => _hasCompatibleReliableTempo(entry, rule))
        .toList(growable: false);
    final progression = switch (rule.tempoEvidencePolicy) {
      TempoEvidencePolicy.required => reliableTempo,
      TempoEvidencePolicy.optional ||
      TempoEvidencePolicy.notApplicable => accurate,
    };
    final recentProgression = progression.take(rule.evidenceAttemptCount);
    final recentTempo = reliableTempo.take(rule.evidenceAttemptCount);
    final hasAccuracy = accurate.length >= rule.evidenceAttemptCount;
    final hasTempo = reliableTempo.length >= rule.evidenceAttemptCount;
    final established = switch (rule.tempoEvidencePolicy) {
      TempoEvidencePolicy.required => hasAccuracy && hasTempo,
      TempoEvidencePolicy.optional ||
      TempoEvidencePolicy.notApplicable => hasAccuracy,
    };
    final bestTempo = _maxBpm(reliableTempo);
    final suggestedTempo = _suggestedTempo(
      node.tempoProgression,
      bestTempo,
      rule.tempoEvidencePolicy,
    );

    return SkillExerciseProficiency(
      exercise: exercise,
      evidence: SkillEvidenceCounts(
        accuracyQualifying: accurate.length,
        reliableTempo: reliableTempo.length,
        progressionQualifying: progression.length,
      ),
      recentAverageAccuracy: _averageAccuracy(recentProgression),
      tempo: SkillTempoEvidence(
        recentAverageMeasuredBpm: _averageBpm(recentTempo),
        historicalBestMeasuredBpm: bestTempo,
        suggestedNextTempoBpm: suggestedTempo,
      ),
      hasSufficientAccuracyEvidence: hasAccuracy,
      hasSufficientTempoEvidence: hasTempo,
      hasEstablishedProficiency: established,
      positiveScore: _positiveScore(
        progressionCount: progression.length,
        requiredCount: rule.evidenceAttemptCount,
        established: established,
        bestTempo: bestTempo,
        referenceTempo: rule.referenceTempoBpm,
      ),
    );
  }

  static SkillCheckpointProficiency evaluateCheckpoint(
    SkillNode node,
    SkillCheckpoint checkpoint,
    Iterable<ExerciseHistoryEntry> history,
  ) {
    final exercises = checkpoint.exercises
        .map((exercise) => evaluateExercise(node, exercise, history))
        .toList(growable: false);
    final established = exercises.every(
      (proficiency) => proficiency.hasEstablishedProficiency,
    );
    return SkillCheckpointProficiency(
      checkpoint: checkpoint,
      exerciseProficiencies: exercises,
      hasEstablishedProficiency: established,
      positiveScore: _average(exercises.map((item) => item.positiveScore)),
    );
  }

  static SkillNodeProficiency evaluateNode(
    SkillNode node,
    Iterable<ExerciseHistoryEntry> history,
  ) {
    final checkpoints = node.checkpoints
        .map((checkpoint) => evaluateCheckpoint(node, checkpoint, history))
        .toList(growable: false);
    final exercises = checkpoints.expand(
      (checkpoint) => checkpoint.exerciseProficiencies,
    );
    final tempos = exercises
        .where((exercise) => exercise.recentAverageMeasuredBpm != null)
        .toList(growable: false);
    final compatibleStepValues = _compatibleStepValues(node, history);
    return SkillNodeProficiency(
      node: node,
      checkpointProficiencies: checkpoints,
      establishedCheckpointCount: checkpoints
          .where((checkpoint) => checkpoint.hasEstablishedProficiency)
          .length,
      recentAverageAccuracy: _averageNullable(
        exercises.map((exercise) => exercise.recentAverageAccuracy),
      ),
      recentAverageMeasuredBpm:
          compatibleStepValues.length == 1 && tempos.isNotEmpty
          ? _average(
              tempos.map((exercise) => exercise.recentAverageMeasuredBpm!),
            )
          : null,
      positiveScore: _average(checkpoints.map((item) => item.positiveScore)),
    );
  }

  static bool _hasCompatibleReliableTempo(
    ExerciseHistoryEntry entry,
    SkillProficiencyRule rule,
  ) {
    return entry.tempoMeasurementQuality == TempoMeasurementQuality.reliable &&
        entry.measuredTempoBpm != null &&
        entry.tempoMeasurementVersion != null &&
        rule.supportedTempoMeasurementVersions.contains(
          entry.tempoMeasurementVersion,
        );
  }

  static double? _averageAccuracy(Iterable<ExerciseHistoryEntry> entries) =>
      _averageNullable(entries.map((entry) => entry.accuracyPercentage));

  static double? _averageBpm(Iterable<ExerciseHistoryEntry> entries) =>
      _averageNullable(entries.map((entry) => entry.measuredTempoBpm));

  static double? _maxBpm(Iterable<ExerciseHistoryEntry> entries) {
    double? maximum;
    for (final entry in entries) {
      final bpm = entry.measuredTempoBpm;
      if (bpm != null && (maximum == null || bpm > maximum)) maximum = bpm;
    }
    return maximum;
  }

  static double? _suggestedTempo(
    TempoProgression? progression,
    double? bestTempo,
    TempoEvidencePolicy policy,
  ) {
    if (progression == null ||
        bestTempo == null ||
        policy == TempoEvidencePolicy.notApplicable) {
      return null;
    }
    return bestTempo + progression.incrementBpm;
  }

  static double _positiveScore({
    required int progressionCount,
    required int requiredCount,
    required bool established,
    required double? bestTempo,
    required double? referenceTempo,
  }) {
    if (progressionCount == 0) return 0;
    if (!established) return (progressionCount / requiredCount) * 0.66;
    if (referenceTempo == null || bestTempo == null) return 0.75;
    return (0.75 + (bestTempo / referenceTempo).clamp(0, 1) * 0.25).clamp(0, 1);
  }

  static double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.reduce((sum, value) => sum + value) / list.length;
  }

  static double? _averageNullable(Iterable<double?> values) {
    final present = values.whereType<double>().toList(growable: false);
    return present.isEmpty ? null : _average(present);
  }

  static Set<PracticeStepNoteValue> _compatibleStepValues(
    SkillNode node,
    Iterable<ExerciseHistoryEntry> history,
  ) {
    final values = <PracticeStepNoteValue>{};
    for (final checkpoint in node.checkpoints) {
      for (final exercise in checkpoint.exercises) {
        final entries = SkillHistoryMatcher.entriesForExercise(
          history,
          exercise,
        );
        for (final entry in entries) {
          if ((entry.accuracyPercentage ?? 0) >=
                  node.proficiencyRule.minimumAccuracy &&
              _hasCompatibleReliableTempo(entry, node.proficiencyRule) &&
              entry.tempoStepNoteValue != null) {
            values.add(entry.tempoStepNoteValue!);
          }
        }
      }
    }
    return values;
  }
}
