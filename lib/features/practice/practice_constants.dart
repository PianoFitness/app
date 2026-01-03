/// Practice feature-specific UI constants.
///
/// These constants are specific to the practice feature and not reusable
/// across the broader application. For shared UI constants, see
/// [lib/shared/constants/ui_constants.dart].
library;

import "package:flutter/material.dart";

/// Practice-specific UI dimension and timing constants.
class PracticeUIConstants {
  PracticeUIConstants._(); // Private constructor to prevent instantiation

  // ==================== Completion Overlay ====================

  /// Padding for the exercise completion overlay message.
  static const EdgeInsets completionOverlayPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// Duration to display the completion overlay before auto-dismissing.
  static const Duration completionDisplayDuration = Duration(seconds: 2);

  /// Shadow offset for the completion overlay (subtle depth effect).
  static const Offset completionShadowOffset = Offset(0, 2);

  // ==================== Practice Settings Panel ====================

  /// Padding inside the practice settings panel container.
  static const double panelPadding = 20.0;

  /// Icon size for practice status indicators.
  static const double statusIconSize = 20.0;

  /// Spacing between hand selection icons (left/right hand).
  static const double handIconSpacing = 2.0;

  /// Padding for the practice status container.
  static const EdgeInsets statusContainerPadding = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 12,
  );

  // ==================== Practice Progress Display ====================

  /// Padding for the progress display container.
  static const EdgeInsets progressPadding = EdgeInsets.all(12);

  /// Spacing between progress label and value.
  static const double progressLabelSpacing = 4.0;

  /// Spacing between progress bar and surrounding elements.
  static const double progressBarSpacing = 8.0;
}
