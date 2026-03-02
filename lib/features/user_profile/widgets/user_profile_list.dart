import "package:flutter/material.dart";

import "../../../domain/models/user_profile.dart";
import "../user_profile_view_model.dart";
import "profile_list_item.dart";

/// List widget displaying all user profiles.
class UserProfileList extends StatelessWidget {
  /// Creates a profile list widget.
  const UserProfileList({
    required this.viewModel,
    required this.onProfileTap,
    required this.onProfileEdit,
    required this.onProfileDelete,
    super.key,
  });

  /// The view model containing profile state.
  final UserProfileViewModel viewModel;

  /// Callback when a profile is tapped.
  final void Function(UserProfile profile) onProfileTap;

  /// Callback when a profile should be edited.
  final void Function(UserProfile profile) onProfileEdit;

  /// Callback when a profile should be deleted.
  final void Function(UserProfile profile) onProfileDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: viewModel.profiles.length,
      itemBuilder: (context, index) {
        final profile = viewModel.profiles[index];
        return ProfileListItem(
          profile: profile,
          onTap: () => onProfileTap(profile),
          onEdit: () => onProfileEdit(profile),
          onDelete: () => onProfileDelete(profile),
        );
      },
    );
  }
}
