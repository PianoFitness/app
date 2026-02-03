/// Play page feature-specific UI constants.
///
/// These constants are specific to the play page feature and not reusable
/// across the broader application. For shared UI constants, see
/// [lib/presentation/constants/ui_constants.dart].
library;

import "package:flutter/material.dart";

/// Play page-specific UI dimension and layout constants.
class PlayUIConstants {
  PlayUIConstants._(); // Private constructor to prevent instantiation

  // ==================== Info Banner ====================

  /// Padding for the practice info banner.
  static const EdgeInsets infoBannerPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
}
