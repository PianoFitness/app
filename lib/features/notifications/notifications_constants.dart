import "package:flutter/material.dart";

/// Constants for Notifications page UI elements
///
/// Contains feature-specific constants for notifications interface including
/// responsive layout values, icon sizes, and component spacing.

/// Notifications page UI constants
///
/// Provides responsive values for padding, sizing, and spacing based on
/// device type (tablet vs mobile) and orientation.
class NotificationsUIConstants {
  NotificationsUIConstants._();

  // Section padding (responsive)
  static double sectionPadding(bool isTablet) => isTablet ? 20.0 : 16.0;

  // Icon sizes (responsive)
  static double sectionIconSize(bool isTablet) => isTablet ? 24.0 : 20.0;
  static double permissionPromptIconSize(bool isTablet) =>
      isTablet ? 32.0 : 28.0;

  // Button padding (responsive)
  static EdgeInsets buttonPadding(bool isTablet) => EdgeInsets.symmetric(
    horizontal: isTablet ? 32.0 : 24.0,
    vertical: isTablet ? 16.0 : 12.0,
  );

  // Section layout constants
  static const double sectionVerticalSpacing = 32.0;
  static const double sectionInnerSpacing = 12.0;
  static const double sectionSmallSpacing = 8.0;
  static const double permissionPromptSpacing = 16.0;

  // Shadow configuration
  static const Offset shadowOffset = Offset(0, 2);
  static const double shadowBlurRadius = 4.0;

  // Snackbar duration
  static const Duration snackbarDuration = Duration(seconds: 2);

  // Time picker default
  static const TimeOfDay defaultReminderTime = TimeOfDay(hour: 18, minute: 0);
}
