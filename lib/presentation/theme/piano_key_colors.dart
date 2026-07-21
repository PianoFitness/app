import "package:flutter/material.dart";

/// Custom theme extension for the base (unhighlighted) piano key colors.
///
/// These are the neutral key colors before any [PianoKeyVisual] indicator
/// (fill/outline/dot) is layered on top by the caller.
@immutable
class PianoKeyColors extends ThemeExtension<PianoKeyColors> {
  /// Creates piano key colors with all required parameters.
  const PianoKeyColors({required this.whiteKey, required this.blackKey});

  /// Base color for white keys.
  final Color whiteKey;

  /// Base color for black keys.
  final Color blackKey;

  /// Light theme piano key colors.
  static const light = PianoKeyColors(
    whiteKey: Color(0xFFFAFAFA),
    blackKey: Color(0xFF212121),
  );

  /// Dark theme piano key colors.
  static const dark = PianoKeyColors(
    whiteKey: Color(0xFFE0E0E0),
    blackKey: Color(0xFF303030),
  );

  @override
  PianoKeyColors copyWith({Color? whiteKey, Color? blackKey}) {
    return PianoKeyColors(
      whiteKey: whiteKey ?? this.whiteKey,
      blackKey: blackKey ?? this.blackKey,
    );
  }

  @override
  PianoKeyColors lerp(ThemeExtension<PianoKeyColors>? other, double t) {
    if (other is! PianoKeyColors) {
      return this;
    }
    return PianoKeyColors(
      whiteKey: Color.lerp(whiteKey, other.whiteKey, t)!,
      blackKey: Color.lerp(blackKey, other.blackKey, t)!,
    );
  }
}

/// Extension to easily access piano key colors from any BuildContext.
extension PianoKeyColorsExtension on BuildContext {
  /// Access piano key colors from the current theme.
  PianoKeyColors get pianoKeyColors =>
      Theme.of(this).extension<PianoKeyColors>() ?? PianoKeyColors.light;
}
