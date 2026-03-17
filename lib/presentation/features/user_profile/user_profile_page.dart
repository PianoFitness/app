import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../domain/models/profile_sort_order.dart";
import "../../../domain/models/user_profile.dart";
import "../../../domain/repositories/user_profile_repository.dart";
import "user_profile_view_model.dart";
import "utils/profile_dialogs.dart";
import "widgets/user_profile_empty_state.dart";
import "widgets/user_profile_error_state.dart";
import "widgets/user_profile_list.dart";

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
    return UserProfileErrorState(viewModel: viewModel);
  }

  Widget _buildEmptyState(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) {
    return UserProfileEmptyState(
      onCreateProfile: () => _showCreateDialog(context, viewModel),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) {
    return UserProfileList(
      viewModel: viewModel,
      onProfileTap: (profile) async {
        await viewModel.selectProfile(profile.id);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      onProfileEdit: (profile) => _showEditDialog(context, viewModel, profile),
      onProfileDelete: (profile) =>
          _showDeleteConfirmation(context, viewModel, profile),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    UserProfileViewModel viewModel,
  ) async {
    final displayName = await ProfileDialogs.showCreate(context);

    if (displayName != null && displayName.isNotEmpty) {
      final profile = await viewModel.createProfile(displayName);
      if (profile != null && context.mounted) {
        // Profile created and set as active, navigate back
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
    final newDisplayName = await ProfileDialogs.showEdit(context, profile);

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
    final confirmed = await ProfileDialogs.showDelete(context, profile);

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
