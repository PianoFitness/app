/// Typography constants for the Piano Fitness app.
///
/// Defines font sizes used throughout the app's TextTheme, matching the
/// Material Design typography system with custom sizes aligned to the
/// Piano Fitness design specification.
///
/// ## Design Notes
/// - headlineLarge (20) and titleLarge (20) intentionally share the same size
///   as they serve similar visual hierarchy roles in different contexts
/// - Font sizes follow the Material Design type scale with adjustments
///   for optimal readability on various screen sizes
library;

/// Font size constants for the app's typography system.
///
/// These values are used in the custom TextTheme defined in main.dart.
/// All sizes are in logical pixels (dp).
class FontSizes {
  FontSizes._(); // Private constructor to prevent instantiation

  // ==================== Display Styles ====================
  // Largest text - used for major page headers and prominent titles

  /// Display large font size - 32dp
  static const double displayLarge = 32;

  /// Display medium font size - 28dp
  static const double displayMedium = 28;

  /// Display small font size - 24dp
  static const double displaySmall = 24;

  // ==================== Headline Styles ====================
  // Section headers and important content labels

  /// Headline large font size - 20dp
  /// Note: Same as titleLarge for consistent visual hierarchy
  static const double headlineLarge = 20;

  /// Headline medium font size - 18dp
  static const double headlineMedium = 18;

  /// Headline small font size - 16dp
  static const double headlineSmall = 16;

  // ==================== Title Styles ====================
  // Component titles and card headers

  /// Title large font size - 20dp
  /// Note: Same as headlineLarge for consistent visual hierarchy
  static const double titleLarge = 20;

  /// Title medium font size - 16dp
  static const double titleMedium = 16;

  /// Title small font size - 14dp
  static const double titleSmall = 14;

  // ==================== Body Styles ====================
  // Main content text

  /// Body large font size - 16dp
  static const double bodyLarge = 16;

  /// Body medium font size - 14dp
  static const double bodyMedium = 14;

  /// Body small font size - 12dp
  static const double bodySmall = 12;

  // ==================== Label Styles ====================
  // Buttons, chips, captions, and small text

  /// Label large font size - 14dp
  static const double labelLarge = 14;

  /// Label medium font size - 12dp
  static const double labelMedium = 12;

  /// Label small font size - 10dp
  static const double labelSmall = 10;
}
