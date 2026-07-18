import "package:flutter/material.dart";

/// Independently composable visual indicators for a single piano key.
///
/// None of these fields carry inherent meaning — "this is the target key"
/// or "this was pressed correctly" is a decision the caller/view-model
/// makes by choosing colors, not something [PianoKeyboard] understands.
@immutable
class PianoKeyVisual {
  /// Creates a piano key visual with any subset of indicators set.
  const PianoKeyVisual({this.fill, this.outline, this.dot, this.label});

  /// No indicators set; the key renders with its default neutral appearance.
  static const empty = PianoKeyVisual();

  /// Background tint of the key.
  final Color? fill;

  /// Border stroke color around the key.
  final Color? outline;

  /// Small circular indicator color, centered on the key.
  final Color? dot;

  /// Short annotation text, e.g. a finger number ("1", "R2", "L1").
  ///
  /// Capped at 2-3 characters for legibility; longer values are truncated
  /// with an ellipsis when rendered.
  final String? label;

  /// Returns a copy with the given fields replaced.
  PianoKeyVisual copyWith({
    Color? fill,
    Color? outline,
    Color? dot,
    String? label,
  }) {
    return PianoKeyVisual(
      fill: fill ?? this.fill,
      outline: outline ?? this.outline,
      dot: dot ?? this.dot,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PianoKeyVisual &&
          runtimeType == other.runtimeType &&
          fill == other.fill &&
          outline == other.outline &&
          dot == other.dot &&
          label == other.label;

  @override
  int get hashCode => Object.hash(fill, outline, dot, label);

  @override
  String toString() =>
      "PianoKeyVisual(fill: $fill, outline: $outline, dot: $dot, label: $label)";
}
