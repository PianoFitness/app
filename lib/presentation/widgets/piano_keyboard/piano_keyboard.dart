import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/semantics.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/theme/piano_key_colors.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/midi_note_range.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/note_label_mode.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_key_visual.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_controller.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_geometry.dart";

export "package:piano_fitness/presentation/widgets/piano_keyboard/midi_note_range.dart";
export "package:piano_fitness/presentation/widgets/piano_keyboard/note_label_mode.dart";
export "package:piano_fitness/presentation/widgets/piano_keyboard/piano_key_visual.dart";
export "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_controller.dart";

/// A custom piano keyboard widget rendering an arbitrary [MidiNoteRange]
/// with independently composable per-key visual indicators.
///
/// See `docs/specifications/piano-keyboard-component.md` for the full
/// design. Replaces the third-party `piano` package's `InteractivePiano`.
class PianoKeyboard extends StatefulWidget {
  /// Creates a piano keyboard for [range].
  const PianoKeyboard({
    required this.range,
    required this.keyVisuals,
    super.key,
    this.noteLabelMode = NoteLabelMode.none,
    this.showAnnotations = false,
    this.enableGlissando = true,
    this.onKeyDown,
    this.onKeyUp,
    this.controller,
    this.keyWidth,
  });

  /// The MIDI range to display. Expanded internally to white-key
  /// boundaries if it starts or ends mid-octave.
  final MidiNoteRange range;

  /// Per-key visual indicators, keyed by MIDI note number. Notes absent
  /// from the map render with default/neutral appearance; notes present
  /// but outside [range] are silently ignored.
  final ValueListenable<Map<int, PianoKeyVisual>> keyVisuals;

  /// Widget-level static per-key label mode (independent of the per-key
  /// [PianoKeyVisual.label]).
  final NoteLabelMode noteLabelMode;

  /// Whether to reserve a dark annotation bar above the keys (a "roof")
  /// for rendering each key's [PianoKeyVisual.label] (e.g. a finger
  /// number), anchored above that key's x-position instead of on top of
  /// the key itself. When `false`, [PianoKeyVisual.label] is not
  /// rendered anywhere.
  final bool showAnnotations;

  /// Whether a single-finger drag across keys retriggers notes
  /// (glissando). When `false`, dragging off the originally-pressed key
  /// cancels the note instead of retriggering a new one.
  final bool enableGlissando;

  /// Called when a key is pressed, by MIDI note number.
  final void Function(int midiNote)? onKeyDown;

  /// Called when a key is released, by MIDI note number.
  final void Function(int midiNote)? onKeyUp;

  /// Optional controller for programmatic scrolling (see
  /// [PianoKeyboardController.ensureVisible]).
  final PianoKeyboardController? controller;

  /// Preferred white-key width. Floored internally at
  /// [ComponentDimensions.minTouchTarget]; the keyboard scrolls rather
  /// than shrinking keys below that floor.
  final double? keyWidth;

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> {
  static const double _panSlop = 12;

  late PianoKeyboardController _controller;
  bool _ownsController = false;
  PianoKeyboardLayout? _layout;

  final Map<int, int?> _pointerKeys = {};
  final Map<int, Offset> _pointerDownPositions = {};
  final Map<int, Offset> _pointerCurrentPositions = {};
  final Set<int> _slidOffPointers = {};
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant PianoKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController();
    }
  }

  @override
  void dispose() {
    for (final midi in _pointerKeys.values) {
      if (midi != null) {
        widget.onKeyUp?.call(midi);
      }
    }
    _pointerKeys.clear();
    _pointerDownPositions.clear();
    _pointerCurrentPositions.clear();
    _slidOffPointers.clear();
    _isPanning = false;
    _detachController();
    super.dispose();
  }

  void _attachController() {
    _controller = widget.controller ?? PianoKeyboardController();
    _ownsController = widget.controller == null;
    _controller.attach(_ensureVisible);
  }

  void _detachController() {
    _controller.detach();
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _ensureVisible(int midiNote) {
    final layout = _layout;
    final scrollController = _controller.scrollController;
    if (layout == null || !scrollController.hasClients) return;

    final target = _findKeyRect(layout, midiNote);
    if (target == null) return;

    final position = scrollController.position;
    final viewportWidth = position.viewportDimension;
    final current = scrollController.offset;
    var newOffset = current;
    if (target.rect.left < current) {
      newOffset = target.rect.left;
    } else if (target.rect.right > current + viewportWidth) {
      newOffset = target.rect.right - viewportWidth;
    }
    newOffset = newOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  PianoKeyRect? _findKeyRect(PianoKeyboardLayout layout, int midiNote) {
    for (final key in layout.blackKeys) {
      if (key.midiNote == midiNote) return key;
    }
    for (final key in layout.whiteKeys) {
      if (key.midiNote == midiNote) return key;
    }
    return null;
  }

  double _resolveWhiteKeyWidth() {
    final requested = widget.keyWidth ?? ComponentDimensions.minTouchTarget;
    return requested < ComponentDimensions.minTouchTarget
        ? ComponentDimensions.minTouchTarget
        : requested;
  }

  double get _annotationBarHeight =>
      widget.showAnnotations ? ComponentDimensions.pianoAnnotationBarHeight : 0;

  Offset _toContentPosition(Offset localPosition) {
    final scrollOffset = _controller.scrollController.hasClients
        ? _controller.scrollController.offset
        : 0.0;
    return Offset(
      localPosition.dx + scrollOffset,
      localPosition.dy - _annotationBarHeight,
    );
  }

  void _handlePointerDown(PointerDownEvent event, PianoKeyboardLayout layout) {
    _pointerDownPositions[event.pointer] = event.localPosition;
    _pointerCurrentPositions[event.pointer] = event.localPosition;
    if (_isPanning) {
      // Don't record a key for pointers that arrive mid-pan: there was no
      // matching onKeyDown, so release must not emit a stray onKeyUp.
      _pointerKeys[event.pointer] = null;
      return;
    }
    final midi = layout.hitTest(_toContentPosition(event.localPosition));
    _pointerKeys[event.pointer] = midi;
    if (midi != null) {
      widget.onKeyDown?.call(midi);
    }
  }

  void _handlePointerMove(PointerMoveEvent event, PianoKeyboardLayout layout) {
    if (!_pointerKeys.containsKey(event.pointer)) return;
    _pointerCurrentPositions[event.pointer] = event.localPosition;

    // Multiple concurrent pointers that drift together read as a
    // two-finger pan rather than independent glissandos; a small slop
    // avoids misreading stationary-chord jitter as the start of a pan.
    // Requiring every active pointer (not just the one that just moved)
    // to have drifted keeps an independent single-finger glissando from
    // being misread as the start of a pan.
    if (!_isPanning && _pointerKeys.length >= 2) {
      final allPointersDrifted = _pointerKeys.keys.every((pointer) {
        final down = _pointerDownPositions[pointer];
        final current = _pointerCurrentPositions[pointer];
        return down != null &&
            current != null &&
            (current - down).distance > _panSlop;
      });
      if (allPointersDrifted) {
        _startPanning();
      }
    }

    if (_isPanning) {
      _applyPanDelta(event.delta.dx);
      return;
    }

    if (_slidOffPointers.contains(event.pointer)) return;

    final previousMidi = _pointerKeys[event.pointer];
    final midi = layout.hitTest(_toContentPosition(event.localPosition));
    if (midi == previousMidi) return;

    if (previousMidi != null) {
      widget.onKeyUp?.call(previousMidi);
    }
    if (!widget.enableGlissando && previousMidi != null) {
      _slidOffPointers.add(event.pointer);
      _pointerKeys[event.pointer] = null;
      return;
    }
    _pointerKeys[event.pointer] = midi;
    if (midi != null) {
      widget.onKeyDown?.call(midi);
    }
  }

  void _startPanning() {
    _isPanning = true;
    for (final entry in _pointerKeys.entries) {
      if (entry.value != null) {
        widget.onKeyUp?.call(entry.value!);
      }
    }
    _pointerKeys.updateAll((key, value) => null);
  }

  void _applyPanDelta(double dx) {
    final scrollController = _controller.scrollController;
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final newOffset = (scrollController.offset - dx).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    scrollController.jumpTo(newOffset);
  }

  void _handlePointerUp(PointerEvent event) {
    _releasePointer(event.pointer);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _releasePointer(event.pointer);
  }

  void _releasePointer(int pointer) {
    final midi = _pointerKeys.remove(pointer);
    _pointerDownPositions.remove(pointer);
    _pointerCurrentPositions.remove(pointer);
    _slidOffPointers.remove(pointer);
    if (midi != null) {
      widget.onKeyUp?.call(midi);
    }
    if (_pointerKeys.isEmpty) {
      _isPanning = false;
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final scrollController = _controller.scrollController;
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    final newOffset = (scrollController.offset + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    scrollController.jumpTo(newOffset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyColors = context.pianoKeyColors;
    final whiteKeyWidth = _resolveWhiteKeyWidth();

    return LayoutBuilder(
      builder: (context, constraints) {
        final annotationBarHeight = _annotationBarHeight;
        final expandedRange = expandToWhiteKeyBoundary(widget.range);
        final layout = PianoKeyboardLayout(
          range: expandedRange,
          whiteKeyWidth: whiteKeyWidth,
          height: constraints.maxHeight - annotationBarHeight,
        );
        _layout = layout;

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _handlePointerDown(event, layout),
          onPointerMove: (event) => _handlePointerMove(event, layout),
          onPointerUp: _handlePointerUp,
          onPointerCancel: _handlePointerCancel,
          onPointerSignal: _handlePointerSignal,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _controller.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: CustomPaint(
              size: Size(layout.totalWidth, constraints.maxHeight),
              painter: _PianoKeyboardPainter(
                layout: layout,
                keyVisuals: widget.keyVisuals,
                noteLabelMode: widget.noteLabelMode,
                annotationBarHeight: annotationBarHeight,
                whiteKeyColor: keyColors.whiteKey,
                blackKeyColor: keyColors.blackKey,
                borderColor: theme.colorScheme.outlineVariant,
                whiteLabelColor: theme.colorScheme.onSurface,
                blackLabelColor: Colors.white70,
                annotationBarColor: keyColors.blackKey,
                annotationTextColor: Colors.white70,
                onKeyDown: widget.onKeyDown,
                onKeyUp: widget.onKeyUp,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Renders every key's shape immediately followed by its overlay
/// (`fill` -> `outline` -> `dot` -> static note/MIDI label), white keys
/// first and then black keys, all within a single canvas pass. When
/// [PianoKeyboard.showAnnotations] is enabled, each key's
/// [PianoKeyVisual.label] renders separately in a roof bar above the
/// keys (see [_paintAnnotationBar]), not on the key itself.
///
/// This single-pass ordering is load-bearing, not stylistic: black key
/// rects deliberately overlap into the top of their neighboring white
/// key rects (see [PianoKeyboardLayout]), so a highlighted white key's
/// overlay must be painted *before* any black key is painted, or its
/// fill would sit on top of the black key next to it. Splitting shapes
/// and overlays into two separately-composited `CustomPaint` layers
/// (a `painter` + `foregroundPainter`) breaks this: the whole overlay
/// layer stacks above the whole shape layer, so a white key's overlay
/// would cover an adjacent black key drawn underneath even though the
/// overlay's own internal white-then-black order was correct.
class _PianoKeyboardPainter extends CustomPainter {
  _PianoKeyboardPainter({
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

  final PianoKeyboardLayout layout;
  final ValueListenable<Map<int, PianoKeyVisual>> keyVisuals;
  final NoteLabelMode noteLabelMode;

  /// Height of the roof bar reserved above the keys for [PianoKeyVisual.label]
  /// annotations. Zero when [PianoKeyboard.showAnnotations] is `false`.
  final double annotationBarHeight;
  final Color whiteKeyColor;
  final Color blackKeyColor;
  final Color borderColor;
  final Color whiteLabelColor;
  final Color blackLabelColor;
  final Color annotationBarColor;
  final Color annotationTextColor;
  final void Function(int midiNote)? onKeyDown;
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

  /// Draws the roof bar and each key's [PianoKeyVisual.label], anchored
  /// above that key's x-position instead of on top of the key — this
  /// keeps fingering annotations close to the keys without covering them.
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
      _drawCenteredText(
        canvas,
        text,
        Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * 2 / 3,
          rect.width,
          rect.height / 3,
        ),
        color: isBlack ? blackLabelColor : whiteLabelColor,
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
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize)),
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
  bool shouldRepaint(covariant _PianoKeyboardPainter oldDelegate) => true;

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
