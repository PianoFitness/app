import "package:flutter/material.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/history/history_page_view_model.dart";
import "package:piano_fitness/presentation/features/history/widgets/history_entry_card.dart";
import "package:provider/provider.dart";

/// Progress overview with a compact summary and chronological practice detail.
class HistoryPage extends StatelessWidget {
  /// Creates the progress page.
  const HistoryPage({this.onOpenCurriculum, super.key});

  /// Opens the curriculum from an empty state.
  final VoidCallback? onOpenCurriculum;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryPageViewModel(
        userProfileRepository: context.read<IUserProfileRepository>(),
        exerciseHistoryRepository: context.read<IExerciseHistoryRepository>(),
      ),
      child: Consumer<HistoryPageViewModel>(
        builder: (context, viewModel, _) => _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryPageViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined),
                const SizedBox(height: Spacing.sm),
                Text(viewModel.error!, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    if (viewModel.entries.isEmpty) {
      return Scaffold(body: _ProgressEmptyState(onStart: onOpenCurriculum));
    }

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.md,
                    Spacing.md,
                    Spacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _ProgressSummary(viewModel: viewModel),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.md,
                    Spacing.md,
                    Spacing.xs,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      "Recent activity",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: viewModel.entries.length,
                  itemBuilder: (context, index) =>
                      HistoryEntryCard(entry: viewModel.entries[index]),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.viewModel});

  final HistoryPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bestAccuracy = viewModel.bestAccuracyPercentage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your practice is adding up",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          "A simple view of the work you have recorded.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Expanded(
              child: _ProgressMetric(
                key: const Key("progress_practices_metric"),
                value: "${viewModel.totalPracticeCount}",
                label: viewModel.totalPracticeCount == 1
                    ? "practice"
                    : "practices",
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _ProgressMetric(
                key: const Key("progress_days_metric"),
                value: "${viewModel.practiceDayCount}",
                label: viewModel.practiceDayCount == 1 ? "day" : "days",
              ),
            ),
            if (bestAccuracy != null) ...[
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _ProgressMetric(
                  key: const Key("progress_accuracy_metric"),
                  value: "${bestAccuracy.toStringAsFixed(0)}%",
                  label: "best accuracy",
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.value, required this.label, super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressEmptyState extends StatelessWidget {
  const _ProgressEmptyState({this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_outlined,
                size: ComponentDimensions.iconSizeXLarge,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                "Your progress starts here",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                "Complete a curriculum exercise and your practice will appear here.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (onStart != null) ...[
                const SizedBox(height: Spacing.md),
                FilledButton.icon(
                  key: const Key("progress_open_curriculum"),
                  onPressed: onStart,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text("Explore curriculum"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
