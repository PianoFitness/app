import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../domain/models/profile_sort_order.dart";
import "../../domain/models/user_profile.dart";
import "../../domain/repositories/user_profile_repository.dart";
import "user_profile_view_model.dart";
import "widgets/profile_create_dialog.dart";
import "widgets/profile_delete_confirmation_dialog.dart";
import "widgets/profile_edit_dialog.dart";
import "widgets/profile_list_item.dart";

/// Profile chooser page for selecting, creating, and managing user profiles.
///
/// This page displays all profiles with options to create, edit, delete,
/// and switch between profiles. It follows the app's MVVM pattern with
/// comprehensive accessibility support.
class UserProfilePage extends StatelessWidget {
  /// Creates the user profile page.
  const UserProfilePage({super.key});

  /// Route name for navigation.
  static const String routeName = "/profiles";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = UserProfileViewModel(
          userProfileRepository: context.read<IUserProfileRepository>(),
        );
        viewModel.loadProfiles();
        return viewModel;
      },
      child: Consumer<UserProfileViewModel>(
        builder: (context, viewModel, child) {
          return _buildScaffold(context, viewModel);
        },
      ),
    );
  }

  Scaffold _buildScaffold(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Choose Profile"),
        actions: [
          IconButton(
            icon: Icon(
              viewModel.sortOrder == ProfileSortOrder.alphabetical
                  ? Icons.sort_by_alpha
                  : Icons.access_time,
            ),
            onPressed: () => viewModel.toggleSortOrder(),
            tooltip: viewModel.sortOrder == ProfileSortOrder.alphabetical
                ? "Sort by last active"
                : "Sort alphabetically",
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, viewModel),
        icon: const Icon(Icons.add),
        label: const Text("Create Profile"),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorState(context, viewModel);
    }

    if (viewModel.profiles.isEmpty) {
      return _buildEmptyState(context, viewModel);
    }

    return _buildProfileList(context, viewModel);
  }

  Widget _buildErrorState(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Error Loading Profiles",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => viewModel.loadProfiles(),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "No Profiles Yet",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              "Create your first profile to get started with Piano Fitness.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showCreateDialog(context, viewModel),
              icon: const Icon(Icons.add),
              label: const Text("Create Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: viewModel.profiles.length,
      itemBuilder: (context, index) {
        final profile = viewModel.profiles[index];
        return ProfileListItem(
          profile: profile,
          onTap: () async {
            await viewModel.selectProfile(profile.id);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onEdit: () => _showEditDialog(context, viewModel, profile),
          onDelete: () => _showDeleteConfirmation(context, viewModel, profile),
        );
      },
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) async {
    final displayName = await showDialog<String>(
      context: context,
      builder: (context) => const ProfileCreateDialog(),
    );

    if (displayName != null && displayName.isNotEmpty) {
      final profile = await viewModel.createProfile(displayName);
      if (profile != null && context.mounted) {
        // Profile created and set as active, navigate to main screen
        Navigator.of(context).pop();
      } else if (context.mounted && viewModel.errorMessage != null) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    UserProfileViewModel viewModel,
    UserProfile profile,
  ) async {
    final newDisplayName = await showDialog<String>(
      context: context,
      builder: (context) => ProfileEditDialog(profile: profile),
    );

    if (newDisplayName != null && newDisplayName != profile.displayName) {
      final updated = profile.copyWith(displayName: newDisplayName);
      final success = await viewModel.updateProfile(updated);

      if (context.mounted && !success && viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (context.mounted && success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated")));
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    UserProfileViewModel viewModel,
    UserProfile profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          ProfileDeleteConfirmationDialog(profileName: profile.displayName),
    );

    if (confirmed == true) {
      final success = await viewModel.deleteProfile(profile.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Profile deleted")));

          // If no profiles left or active profile was deleted, stay on profile chooser
          if (viewModel.profiles.isEmpty) {
            // Already on profile chooser, just show empty state
          } else if (viewModel.activeProfile == null) {
            // Active profile was deleted but other profiles exist
            // User needs to select a profile
          }
        } else if (viewModel.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
