/// Constants for Repertoire page UI elements and timer logic.
///
/// Contains feature-specific constants for repertoire interface including
/// timer durations, responsive font sizes, and modal configurations.
/// Common spacing, sizing, and opacity values have been moved to shared constants.
///
/// See [lib/shared/constants/ui_constants.dart] for:
/// - Spacing (xs, sm, md, lg, xl, xxl)
/// - ComponentDimensions (iconSizes, minTouchTarget)
/// - OpacityValues (borders, shadows, gradients)
/// - ResponsiveBreakpoints (tablet, compactHeight)
class RepertoireUIConstants {
  RepertoireUIConstants._(); // Private constructor to prevent instantiation

  // Timer Configuration
  /// Default timer duration in minutes
  static const int defaultDurationMinutes = 15;

  /// Available timer duration options in minutes
  static const List<int> timerDurations = [5, 10, 15, 20, 30];

  /// Seconds per minute conversion constant
  static const int secondsPerMinute = 60;

  /// Timer tick interval (use AnimationDurations.xLong from shared constants)
  static const Duration timerTickDuration = Duration(seconds: 1);

  /// Minimum padding for zero value in time formatting
  static const int timePaddingWidth = 2;

  /// Padding character for time formatting
  static const String timePaddingChar = "0";

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

  // Container Padding (Feature-Specific)
  /// App icon container padding
  static const double appIconPadding = 6.0;

  // Border Radius (Feature-Specific)
  /// Container border radius
  static const double containerBorderRadius = 6.0;

  // Notification Configuration
  /// Timer completion notification title
  static const String notificationTitle = "Great Practice Session! 🎹";

  /// Timer completion notification payload
  static const String notificationPayload = "timer_completion";
}
