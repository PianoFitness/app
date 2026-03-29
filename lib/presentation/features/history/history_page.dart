import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/features/history/history_page_view_model.dart";
import "package:piano_fitness/presentation/features/history/widgets/history_entry_card.dart";

/// The Practice History page.
///
/// Displays all completed exercises for the active profile in reverse-
/// chronological order. Each entry is rendered by [HistoryEntryCard].
/// Loading, empty, and error states are handled explicitly.
///
/// Follows the MVVM pattern: this widget is a thin presentation layer;
/// all state is owned by [HistoryPageViewModel].
class HistoryPage extends StatelessWidget {
  /// Creates the history page.
  const HistoryPage({super.key});

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
            padding: const EdgeInsets.all(24),
            child: Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    if (viewModel.entries.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  "No practice history yet",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Complete a practice exercise to see your history here.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: viewModel.entries.length,
          itemBuilder: (context, index) =>
              HistoryEntryCard(entry: viewModel.entries[index]),
        ),
      ),
    );
  }
}
