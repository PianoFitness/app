/// Controls the widget-level static per-key label shown on [PianoKeyboard].
///
/// This is independent of the per-key [PianoKeyVisual.label] (e.g. a finger
/// number) — both can be shown on the same key at once.
enum NoteLabelMode {
  /// No static label is drawn.
  none,

  /// Show the note's display name, e.g. "C4", "F#3".
  name,

  /// Show the raw MIDI note number, e.g. "60".
  midiNumber,
}
