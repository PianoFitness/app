/// Relative emphasis of a metronome beat within a measure.
///
/// Drives both playback volume and the size of the visual pulse.
enum BeatEmphasis {
  /// Downbeat - highest volume/pulse size.
  strong(1),

  /// Secondary accent (e.g. beat 3 in 4/4).
  medium(0.7),

  /// Regular beat - lowest volume/pulse size.
  weak(0.4);

  const BeatEmphasis(this.intensity);

  /// Volume multiplier in the 0.0-1.0 range.
  final double intensity;
}
