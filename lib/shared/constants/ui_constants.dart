/// Shared UI constants for consistent spacing, sizing, and timing across the app.
///
/// This file provides Material Design-inspired constants for building
/// consistent, maintainable UIs throughout Piano Fitness.
library;

/// Standardized spacing values following Material Design guidelines.
///
/// Use these for consistent padding, margins, and gaps throughout the app.
/// Based on the 4pt/8pt grid system.
class Spacing {
  Spacing._(); // Private constructor to prevent instantiation

  /// Extra small spacing: 4.0 logical pixels
  static const double xs = 4.0;

  /// Small spacing: 8.0 logical pixels
  static const double sm = 8.0;

  /// Medium spacing: 16.0 logical pixels (default for most cases)
  static const double md = 16.0;

  /// Large spacing: 24.0 logical pixels
  static const double lg = 24.0;

  /// Extra large spacing: 32.0 logical pixels
  static const double xl = 32.0;

  /// Double extra large spacing: 48.0 logical pixels
  static const double xxl = 48.0;
}

/// Standardized border radius values for consistent component styling.
///
/// Use these for cards, containers, buttons, and other rounded elements.
class AppBorderRadius {
  AppBorderRadius._(); // Private constructor to prevent instantiation

  /// Extra small border radius: 4.0 logical pixels
  static const double xs = 4.0;

  /// Small border radius: 8.0 logical pixels
  static const double small = 8.0;

  /// Medium border radius: 12.0 logical pixels
  static const double medium = 12.0;

  /// Large border radius: 16.0 logical pixels
  static const double large = 16.0;

  /// Extra large border radius: 20.0 logical pixels
  static const double xLarge = 20.0;
}

/// Component-specific dimension constants.
///
/// Standardized sizes for interactive elements and UI components.
class ComponentDimensions {
  ComponentDimensions._(); // Private constructor to prevent instantiation

  /// Minimum touch target size for accessibility: 44.0 logical pixels
  static const double minTouchTarget = 44.0;

  /// Small icon size: 16.0 logical pixels
  static const double iconSizeSmall = 16.0;

  /// Medium icon size: 20.0 logical pixels
  static const double iconSizeMedium = 20.0;

  /// Large icon size: 24.0 logical pixels
  static const double iconSizeLarge = 24.0;

  /// Extra large icon size: 32.0 logical pixels
  static const double iconSizeXLarge = 32.0;
}

/// Standardized animation and transition durations.
///
/// Use these for consistent timing across the app's animations.
class AnimationDurations {
  AnimationDurations._(); // Private constructor to prevent instantiation

  /// Short animation: 200 milliseconds
  static const Duration short = Duration(milliseconds: 200);

  /// Medium animation: 300 milliseconds
  static const Duration medium = Duration(milliseconds: 300);

  /// Long animation: 500 milliseconds
  static const Duration long = Duration(milliseconds: 500);

  /// Extra long animation: 1 second
  static const Duration xLong = Duration(seconds: 1);
}
