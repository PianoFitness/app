import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

import "package:piano_fitness/presentation/theme/piano_key_colors.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/midi_note_range.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/note_label_mode.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_key_visual.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_controller.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_geometry.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_painter.dart";

export "package:piano_fitness/presentation/widgets/piano_keyboard/midi_note_range.dart";
export "package:piano_fitness/presentation/widgets/piano_keyboard/note_label_mode.dart";
export "package:piano_fitness/presentation/widgets/piano_keyboard/piano_key_visual.dart";
export "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_controller.dart";
export "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_painter.dart";

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
              painter: PianoKeyboardPainter(
                layout: layout,
                keyVisuals: widget.keyVisuals,
                noteLabelMode: widget.noteLabelMode,
                annotationBarHeight: annotationBarHeight,
                whiteKeyColor: keyColors.whiteKey,
                blackKeyColor: keyColors.blackKey,
                borderColor: theme.colorScheme.outlineVariant,
                whiteLabelColor: keyColors.whiteLabel,
                blackLabelColor: keyColors.blackLabel,
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
