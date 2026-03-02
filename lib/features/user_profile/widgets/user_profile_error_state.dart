import "package:flutter/material.dart";

import "../user_profile_view_model.dart";

/// Error state widget displayed when profile loading fails.
class UserProfileErrorState extends StatelessWidget {
  /// Creates an error state widget.
  const UserProfileErrorState({required this.viewModel, super.key});

  /// The view model containing profile state and error message.
  final UserProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
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
              viewModel.errorMessage ?? "An unknown error occurred",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key("profile_error_retry_button"),
              onPressed: () => viewModel.loadProfiles(),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
