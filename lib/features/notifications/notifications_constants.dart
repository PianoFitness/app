import "package:flutter/material.dart";

/// Constants for Notifications page UI elements
///
/// Contains feature-specific responsive functions and default values.
/// Common spacing, opacity, and timing values moved to shared constants.
///
/// See [lib/shared/constants/ui_constants.dart] for:
/// - Spacing (xl=32.0, md=16.0, sm=8.0)
/// - ComponentDimensions (iconSizeLarge=24, iconSizeMedium=20, iconSizeXLarge=32)
/// - OpacityValues (borderSubtle, shadowSubtle, gradientMid, gradientEnd)
/// - AnimationDurations (snackbar)
class NotificationsUIConstants {
  NotificationsUIConstants._();

  // Responsive layout functions (feature-specific)

  /// Section padding based on device type
  /// Tablet: 20.0, Mobile: uses Spacing.md (16.0)
  static double sectionPadding(bool isTablet) => isTablet ? 20.0 : 16.0;

  /// Section icon size based on device type
  /// Tablet: ComponentDimensions.iconSizeLarge (24), Mobile: ComponentDimensions.iconSizeMedium (20)
  static double sectionIconSize(bool isTablet) => isTablet ? 24.0 : 20.0;

  /// Permission prompt icon size based on device type
  /// Tablet: ComponentDimensions.iconSizeXLarge (32), Mobile: 28
  static double permissionPromptIconSize(bool isTablet) =>
      isTablet ? 32.0 : 28.0;

  /// Button padding based on device type
  /// Tablet: (32, 16), Mobile: (24, 12)
  static EdgeInsets buttonPadding(bool isTablet) => EdgeInsets.symmetric(
    horizontal: isTablet ? 32.0 : 24.0,
    vertical: isTablet ? 16.0 : 12.0,
  );

  // Feature-specific constants

  /// Custom inner section spacing
  static const double sectionInnerSpacing = 12.0;

  /// Default reminder time (6:00 PM)
  static const TimeOfDay defaultReminderTime = TimeOfDay(hour: 18, minute: 0);
}
