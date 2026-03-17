/// Shared validation utilities for user profile operations.
///
/// Centralizes validation logic to ensure consistency across
/// profile creation and editing workflows.
library;

/// Validates a profile display name.
///
/// Returns null if valid, or an error message string if invalid.
///
/// Rules:
/// - Cannot be null or empty (after trimming)
/// - Cannot exceed 30 characters
String? validateDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Display name cannot be empty";
  }
  if (value.length > 30) {
    return "Display name cannot exceed 30 characters";
  }
  return null;
}
