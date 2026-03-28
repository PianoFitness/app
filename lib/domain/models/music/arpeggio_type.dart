/// The different types of arpeggio chord qualities supported by Piano Fitness.
///
/// Each type represents a different chord structure that creates unique
/// harmonic sounds when played as broken chords (arpeggios).
enum ArpeggioType {
  /// Major arpeggio (1-3-5-8) - bright, happy sound
  major,

  /// Minor arpeggio (1-♭3-5-8) - darker, more melancholic sound
  minor,

  /// Diminished arpeggio (1-♭3-♭5-8) - tense, unstable sound
  diminished,

  /// Augmented arpeggio (1-3-#5-8) - mysterious, dreamy sound
  augmented,

  /// Dominant 7th arpeggio (1-3-5-♭7-8) - jazzy, bluesy sound
  dominant7,

  /// Minor 7th arpeggio (1-♭3-5-♭7-8) - smooth, jazzy minor sound
  minor7,

  /// Major 7th arpeggio (1-3-5-7-8) - sophisticated, jazzy major sound
  major7,
}

/// The octave range options for arpeggio exercises.
///
/// Determines how many octaves the arpeggio pattern spans,
/// affecting both difficulty and musical range.
enum ArpeggioOctaves {
  /// Single octave arpeggio - easier, more focused
  one,

  /// Two octave arpeggio - more challenging, greater range
  two,
}
