import "package:flutter/material.dart";

import "../utils/profile_validation.dart";

/// Dialog for creating a new user profile.
///
/// Collects a display name (1-30 characters) and validates input.
class ProfileCreateDialog extends StatefulWidget {
  /// Creates a profile creation dialog.
  const ProfileCreateDialog({super.key});

  @override
  State<ProfileCreateDialog> createState() => _ProfileCreateDialogState();
}

class _ProfileCreateDialogState extends State<ProfileCreateDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Profile"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your first name to create a new profile.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: "Display Name",
                hintText: "Enter your first name",
                border: OutlineInputBorder(),
              ),
              validator: validateDisplayName,
              onFieldSubmitted: (_) => _onCreate(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key("profile_create_cancel_button"),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          key: const Key("profile_create_submit_button"),
          onPressed: _onCreate,
          child: const Text("Create"),
        ),
      ],
    );
  }
}
