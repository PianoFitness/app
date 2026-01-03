import "package:flutter/material.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";

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
  /// Tablet: 20.0, Mobile: Spacing.md
  static double sectionPadding(bool isTablet) => isTablet ? 20.0 : Spacing.md;

  /// Section icon size based on device type
  /// Tablet: ComponentDimensions.iconSizeLarge, Mobile: ComponentDimensions.iconSizeMedium
  static double sectionIconSize(bool isTablet) => isTablet
      ? ComponentDimensions.iconSizeLarge
      : ComponentDimensions.iconSizeMedium;

  /// Permission prompt icon size based on device type
  /// Tablet: ComponentDimensions.iconSizeXLarge, Mobile: 28
  static double permissionPromptIconSize(bool isTablet) =>
      isTablet ? ComponentDimensions.iconSizeXLarge : 28.0;

  /// Button padding based on device type
  /// Tablet: (Spacing.xl, Spacing.md), Mobile: (Spacing.lg, Spacing.sm)
  static EdgeInsets buttonPadding(bool isTablet) => EdgeInsets.symmetric(
    horizontal: isTablet ? Spacing.xl : Spacing.lg,
    vertical: isTablet ? Spacing.md : Spacing.sm,
  );

  // Feature-specific constants

  /// Custom inner section spacing
  static const double sectionInnerSpacing = 12.0;

  /// Default reminder time (6:00 PM)
  static const TimeOfDay defaultReminderTime = TimeOfDay(hour: 18, minute: 0);
}
