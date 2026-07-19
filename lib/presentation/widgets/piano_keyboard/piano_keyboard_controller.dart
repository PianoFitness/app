import "package:flutter/widgets.dart";

/// Controller for a [PianoKeyboard] that exposes programmatic scrolling.
///
/// Pass an instance to [PianoKeyboard.controller] to call
/// [ensureVisible] from outside the widget (e.g. an exercise engine
/// scrolling the next target key into view) without fighting the
/// widget's internal scroll ownership.
class PianoKeyboardController {
  /// The underlying scroll controller driving the keyboard's horizontal
  /// scroll position.
  final ScrollController scrollController = ScrollController();

  void Function(int midiNote)? _ensureVisibleImpl;

  /// Called by [PianoKeyboard]'s state to attach itself to this controller.
  // ignore: use_setters_to_change_properties
  void attach(void Function(int midiNote) ensureVisibleImpl) {
    _ensureVisibleImpl = ensureVisibleImpl;
  }

  /// Called by [PianoKeyboard]'s state when it is disposed.
  void detach() {
    _ensureVisibleImpl = null;
  }

  /// Scrolls so that [midiNote] is visible within the keyboard's viewport.
  ///
  /// A no-op if no [PianoKeyboard] is currently attached, or if
  /// [midiNote] falls outside the keyboard's current range.
  void ensureVisible(int midiNote) {
    _ensureVisibleImpl?.call(midiNote);
  }

  /// Releases resources held by this controller.
  void dispose() {
    scrollController.dispose();
  }
}
