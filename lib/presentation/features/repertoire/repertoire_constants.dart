import "package:flutter/material.dart";

/// Constants for Repertoire page UI elements and timer logic.
///
/// Contains feature-specific constants for repertoire interface including
/// timer durations, responsive font sizes, and modal configurations.
/// Common spacing, sizing, and opacity values have been moved to shared constants.
///
/// See [lib/presentation/constants/ui_constants.dart] for:
/// - Spacing (xs, sm, md, lg, xl, xxl)
/// - ComponentDimensions (iconSizes, minTouchTarget)
/// - OpacityValues (borders, shadows, gradients)
/// - ResponsiveBreakpoints (tablet, compactHeight)
class RepertoireUIConstants {
  RepertoireUIConstants._(); // Private constructor to prevent instantiation

  // Responsive Font Sizes (Compact Layouts)
  // Note: Standard font sizes should use Theme.of(context).textTheme instead
  // These compact sizes are for responsive layouts with height < 600px

  /// Helper text font size (compact) - for very small screens
  static const double helperFontSizeCompact = 11.0;

  /// Page padding (compact) - for very small screens
  static const double pagePaddingCompact = 6.0;

  /// Header padding (compact)
  static const double headerPaddingCompact = 12.0;

  /// Help icon size (compact)
  static const double helpIconSizeCompact = 18.0;

  /// App recommendation icon size
  static const double appRecommendationIconSize = 18.0;

  // Line Heights & Typography
  /// Letter spacing for titles
  static const double titleLetterSpacing = -0.3;

  /// Line height for introduction text
  static const double introTextLineHeight = 1.3;

  /// Line height for practice timer description
  static const double descriptionLineHeight = 1.4;

  /// Line height for app descriptions
  static const double appDescriptionLineHeight = 1.2;

  // Modal Configuration
  /// Initial sheet size for landscape
  static const double modalInitialSizeLandscape = 0.9;

  /// Initial sheet size for tablet
  static const double modalInitialSizeTablet = 0.8;

  /// Initial sheet size for mobile
  static const double modalInitialSizeMobile = 0.75;

  /// Maximum sheet size
  static const double modalMaxSize = 0.95;

  /// Minimum sheet size for landscape
  static const double modalMinSizeLandscape = 0.6;

  /// Minimum sheet size for portrait
  static const double modalMinSizePortrait = 0.5;

  // Layout Flex Values
  /// Duration selector flex weight in horizontal layouts
  static const int durationSelectorFlex = 4;

  /// Timer display flex weight in horizontal layouts
  static const int timerDisplayFlex = 3;

  // Typography (Feature-Specific)
  /// Timer header letter spacing
  static const double headerLetterSpacing = -0.2;

  // Container Padding (Feature-Specific)
  /// App icon container padding
  static const double appIconPadding = 6.0;

  // Border Radius (Feature-Specific)
  /// Container border radius
  static const double containerBorderRadius = 6.0;

  // Brand Gradient Colors
  /// Primary gradient color (indigo) — used in timer container and header
  static const Color gradientPrimaryColor = Color(0xFF6366F1);

  /// Secondary gradient color (purple) — used in timer container gradient
  static const Color gradientSecondaryColor = Color(0xFF8B5CF6);

  // Timer Status Colors
  /// Color indicating timer is running (green)
  static const Color timerRunningColor = Color(0xFF4CAF50);

  /// Color indicating timer is paused (amber)
  static const Color timerPausedColor = Color(0xFFFF9800);

  /// Color indicating session is complete (purple)
  static const Color timerCompletedColor = Color(0xFF9C27B0);

  /// Color indicating timer is ready to start (indigo)
  static const Color timerReadyColor = Color(0xFF3F51B5);

  // Timer Display Constraint Thresholds
  /// Height below which the timer enters extremely constrained mode
  static const double timerExtremelyConstrainedHeight = 100.0;

  /// Height below which the timer enters very constrained mode
  static const double timerVeryConstrainedHeight = 140.0;

  /// Width below which the timer enters very constrained mode
  static const double timerVeryConstrainedWidth = 200.0;

  /// Height above which the timer uses its larger circle size
  static const double timerComfortableHeight = 150.0;

  // Duration Selector Constraint Thresholds
  /// Height below which the duration selector enters very constrained mode
  static const double durationVeryConstrainedHeight = 120.0;

  /// Width below which the duration selector uses horizontal-layout sizing
  static const double durationHorizontalLayoutWidth = 300.0;

  // Recommended Duration
  /// Recommended practice duration in minutes (shown with star indicator)
  static const int recommendedDurationMinutes = 15;
}
