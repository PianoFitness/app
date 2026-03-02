import "package:flutter/material.dart";

import "../user_profile_view_model.dart";

/// Empty state widget displayed when no profiles exist.
class UserProfileEmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  const UserProfileEmptyState({
    required this.viewModel,
    required this.onCreateProfile,
    super.key,
  });

  /// The view model containing profile state.
  final UserProfileViewModel viewModel;

  /// Callback when user wants to create a profile.
  final VoidCallback onCreateProfile;

  @override
  Widget build(BuildContext context) {
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
              onPressed: onCreateProfile,
              icon: const Icon(Icons.add),
              label: const Text("Create Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
