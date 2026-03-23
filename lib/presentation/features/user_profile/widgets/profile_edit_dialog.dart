import "package:flutter/material.dart";

import "package:piano_fitness/domain/models/user_profile.dart";
import "package:piano_fitness/presentation/features/user_profile/utils/profile_validation.dart";

/// Dialog for editing an existing user profile's display name.
class ProfileEditDialog extends StatefulWidget {
  /// Creates a profile edit dialog.
  const ProfileEditDialog({required this.profile, super.key});

  /// The profile to edit.
  final UserProfile profile;

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.profile.displayName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    // Re-entrancy guard
    if (_isSaving) return;

    // Null-safe form state access
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    setState(() => _isSaving = true);
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Profile"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Update the display name for this profile.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              maxLength: 30,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(),
              ),
              validator: validateDisplayName,
              onFieldSubmitted: (_) => _onSave(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key("profile_edit_cancel_button"),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          key: const Key("profile_edit_save_button"),
          onPressed: _isSaving ? null : _onSave,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
