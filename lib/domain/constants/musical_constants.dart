/// Musical constants used throughout the Piano Fitness app.
///
/// This file centralizes commonly used musical values to eliminate magic numbers
/// and ensure consistency across the codebase.
class MusicalConstants {
  /// Private constructor to prevent instantiation.
  MusicalConstants._();

  /// Base octave for musical references and chord/scale display.
  ///
  /// This corresponds to the octave containing middle C (C4).
  /// Used as the default octave for chord and scale visualization in reference mode,
  /// and as the base for octave calculations throughout the app.
  ///
  /// Example: C4 = MIDI note 60, which is middle C.
  static const int baseOctave = 4;

  /// MIDI note number for middle C (C4).
  ///
  /// This is a commonly used reference point in MIDI and music applications.
  static const int middleC = 60;

  /// Number of semitones in one octave.
  static const int semitonesPerOctave = 12;

  /// Number of notes in a traditional major or minor scale.
  static const int notesPerScale = 7;

  /// Number of notes in a traditional triad chord.
  static const int notesPerTriad = 3;

  /// Number of notes in a seventh chord.
  static const int notesPerSeventhChord = 4;

  // Musical interval constants (in semitones)

  /// Minor second interval (1 semitone).
  static const int minorSecond = 1;

  /// Major second interval (2 semitones).
  static const int majorSecond = 2;

  /// Minor third interval (3 semitones).
  static const int minorThird = 3;

  /// Major third interval (4 semitones).
  static const int majorThird = 4;

  /// Perfect fourth interval (5 semitones).
  static const int perfectFourth = 5;

  /// Tritone interval (6 semitones).
  static const int tritone = 6;

  /// Perfect fifth interval (7 semitones).
  static const int perfectFifth = 7;

  /// Minor sixth interval (8 semitones).
  static const int minorSixth = 8;

  /// Major sixth interval (9 semitones).
  static const int majorSixth = 9;

  /// Minor seventh interval (10 semitones).
  static const int minorSeventh = 10;

  /// Major seventh interval (11 semitones).
  static const int majorSeventh = 11;

  // Note offsets from C (in semitones)

  /// C note offset (0 semitones from C).
  static const int cOffset = 0;

  /// C# note offset (1 semitone from C).
  static const int cSharpOffset = 1;

  /// D note offset (2 semitones from C).
  static const int dOffset = 2;

  /// D# note offset (3 semitones from C).
  static const int dSharpOffset = 3;

  /// E note offset (4 semitones from C).
  static const int eOffset = 4;

  /// F note offset (5 semitones from C).
  static const int fOffset = 5;

  /// F# note offset (6 semitones from C).
  static const int fSharpOffset = 6;

  /// G note offset (7 semitones from C).
  static const int gOffset = 7;

  /// G# note offset (8 semitones from C).
  static const int gSharpOffset = 8;

  /// A note offset (9 semitones from C).
  static const int aOffset = 9;

  /// A# note offset (10 semitones from C).
  static const int aSharpOffset = 10;

  /// B note offset (11 semitones from C).
  static const int bOffset = 11;

  // Display names for musical concepts

  /// Human-readable display names for scale types.
  ///
  /// Maps scale type identifiers to their proper display names.
  static const Map<String, String> scaleTypeNames = {
    "major": "Major",
    "minor": "Minor",
    "dorian": "Dorian",
    "phrygian": "Phrygian",
    "lydian": "Lydian",
    "mixolydian": "Mixolydian",
    "aeolian": "Aeolian",
    "locrian": "Locrian",
  };

  /// Human-readable display names for chord types.
  ///
  /// Maps chord type identifiers to their proper display names.
  static const Map<String, String> chordTypeNames = {
    "major": "Major",
    "minor": "Minor",
    "diminished": "Diminished",
    "augmented": "Augmented",
  };

  /// Human-readable display names for chord inversions.
  ///
  /// Maps inversion identifiers to their proper display names.
  static const Map<String, String> chordInversionNames = {
    "root": "Root Position",
    "first": "1st Inversion",
    "second": "2nd Inversion",
  };
}
