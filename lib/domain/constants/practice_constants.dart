/// Practice feature-specific UI constants.
///
/// These constants are specific to the practice feature and not reusable
/// across the broader application. For shared UI constants, see
/// [lib/shared/constants/ui_constants.dart].
library;

import "package:flutter/material.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";

/// Practice-specific UI dimension and timing constants.
class PracticeUIConstants {
  PracticeUIConstants._(); // Private constructor to prevent instantiation

  // ==================== Completion Overlay ====================

  /// Padding for the exercise completion overlay message.
  static const EdgeInsets completionOverlayPadding = EdgeInsets.symmetric(
    horizontal: Spacing.md,
    vertical: Spacing.sm,
  );

  // ==================== Practice Settings Panel ====================

  /// Icon size for practice status indicators.
  static const double statusIconSize = 20.0;

  /// Spacing between hand selection icons (left/right hand).
  static const double handIconSpacing = 2.0;

  /// Padding for the practice status container.
  static const EdgeInsets statusContainerPadding = EdgeInsets.symmetric(
    vertical: Spacing.sm,
    horizontal: Spacing.sm,
  );

  // ==================== Practice Progress Display ====================

  /// Padding for the progress display container.
  static const EdgeInsets progressPadding = EdgeInsets.all(Spacing.sm);
}
