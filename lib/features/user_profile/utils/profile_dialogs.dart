import "package:flutter/material.dart";

import "../../../domain/models/user_profile.dart";
import "../widgets/profile_create_dialog.dart";
import "../widgets/profile_delete_confirmation_dialog.dart";
import "../widgets/profile_edit_dialog.dart";

/// Helper class for showing profile-related dialogs.
class ProfileDialogs {
  /// Shows the create profile dialog.
  ///
  /// Returns the display name if user confirms, null if cancelled.
  static Future<String?> showCreate(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const ProfileCreateDialog(),
    );
  }

  /// Shows the edit profile dialog.
  ///
  /// Returns the new display name if user confirms, null if cancelled.
  static Future<String?> showEdit(BuildContext context, UserProfile profile) {
    return showDialog<String>(
      context: context,
      builder: (context) => ProfileEditDialog(profile: profile),
    );
  }

  /// Shows the delete confirmation dialog.
  ///
  /// Returns true if user confirms deletion, false/null if cancelled.
  static Future<bool?> showDelete(BuildContext context, UserProfile profile) {
    return showDialog<bool>(
      context: context,
      builder: (context) =>
          ProfileDeleteConfirmationDialog(profileName: profile.displayName),
    );
  }
}
