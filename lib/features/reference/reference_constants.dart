/// Constants for Reference page UI elements
///
/// Contains feature-specific constants for reference interface including
/// padding, spacing, font sizes, and opacity values.
/// For common spacing values, see [lib/shared/constants/ui_constants.dart].
class ReferenceUIConstants {
  ReferenceUIConstants._();

  // Container padding
  static const double containerPadding = 16.0;

  // Border radius
  static const double containerBorderRadius = 12.0;

  // Opacity values for container backgrounds and borders
  static const int borderAlpha = 80; // For border colors
  static const int selectedChipAlpha = 50; // For selected chip backgrounds

  // Font sizes
  static const double titleFontSize = 18.0;
  static const double sectionHeaderFontSize = 16.0;

  // Spacing
  static const double sectionSpacing = 16.0;
  static const double headerSpacing = 12.0;
  static const double chipSpacing = 8.0;
  static const double chipRunSpacing = 8.0;

  // Display names for scale types
  static const Map<String, String> scaleTypeNames = {
    "major": "Major",
    "minor": "Minor",
    "dorian": "Dorian",
    "phrygian": "Phrygian",
    "lydian": "Lydian",
    "mixolydian": "Mixolydian",
    "aeolian": "Aeolian",
    "locrian": "Locrian",
  };

  // Display names for chord types
  static const Map<String, String> chordTypeNames = {
    "major": "Major",
    "minor": "Minor",
    "diminished": "Diminished",
    "augmented": "Augmented",
  };

  // Display names for chord inversions
  static const Map<String, String> chordInversionNames = {
    "root": "Root Position",
    "first": "1st Inversion",
    "second": "2nd Inversion",
  };
}
