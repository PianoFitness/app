import "dart:math" as math;

import "package:flutter/material.dart";

/// A chromatic circle that reveals the geometry of selected musical tones.
///
/// Pitch classes are arranged clockwise from C. [selectedPitchClasses] form
/// a connected shape, while [activePitchClasses] provide immediate feedback
/// for notes the learner is currently playing.
class TwelveToneCircle extends StatelessWidget {
  /// Creates a twelve-tone circle.
  const TwelveToneCircle({
    required this.selectedPitchClasses,
    required this.activePitchClasses,
    super.key,
  });

  /// Pitch classes (0–11) belonging to the selected scale or chord.
  final Set<int> selectedPitchClasses;

  /// Pitch classes (0–11) currently sounding through MIDI or touch.
  final Set<int> activePitchClasses;

  static const _noteNames = [
    "C",
    "D♭",
    "D",
    "E♭",
    "E",
    "F",
    "G♭",
    "G",
    "A♭",
    "A",
    "B♭",
    "B",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedNames = [
      for (var pitchClass = 0; pitchClass < _noteNames.length; pitchClass++)
        if (selectedPitchClasses.contains(pitchClass)) _noteNames[pitchClass],
    ];
    final activeNames = [
      for (var pitchClass = 0; pitchClass < _noteNames.length; pitchClass++)
        if (activePitchClasses.contains(pitchClass)) _noteNames[pitchClass],
    ];
    final semanticsParts = <String>[
      "Twelve-tone circle",
      if (selectedNames.isNotEmpty)
        "selected tones ${selectedNames.join(", ")}",
      if (activeNames.isNotEmpty) "playing ${activeNames.join(", ")}",
    ];

    return Semantics(
      key: const Key("twelve_tone_circle"),
      image: true,
      label: semanticsParts.join(". "),
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _TwelveToneCirclePainter(
            selectedPitchClasses: selectedPitchClasses,
            activePitchClasses: activePitchClasses,
            colorScheme: theme.colorScheme,
            textStyle: theme.textTheme.labelLarge,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _TwelveToneCirclePainter extends CustomPainter {
  const _TwelveToneCirclePainter({
    required this.selectedPitchClasses,
    required this.activePitchClasses,
    required this.colorScheme,
    required this.textStyle,
  });

  final Set<int> selectedPitchClasses;
  final Set<int> activePitchClasses;
  final ColorScheme colorScheme;
  final TextStyle? textStyle;

  static const _noteNames = TwelveToneCircle._noteNames;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final nodeRadius = (size.shortestSide * 0.072).clamp(15.0, 23.0);
    final radius = math.max(0.0, size.shortestSide / 2 - nodeRadius - 3);
    final positions = <Offset>[
      for (var index = 0; index < 12; index++)
        center +
            Offset.fromDirection(-math.pi / 2 + index * math.pi / 6, radius),
    ];

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = colorScheme.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final selectedPositions = [
      for (var index = 0; index < positions.length; index++)
        if (selectedPitchClasses.contains(index)) positions[index],
    ];
    if (selectedPositions.length >= 2) {
      final path = Path()
        ..moveTo(selectedPositions.first.dx, selectedPositions.first.dy);
      for (final position in selectedPositions.skip(1)) {
        path.lineTo(position.dx, position.dy);
      }
      if (selectedPositions.length > 2) path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = colorScheme.primary.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = colorScheme.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (var index = 0; index < positions.length; index++) {
      final isSelected = selectedPitchClasses.contains(index);
      final isActive = activePitchClasses.contains(index);
      final fill = isActive
          ? colorScheme.primary
          : isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest;
      final foreground = isActive
          ? colorScheme.onPrimary
          : isSelected
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurfaceVariant;

      canvas.drawCircle(positions[index], nodeRadius, Paint()..color = fill);
      if (isSelected || isActive) {
        canvas.drawCircle(
          positions[index],
          nodeRadius,
          Paint()
            ..color = colorScheme.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = isActive ? 3 : 1.5,
        );
      }
      _paintLabel(
        canvas,
        label: _noteNames[index],
        center: positions[index],
        color: foreground,
      );
    }
  }

  void _paintLabel(
    Canvas canvas, {
    required String label,
    required Offset center,
    required Color color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _TwelveToneCirclePainter oldDelegate) {
    return oldDelegate.selectedPitchClasses != selectedPitchClasses ||
        oldDelegate.activePitchClasses != activePitchClasses ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.textStyle != textStyle;
  }
}
