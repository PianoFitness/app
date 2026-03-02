import "package:flutter/material.dart";

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
  bool _isCreating = false;

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

  void _onCreate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreating = true;
      });
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
              validator: _validateDisplayName,
              enabled: !_isCreating,
              onFieldSubmitted: (_) => _onCreate(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isCreating ? null : _onCreate,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Create"),
        ),
      ],
    );
  }
}
