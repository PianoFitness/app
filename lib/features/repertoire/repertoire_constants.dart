/// Constants for Repertoire page UI elements and timer logic.
///
/// Contains feature-specific constants for repertoire interface including
/// timer durations, opacity values, font sizes, and responsive breakpoints.
/// For common spacing/sizing values, see [lib/shared/constants/ui_constants.dart].
class RepertoireUIConstants {
  RepertoireUIConstants._(); // Private constructor to prevent instantiation

  // Timer Configuration
  /// Default timer duration in minutes
  static const int defaultDurationMinutes = 15;

  /// Available timer duration options in minutes
  static const List<int> timerDurations = [5, 10, 15, 20, 30];

  /// Seconds per minute conversion constant
  static const int secondsPerMinute = 60;

  /// Timer tick interval
  static const Duration timerTickDuration = Duration(seconds: 1);

  /// Minimum padding for zero value in time formatting
  static const int timePaddingWidth = 2;

  /// Padding character for time formatting
  static const String timePaddingChar = "0";

  // Opacity Values
  /// Primary gradient opacity for header
  static const double gradientPrimaryAlpha = 0.1;

  /// Secondary gradient opacity for header
  static const double gradientSecondaryAlpha = 0.1;

  /// Border opacity for containers
  static const double borderAlpha = 0.2;

  /// Shadow/highlight opacity for icons
  static const double shadowAlpha = 0.1;

  /// Tertiary container background opacity
  static const double tertiaryBackgroundAlpha = 0.1;

  /// App recommendation border opacity
  static const double appRecommendationBorderAlpha = 0.3;

  /// App icon background opacity
  static const double appIconBackgroundAlpha = 0.1;

  /// Subtitle text opacity
  static const double subtitleAlpha = 0.7;

  // Font Sizes
  /// Header title font size (standard)
  static const double headerTitleFontSize = 18.0;

  /// Header title font size (compact)
  static const double headerTitleFontSizeCompact = 16.0;

  /// Subtitle font size (standard)
  static const double subtitleFontSize = 14.0;

  /// Helper text font size (standard)
  static const double helperFontSize = 12.0;

  /// Helper text font size (compact)
  static const double helperFontSizeCompact = 11.0;

  /// Modal title font size
  static const double modalTitleFontSize = 20.0;

  /// Section header font size
  static const double sectionHeaderFontSize = 18.0;

  /// Introduction text font size
  static const double introTextFontSize = 15.0;

  /// Practice timer description font size
  static const double practiceTimerDescFontSize = 16.0;

  /// App name font size
  static const double appNameFontSize = 14.0;

  /// App description font size
  static const double appDescriptionFontSize = 12.0;

  // Responsive Breakpoints
  /// Height threshold for compact layout
  static const double compactHeightThreshold = 600.0;

  /// Width threshold for tablet detection
  static const double tabletWidthThreshold = 768.0;

  /// Height threshold for tablet detection
  static const double tabletHeightThreshold = 768.0;

  // Responsive Padding & Spacing
  /// Page padding (standard)
  static const double pagePadding = 8.0;

  /// Page padding (compact)
  static const double pagePaddingCompact = 6.0;

  /// Section spacing (standard)
  static const double sectionSpacing = 8.0;

  /// Section spacing (compact)
  static const double sectionSpacingCompact = 4.0;

  /// Header padding (standard)
  static const double headerPadding = 16.0;

  /// Header padding (compact)
  static const double headerPaddingCompact = 12.0;

  // Icon Sizes
  /// Header icon size (standard)
  static const double headerIconSize = 24.0;

  /// Header icon size (compact)
  static const double headerIconSizeCompact = 20.0;

  /// Help icon size (standard)
  static const double helpIconSize = 20.0;

  /// Help icon size (compact)
  static const double helpIconSizeCompact = 18.0;

  /// Modal header icon size
  static const double modalIconSize = 24.0;

  /// App recommendation icon size
  static const double appRecommendationIconSize = 18.0;

  // Line Heights
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

  // Container Padding & Sizing
  /// Icon container padding
  static const double iconContainerPadding = 8.0;

  /// Modal content padding
  static const double modalContentPadding = 16.0;

  /// Info container padding
  static const double infoContainerPadding = 16.0;

  /// App recommendation container padding
  static const double appRecommendationPadding = 8.0;

  /// App icon container padding
  static const double appIconPadding = 6.0;

  /// Help button padding
  static const double helpButtonPadding = 8.0;

  /// Icon button padding
  static const double iconButtonPadding = 4.0;

  // Sizing Constraints
  /// Minimum width for icon button
  static const double iconButtonMinWidth = 32.0;

  /// Minimum height for icon button
  static const double iconButtonMinHeight = 32.0;

  // Border Radius
  /// Container border radius
  static const double containerBorderRadius = 6.0;

  // Notification Configuration
  /// Timer completion notification title
  static const String notificationTitle = "Great Practice Session! 🎹";

  /// Timer completion notification payload
  static const String notificationPayload = "timer_completion";
}
