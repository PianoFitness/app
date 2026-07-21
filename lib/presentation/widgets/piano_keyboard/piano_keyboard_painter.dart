import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/semantics.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/note_label_mode.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_key_visual.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_geometry.dart";

/// Renders every key's shape immediately followed by its overlay
/// (`fill` -> `outline` -> `dot` -> static note/MIDI label), white keys
/// first and then black keys, all within a single canvas pass. When
/// [PianoKeyboard.showAnnotations] is enabled, each key's
/// [PianoKeyVisual.label] renders separately in a roof bar above the
/// keys, not on the key itself.
class PianoKeyboardPainter extends CustomPainter {
  /// Creates a painter for drawing piano keys on a canvas.
  PianoKeyboardPainter({
    required this.layout,
    required this.keyVisuals,
    required this.noteLabelMode,
    required this.annotationBarHeight,
    required this.whiteKeyColor,
    required this.blackKeyColor,
    required this.borderColor,
    required this.whiteLabelColor,
    required this.blackLabelColor,
    required this.annotationBarColor,
    required this.annotationTextColor,
    this.onKeyDown,
    this.onKeyUp,
  }) : super(repaint: keyVisuals);

  /// Piano keyboard layout containing keys and boundaries.
  final PianoKeyboardLayout layout;

  /// Map of per-key visual indicators.
  final ValueListenable<Map<int, PianoKeyVisual>> keyVisuals;

  /// Display mode for note labels.
  final NoteLabelMode noteLabelMode;

  /// Height of the annotation roof bar.
  final double annotationBarHeight;

  /// Color for white keys.
  final Color whiteKeyColor;

  /// Color for black keys.
  final Color blackKeyColor;

  /// Border color for key outlines.
  final Color borderColor;

  /// Text color for labels on white keys.
  final Color whiteLabelColor;

  /// Text color for labels on black keys.
  final Color blackLabelColor;

  /// Background color for annotation roof bar.
  final Color annotationBarColor;

  /// Text color for annotation roof bar labels.
  final Color annotationTextColor;

  /// Callback when a key is pressed.
  final void Function(int midiNote)? onKeyDown;

  /// Callback when a key is released.
  final void Function(int midiNote)? onKeyUp;

  static const double _minBlackLabelWidth = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final visuals = keyVisuals.value;
    final whitePaint = Paint()..color = whiteKeyColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final blackPaint = Paint()..color = blackKeyColor;

    canvas.save();
    canvas.translate(0, annotationBarHeight);
    for (final key in layout.whiteKeys) {
      canvas.drawRect(key.rect, whitePaint);
      canvas.drawRect(key.rect, borderPaint);
      _paintOverlay(
        canvas,
        key,
        isBlack: false,
        visual: visuals[key.midiNote] ?? PianoKeyVisual.empty,
      );
    }
    for (final key in layout.blackKeys) {
      canvas.drawRect(key.rect, blackPaint);
      _paintOverlay(
        canvas,
        key,
        isBlack: true,
        visual: visuals[key.midiNote] ?? PianoKeyVisual.empty,
      );
    }
    canvas.restore();

    if (annotationBarHeight > 0) {
      _paintAnnotationBar(canvas, visuals);
    }
  }

  void _paintAnnotationBar(Canvas canvas, Map<int, PianoKeyVisual> visuals) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, layout.totalWidth, annotationBarHeight),
      Paint()..color = annotationBarColor,
    );
    for (final key in [...layout.whiteKeys, ...layout.blackKeys]) {
      final label = (visuals[key.midiNote] ?? PianoKeyVisual.empty).label;
      if (label == null || label.isEmpty) continue;
      _drawCenteredText(
        canvas,
        label,
        Rect.fromLTWH(key.rect.left, 0, key.rect.width, annotationBarHeight),
        color: annotationTextColor,
        fontSize: 11,
      );
    }
  }

  void _paintOverlay(
    Canvas canvas,
    PianoKeyRect key, {
    required bool isBlack,
    required PianoKeyVisual visual,
  }) {
    final rect = key.rect;

    if (visual.fill != null) {
      canvas.drawRect(rect, Paint()..color = visual.fill!);
    }
    if (visual.outline != null) {
      canvas.drawRect(
        rect.deflate(1.5),
        Paint()
          ..color = visual.outline!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
    if (visual.dot != null) {
      final center = Offset(rect.center.dx, rect.top + rect.height * 0.5);
      canvas.drawCircle(center, rect.width * 0.2, Paint()..color = visual.dot!);
    }

    if (noteLabelMode != NoteLabelMode.none &&
        (!isBlack || rect.width >= _minBlackLabelWidth)) {
      final text = noteLabelMode == NoteLabelMode.name
          ? NoteUtils.midiNumberToNote(key.midiNote).displayName
          : key.midiNote.toString();
      final Color labelColor;
      if (visual.fill != null) {
        labelColor =
            ThemeData.estimateBrightnessForColor(visual.fill!) ==
                Brightness.dark
            ? Colors.white
            : Colors.black87;
      } else {
        labelColor = isBlack ? blackLabelColor : whiteLabelColor;
      }

      _drawCenteredText(
        canvas,
        text,
        Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * 2 / 3,
          rect.width,
          rect.height / 3,
        ),
        color: labelColor,
        fontSize: 10,
      );
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Rect box, {
    required Color color,
    required double fontSize,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: "…",
    )..layout(maxWidth: box.width);
    final offset = Offset(
      box.left + (box.width - textPainter.width) / 2,
      box.top + (box.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant PianoKeyboardPainter oldDelegate) => true;

  @override
  SemanticsBuilderCallback get semanticsBuilder => _buildSemantics;

  List<CustomPainterSemantics> _buildSemantics(Size size) {
    final visuals = keyVisuals.value;
    final result = <CustomPainterSemantics>[];
    for (final key in [...layout.whiteKeys, ...layout.blackKeys]) {
      final visual = visuals[key.midiNote] ?? PianoKeyVisual.empty;
      final descriptionParts = <String>[
        NoteUtils.midiNumberToNote(key.midiNote).displayName,
      ];
      if (visual.fill != null) descriptionParts.add("highlighted");
      if (visual.label != null && visual.label!.isNotEmpty) {
        descriptionParts.add("finger ${visual.label}");
      }
      result.add(
        CustomPainterSemantics(
          rect: key.rect.shift(Offset(0, annotationBarHeight)),
          properties: SemanticsProperties(
            label: descriptionParts.join(", "),
            textDirection: TextDirection.ltr,
            onTap: () {
              onKeyDown?.call(key.midiNote);
              onKeyUp?.call(key.midiNote);
            },
          ),
        ),
      );
    }
    return result;
  }
}
