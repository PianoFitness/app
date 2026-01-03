/// Constants for Reference page UI elements
///
/// Contains feature-specific constants for reference interface.
/// Common spacing, sizing, and opacity values moved to shared constants.
///
/// See [lib/shared/constants/ui_constants.dart] for:
/// - Spacing (xs, sm, md, lg, xl, xxl)
/// - AppBorderRadius (xs, small, medium, large, xLarge)
/// - OpacityValues (borders, shadows, gradients)
///
/// See [lib/shared/constants/musical_constants.dart] for:
/// - scaleTypeNames, chordTypeNames, chordInversionNames
///
/// Font sizes should use Theme.of(context).textTheme for consistency:
/// - titleFontSize: 18.0 → theme.textTheme.headlineMedium.fontSize
/// - sectionHeaderFontSize: 16.0 → theme.textTheme.headlineSmall.fontSize
class ReferenceUIConstants {
  ReferenceUIConstants._();

  // Feature-specific spacing (not in shared constants)
  /// Custom header spacing between elements
  static const double headerSpacing = 12.0;
}
