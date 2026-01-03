/// Play page feature-specific UI constants.
///
/// These constants are specific to the play page feature and not reusable
/// across the broader application. For shared UI constants, see
/// [lib/shared/constants/ui_constants.dart].
library;

import "package:flutter/material.dart";

/// Play page-specific UI dimension and layout constants.
class PlayUIConstants {
  PlayUIConstants._(); // Private constructor to prevent instantiation

  // ==================== Content Container ====================

  /// Padding for the educational content container.
  static const double contentContainerPadding = 20.0;

  /// Icon size for the piano icon in the content header.
  static const double headerIconSize = 32.0;

  // ==================== Info Banner ====================

  /// Padding for the practice info banner.
  static const EdgeInsets infoBannerPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  /// Icon size for the info banner.
  static const double infoBannerIconSize = 16.0;
}
