import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_proficiency_snapshot.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/features/practice/practice_page.dart";
import "package:piano_fitness/presentation/features/skill_progression/skill_tree_page_view_model.dart";

/// A positive, freely navigable map of the curated piano technique catalogue.
class SkillTreePage extends StatelessWidget {
  const SkillTreePage({super.key, this.catalogue});

  final SkillCatalogue? catalogue;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SkillTreePageViewModel(
        userProfileRepository: context.read<IUserProfileRepository>(),
        exerciseHistoryRepository: context.read<IExerciseHistoryRepository>(),
        catalogue: catalogue,
      ),
      child: const _SkillTreeView(),
    );
  }
}

class _SkillTreeView extends StatelessWidget {
  const _SkillTreeView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SkillTreePageViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text("Technique Tree")),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, SkillTreePageViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null) {
      return Center(child: Text(viewModel.error!));
    }
    final byId = {
      for (final proficiency in viewModel.nodeProficiencies)
        proficiency.node.id: proficiency,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Explore exercises and track positive evidence across keys.",
        ),
        const SizedBox(height: 16),
        for (final group in viewModel.catalogue.groups) ...[
          Text(group.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(group.description),
          const SizedBox(height: 8),
          for (final nodeId in group.nodeIds)
            if (byId[nodeId] case final proficiency?)
              _SkillNodeCard(proficiency: proficiency),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _SkillNodeCard extends StatelessWidget {
  const _SkillNodeCard({required this.proficiency});

  final SkillNodeProficiency proficiency;

  @override
  Widget build(BuildContext context) {
    final node = proficiency.node;
    final prerequisiteNames = node.relations
        .where(
          (relation) =>
              relation.type == SkillRelationType.recommendedPrerequisite,
        )
        .map((relation) => relation.nodeId.replaceAll("-", " "))
        .join(", ");
    return Card(
      child: ListTile(
        key: Key("skill_node_${node.id}"),
        title: Text(node.name),
        subtitle: Text(
          "${node.description}\n${proficiency.establishedCheckpointCount} of ${proficiency.checkpointCount} keys established"
          "${prerequisiteNames.isEmpty ? "" : "\nRecommended first: $prerequisiteNames"}",
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SkillNodeDetailPage(proficiency: proficiency),
          ),
        ),
      ),
    );
  }
}

/// Shows key-level evidence and opens the existing practice workflow.
class SkillNodeDetailPage extends StatelessWidget {
  const SkillNodeDetailPage({super.key, required this.proficiency});

  final SkillNodeProficiency proficiency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(proficiency.node.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(proficiency.node.description),
          const SizedBox(height: 8),
          Text(
            "${proficiency.establishedCheckpointCount} of ${proficiency.checkpointCount} keys established",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final checkpoint in proficiency.checkpointProficiencies)
            _CheckpointCard(
              checkpoint: checkpoint,
              rule: proficiency.node.proficiencyRule,
            ),
        ],
      ),
    );
  }
}

class _CheckpointCard extends StatelessWidget {
  const _CheckpointCard({required this.checkpoint, required this.rule});

  final SkillCheckpointProficiency checkpoint;
  final SkillProficiencyRule rule;

  @override
  Widget build(BuildContext context) {
    final tone = checkpoint.hasEstablishedProficiency
        ? Theme.of(context).colorScheme.primaryContainer
        : checkpoint.positiveScore > 0
        ? Theme.of(context).colorScheme.secondaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      label:
          "${checkpoint.checkpoint.name}: ${checkpoint.hasEstablishedProficiency ? "established" : "in progress"}",
      child: Card(
        color: tone,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checkpoint.checkpoint.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final exercise in checkpoint.exerciseProficiencies) ...[
                const SizedBox(height: 8),
                Text(exercise.exercise.name),
                Text(
                  "${exercise.progressionQualifyingAttemptCount} of ${rule.evidenceAttemptCount} qualifying attempts"
                  "${exercise.recentAverageAccuracy == null ? "" : " · ${exercise.recentAverageAccuracy!.toStringAsFixed(0)}% recent accuracy"}",
                ),
                Text(_tempoText(exercise)),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    key: Key("practice_${exercise.exercise.id}"),
                    onPressed: () =>
                        _openPractice(context, exercise.exercise.configuration),
                    child: const Text("Practice"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _tempoText(SkillExerciseProficiency exercise) {
    final bpm = exercise.recentAverageMeasuredBpm;
    if (bpm != null) {
      final next = exercise.suggestedNextTempoBpm;
      return "${bpm.toStringAsFixed(0)} BPM exercise tempo"
          "${next == null ? "" : " · next ${next.toStringAsFixed(0)} BPM"}";
    }
    return rule.tempoEvidencePolicy == TempoEvidencePolicy.notApplicable
        ? "Tempo not recorded for this exercise"
        : "Tempo evidence not yet available";
  }

  void _openPractice(
    BuildContext context,
    ExerciseConfiguration configuration,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticePage(
          initialConfiguration: configuration,
          backTooltip: "Back to Technique Tree",
        ),
      ),
    );
  }
}
