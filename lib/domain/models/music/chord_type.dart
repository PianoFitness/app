/// The different chord qualities supported for chord practice.
///
/// Each type represents a different harmonic structure with its own
/// characteristic sound and theoretical function.
enum ChordType {
  /// Major chord - bright, stable sound (1-3-5)
  major,

  /// Minor chord - darker, more melancholic sound (1-♭3-5)
  minor,

  /// Diminished chord - tense, unstable sound (1-♭3-♭5)
  diminished,

  /// Augmented chord - mysterious, floating sound (1-3-#5)
  augmented,

  /// Major seventh chord - bright, jazzy sound (1-3-5-7)
  major7,

  /// Dominant seventh chord - bluesy, tension-seeking sound (1-3-5-♭7)
  dominant7,

  /// Minor seventh chord - smooth, mellow sound (1-♭3-5-♭7)
  minor7,

  /// Half-diminished seventh chord - jazzy, ambiguous sound (1-♭3-♭5-♭7)
  halfDiminished7,

  /// Fully diminished seventh chord - intense, dramatic sound (1-♭3-♭5-♭♭7)
  diminished7,

  /// Minor-major seventh chord - haunting, mysterious sound (1-♭3-5-7)
  minorMajor7,

  /// Augmented seventh chord - exotic, unstable sound (1-3-#5-♭7)
  augmented7,
}

/// Extension methods for ChordType to provide consistent display names.
extension ChordTypeDisplay on ChordType {
  /// Returns the short display name for the chord type (e.g., "Major").
  String get shortName {
    switch (this) {
      case ChordType.major:
        return "Major";
      case ChordType.minor:
        return "Minor";
      case ChordType.diminished:
        return "Diminished";
      case ChordType.augmented:
        return "Augmented";
      case ChordType.major7:
        return "Major 7th";
      case ChordType.dominant7:
        return "Dominant 7th";
      case ChordType.minor7:
        return "Minor 7th";
      case ChordType.halfDiminished7:
        return "Half-Diminished 7th";
      case ChordType.diminished7:
        return "Diminished 7th";
      case ChordType.minorMajor7:
        return "Minor-Major 7th";
      case ChordType.augmented7:
        return "Augmented 7th";
    }
  }

  /// Returns the long display name for the chord type (e.g., "Major Chords").
  String get longName {
    switch (this) {
      case ChordType.major:
        return "Major Chords";
      case ChordType.minor:
        return "Minor Chords";
      case ChordType.diminished:
        return "Diminished Chords";
      case ChordType.augmented:
        return "Augmented Chords";
      case ChordType.major7:
        return "Major 7th Chords";
      case ChordType.dominant7:
        return "Dominant 7th Chords";
      case ChordType.minor7:
        return "Minor 7th Chords";
      case ChordType.halfDiminished7:
        return "Half-Diminished 7th Chords";
      case ChordType.diminished7:
        return "Diminished 7th Chords";
      case ChordType.minorMajor7:
        return "Minor-Major 7th Chords";
      case ChordType.augmented7:
        return "Augmented 7th Chords";
    }
  }

  /// Returns true if this chord type is a seventh chord (4 notes).
  bool get isSeventhChord {
    switch (this) {
      case ChordType.major:
      case ChordType.minor:
      case ChordType.diminished:
      case ChordType.augmented:
        return false;
      case ChordType.major7:
      case ChordType.dominant7:
      case ChordType.minor7:
      case ChordType.halfDiminished7:
      case ChordType.diminished7:
      case ChordType.minorMajor7:
      case ChordType.augmented7:
        return true;
    }
  }
}

/// The different inversions available for chord practice.
///
/// Inversions change the bass note of the chord while preserving
/// the harmony, creating smoother voice leading in progressions.
enum ChordInversion {
  /// Root position - root note in bass
  root,

  /// First inversion - third in bass
  first,

  /// Second inversion - fifth in bass
  second,

  /// Third inversion - seventh in bass (for seventh chords only)
  third,
}
