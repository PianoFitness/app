import "package:flutter/material.dart";

/// Confirmation dialog for profile deletion.
///
/// Warns the user that all associated data will be permanently deleted.
class ProfileDeleteConfirmationDialog extends StatelessWidget {
  /// Creates a profile deletion confirmation dialog.
  const ProfileDeleteConfirmationDialog({required this.profileName, super.key});

  /// The display name of the profile to delete.
  final String profileName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Profile?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All practice data, settings, and progress for \"$profileName\" will be permanently deleted.",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "This action cannot be undone.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key("profile_delete_cancel_button"),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        FilledButton(
          key: const Key("profile_delete_confirm_button"),
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
