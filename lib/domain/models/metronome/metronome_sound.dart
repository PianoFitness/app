/// Click sound used for metronome beats.
///
/// Only one audible sound is available today; see
/// docs/specifications/metronome-component.md for the full planned roster
/// (click, wood block, digital beep) once those assets are sourced.
enum MetronomeSound {
  /// The bundled bell click (`assets/audio/218851__kellyconidi__highbell.mp3`).
  bell,

  /// Visual-only mode - no sound is played.
  silent,
}
