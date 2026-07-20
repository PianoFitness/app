/// The chunk-generation pattern shared by Arpeggios (broken) and Block
/// Chords (blocked) modes.
///
/// See `domain/services/music_theory/tone_pattern.dart` for the generator
/// that turns a pattern into chord-tone degree tokens.
enum ChordTonePattern {
  /// Each chord-tone group restarts on the root, one octave higher than
  /// the last.
  straight,

  /// Each chord-tone group starts one chord tone further around the cycle
  /// than the last, continuously rotating through inversions while
  /// climbing.
  rolling,
}
