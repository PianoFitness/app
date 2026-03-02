import "package:flutter/material.dart";

import "../../../domain/models/user_profile.dart";

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

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Display name cannot be empty";
    }
    if (value.length > 30) {
      return "Display name cannot exceed 30 characters";
    }
    return null;
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      Navigator.of(context).pop(_controller.text.trim());
    }
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
              decoration: const InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(),
              ),
              validator: _validateDisplayName,
              enabled: !_isSaving,
              onFieldSubmitted: (_) => _onSave(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}
