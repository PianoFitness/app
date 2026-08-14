import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_proficiency_snapshot.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
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
      appBar: AppBar(title: const Text("Curriculum")),
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
    final groupedNodeIds = viewModel.catalogue.groups
        .expand((group) => group.nodeIds)
        .toSet();
    final ungrouped = viewModel.nodeProficiencies
        .where((proficiency) => !groupedNodeIds.contains(proficiency.node.id))
        .toList(growable: false);
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
        if (ungrouped.isNotEmpty) ...[
          Text("Other skills", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final proficiency in ungrouped)
            _SkillNodeCard(proficiency: proficiency),
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
    final viewModel = context.read<SkillTreePageViewModel>();
    final prerequisiteNames = node.relations
        .where(
          (relation) =>
              relation.type == SkillRelationType.recommendedPrerequisite,
        )
        .map((relation) {
          for (final target in viewModel.catalogue.nodes) {
            if (target.id == relation.nodeId) return target.name;
          }
          return relation.description ?? relation.nodeId;
        })
        .join(", ");
    return Card(
      child: ListTile(
        key: Key("skill_node_${node.id}"),
        title: Text(node.name),
        subtitle: Text(
          "${node.description}\n${proficiency.establishedCheckpointCount} of ${proficiency.checkpointCount} keys complete"
          "${prerequisiteNames.isEmpty ? "" : "\nRecommended first: $prerequisiteNames"}",
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChangeNotifierProvider.value(
              value: viewModel,
              child: SkillNodeDetailPage(nodeId: node.id),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows key-level evidence and opens the existing practice workflow.
class SkillNodeDetailPage extends StatelessWidget {
  const SkillNodeDetailPage({super.key, required this.nodeId});

  final String nodeId;

  @override
  Widget build(BuildContext context) {
    final proficiency = context
        .select<SkillTreePageViewModel, SkillNodeProficiency?>(
          (viewModel) => viewModel.proficiencyForNode(nodeId),
        );
    if (proficiency == null) {
      return const Scaffold(body: Center(child: Text("Skill not found.")));
    }
    return Scaffold(
      appBar: AppBar(title: Text(proficiency.node.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.lg,
            ),
            children: [
              _SkillDetailHeader(proficiency: proficiency),
              const SizedBox(height: Spacing.md),
              for (final checkpoint in proficiency.checkpointProficiencies)
                _CheckpointCard(
                  checkpoint: checkpoint,
                  rule: proficiency.node.proficiencyRule,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillDetailHeader extends StatelessWidget {
  const _SkillDetailHeader({required this.proficiency});

  final SkillNodeProficiency proficiency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = proficiency.checkpointCount == 0
        ? 0.0
        : proficiency.establishedCheckpointCount / proficiency.checkpointCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            proficiency.node.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xs),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                "${proficiency.establishedCheckpointCount} / ${proficiency.checkpointCount} keys",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Flexible(
                    child: Semantics(
                      header: true,
                      child: Text(
                        checkpoint.checkpoint.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (checkpoint.hasEstablishedProficiency) ...[
                    const SizedBox(width: Spacing.xs),
                    Icon(
                      Icons.check_circle_rounded,
                      size: ComponentDimensions.iconSizeSmall,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              flex: 5,
              child: _PracticeChoiceRow(
                exercises: checkpoint.exerciseProficiencies,
                requiredAttemptCount: rule.evidenceAttemptCount,
                onPractice: (configuration) =>
                    _openPractice(context, configuration),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPractice(
    BuildContext context,
    ExerciseConfiguration configuration,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticePage(
          initialConfiguration: configuration,
          backTooltip: "Back to Curriculum",
        ),
      ),
    );
  }
}

/// Compact practice choices that keep the hand actions together visually.
class _PracticeChoiceRow extends StatelessWidget {
  const _PracticeChoiceRow({
    required this.exercises,
    required this.requiredAttemptCount,
    required this.onPractice,
  });

  final List<SkillExerciseProficiency> exercises;
  final int requiredAttemptCount;
  final ValueChanged<ExerciseConfiguration> onPractice;

  @override
  Widget build(BuildContext context) {
    final showHandLabels = exercises.length > 1;
    return Row(
      children: [
        for (var index = 0; index < exercises.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _PracticeChoiceButton(
              exercise: exercises[index],
              requiredAttemptCount: requiredAttemptCount,
              label: showHandLabels
                  ? _handLabel(
                      exercises[index].exercise.configuration.handSelection,
                    )
                  : "Practice",
              onPressed: () =>
                  onPractice(exercises[index].exercise.configuration),
            ),
          ),
        ],
      ],
    );
  }

  String _handLabel(HandSelection handSelection) => switch (handSelection) {
    HandSelection.left => "Left",
    HandSelection.right => "Right",
    HandSelection.both => "Together",
  };
}

class _PracticeChoiceButton extends StatelessWidget {
  const _PracticeChoiceButton({
    required this.exercise,
    required this.requiredAttemptCount,
    required this.label,
    required this.onPressed,
  });

  final SkillExerciseProficiency exercise;
  final int requiredAttemptCount;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final completed = exercise.progressionQualifyingAttemptCount
        .clamp(0, requiredAttemptCount)
        .toInt();
    final bpm = exercise.recentAverageMeasuredBpm;
    final colorScheme = Theme.of(context).colorScheme;
    final hasProgress = completed > 0;
    final backgroundColor = exercise.hasEstablishedProficiency
        ? colorScheme.primaryContainer
        : hasProgress
        ? colorScheme.secondaryContainer.withValues(alpha: 0.72)
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = exercise.hasEstablishedProficiency
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final semanticLabel = [
      exercise.exercise.name,
      "$completed of $requiredAttemptCount practices complete",
      if (bpm != null) "${bpm.toStringAsFixed(0)} BPM",
    ].join(", ");

    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: TextButton(
          key: Key("practice_${exercise.exercise.id}"),
          style: TextButton.styleFrom(
            minimumSize: const Size(
              0,
              ComponentDimensions.minTouchTarget + Spacing.sm,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.xs,
            ),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProgressDots(
                    completed: completed,
                    total: requiredAttemptCount,
                    exerciseId: exercise.exercise.id,
                  ),
                  if (bpm != null) ...[
                    const SizedBox(width: Spacing.xs),
                    Text(
                      "${bpm.toStringAsFixed(0)} BPM",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foregroundColor.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.completed,
    required this.total,
    required this.exerciseId,
  });

  final int completed;
  final int total;
  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: "$completed of $total practices complete",
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < total; index++) ...[
            if (index > 0) const SizedBox(width: 5),
            Container(
              key: Key("progress_${exerciseId}_$index"),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < completed ? colorScheme.primary : null,
                border: Border.all(
                  color: index < completed
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
