import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// An immutable value object representing a MIDI note.
///
/// MIDI (Musical Instrument Digital Interface) notes are represented as integers
/// from 0 to 127, where:
/// - MIDI 0 = C-1 (lowest possible note)
/// - MIDI 60 = C4 (middle C)
/// - MIDI 127 = G9 (highest possible note)
///
/// This value object wraps the raw MIDI number and provides domain-specific
/// operations and properties for music theory calculations, particularly
/// voice leading.
///
/// ## Usage
///
/// ```dart
/// // Create from MIDI number
/// final middleC = MidiNote(60);
/// final a440 = MidiNote(69);
///
/// // Create from musical note and octave
/// final g4 = MidiNote.fromNote(MusicalNote.g, 4);
/// final fSharp3 = MidiNote.fromNote(MusicalNote.fSharp, 3);
///
/// // Access properties
/// print(middleC.pitchClass);   // 0 (C)
/// print(middleC.octave);       // 4
/// print(middleC.displayName);  // "C4"
/// print(middleC.noteName);     // "C"
///
/// // Voice leading operations
/// final distance = middleC.distanceTo(g4);  // 7 semitones
/// final sameClass = middleC.hasSamePitchClass(MidiNote(72));  // true (both C)
/// ```
///
/// ## Equality and Hashing
///
/// Two MidiNote instances are equal if they have the same MIDI value.
/// This allows them to be used in Sets and as Map keys:
///
/// ```dart
/// final note1 = MidiNote(60);
/// final note2 = MidiNote(60);
/// print(note1 == note2);  // true
///
/// final noteSet = {MidiNote(60), MidiNote(60), MidiNote(62)};
/// print(noteSet.length);  // 2 (duplicates removed)
/// ```
class MidiNote {
  /// Creates a MIDI note from a raw MIDI number.
  ///
  /// The [value] must be in the valid MIDI range (0-127).
  ///
  /// Throws [ArgumentError] if the value is outside the valid range.
  const MidiNote(this.value)
    : assert(
        value >= 0 && value <= 127,
        "MIDI note value must be between 0 and 127",
      );

  /// Creates a MIDI note from a musical note and octave.
  ///
  /// The [note] specifies the pitch class (C, C#, D, etc.).
  /// The [octave] follows the standard convention where middle C is C4.
  ///
  /// Example:
  /// ```dart
  /// final middleC = MidiNote.fromNote(MusicalNote.c, 4);  // MIDI 60
  /// final a440 = MidiNote.fromNote(MusicalNote.a, 4);    // MIDI 69
  /// ```
  factory MidiNote.fromNote(MusicalNote note, int octave) {
    return MidiNote(NoteUtils.noteToMidiNumber(note, octave));
  }

  /// The raw MIDI note number (0-127).
  final int value;

  /// The pitch class of this note (0-11).
  ///
  /// Returns the note's position within the chromatic scale:
  /// - 0 = C
  /// - 1 = C#
  /// - 2 = D
  /// - 3 = D#
  /// - 4 = E
  /// - 5 = F
  /// - 6 = F#
  /// - 7 = G
  /// - 8 = G#
  /// - 9 = A
  /// - 10 = A#
  /// - 11 = B
  ///
  /// All notes with the same pitch class sound like the same note at different
  /// octaves. For example, MIDI 60 (C4), 72 (C5), and 48 (C3) all have
  /// pitch class 0.
  int get pitchClass => value % 12;

  /// The octave of this note.
  ///
  /// Returns the octave number following the standard convention where:
  /// - Octave -1: MIDI 0-11 (C-1 to B-1)
  /// - Octave 0: MIDI 12-23 (C0 to B0)
  /// - Octave 4: MIDI 60-71 (C4 to B4, contains middle C)
  /// - Octave 9: MIDI 120-127 (C9 to G9)
  int get octave => (value ~/ 12) - 1;

  /// The musical note as a MusicalNote enum value.
  ///
  /// This extracts the pitch class and converts it to the corresponding
  /// MusicalNote enum (C, C#, D, etc.).
  MusicalNote get musicalNote {
    return NoteUtils.midiNumberToNote(value).note;
  }

  /// The full display name including octave (e.g., "C4", "F#3", "A#5").
  ///
  /// This is commonly used in UI elements to show note names to users.
  String get displayName {
    return NoteUtils.midiNumberToNote(value).displayName;
  }

  /// The compact note name without octave (e.g., "C", "F#", "A#").
  ///
  /// This is useful for displaying note names where space is limited,
  /// such as piano key labels.
  String get noteName {
    return NoteUtils.getCompactNoteName(value);
  }

  /// Calculates the distance in semitones to another note.
  ///
  /// Returns the absolute difference between the two MIDI values.
  /// This is useful for voice leading calculations.
  ///
  /// Example:
  /// ```dart
  /// final c4 = MidiNote(60);
  /// final g4 = MidiNote(67);
  /// print(c4.distanceTo(g4));  // 7 semitones
  /// ```
  int distanceTo(MidiNote other) {
    return (value - other.value).abs();
  }

  /// Checks if this note has the same pitch class as another note.
  ///
  /// Returns true if both notes are the same letter name at different octaves
  /// (e.g., C4 and C5 both have pitch class 0).
  ///
  /// This is essential for voice leading, where we need to identify common
  /// tones between chords regardless of their octave.
  ///
  /// Example:
  /// ```dart
  /// final c4 = MidiNote(60);
  /// final c5 = MidiNote(72);
  /// final d4 = MidiNote(62);
  /// print(c4.hasSamePitchClass(c5));  // true
  /// print(c4.hasSamePitchClass(d4));  // false
  /// ```
  bool hasSamePitchClass(MidiNote other) {
    return pitchClass == other.pitchClass;
  }

  /// Transposes this note by a number of semitones.
  ///
  /// Returns a new MidiNote that is [semitones] higher (positive) or
  /// lower (negative) than this note.
  ///
  /// Throws [ArgumentError] if the transposition would result in a MIDI
  /// value outside the valid range (0-127).
  ///
  /// Example:
  /// ```dart
  /// final c4 = MidiNote(60);
  /// final g4 = c4.transpose(7);   // Perfect fifth up
  /// final f3 = c4.transpose(-7);  // Perfect fifth down
  /// ```
  MidiNote transpose(int semitones) {
    final newValue = value + semitones;
    if (newValue < 0 || newValue > 127) {
      throw ArgumentError(
        "Transposition of $value by $semitones semitones "
        "results in $newValue, which is outside MIDI range (0-127)",
      );
    }
    return MidiNote(newValue);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MidiNote &&
            runtimeType == other.runtimeType &&
            value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => "MidiNote($value, $displayName)";

  /// Convenient factory constructors for common notes (middle octave, octave 4)

  /// C4 (middle C) - MIDI 60
  static const c4 = MidiNote(60);

  /// C#4 - MIDI 61
  static const cSharp4 = MidiNote(61);

  /// D4 - MIDI 62
  static const d4 = MidiNote(62);

  /// D#4 - MIDI 63
  static const dSharp4 = MidiNote(63);

  /// E4 - MIDI 64
  static const e4 = MidiNote(64);

  /// F4 - MIDI 65
  static const f4 = MidiNote(65);

  /// F#4 - MIDI 66
  static const fSharp4 = MidiNote(66);

  /// G4 - MIDI 67
  static const g4 = MidiNote(67);

  /// G#4 - MIDI 68
  static const gSharp4 = MidiNote(68);

  /// A4 (concert pitch, 440 Hz) - MIDI 69
  static const a4 = MidiNote(69);

  /// A#4 - MIDI 70
  static const aSharp4 = MidiNote(70);

  /// B4 - MIDI 71
  static const b4 = MidiNote(71);
}

/// Extension on List<MidiNote> to provide collection-level operations.
extension MidiNoteList on List<MidiNote> {
  /// Extracts the raw MIDI values from a list of MidiNotes.
  ///
  /// This is useful at the boundary between the domain layer and
  /// infrastructure (MIDI I/O), where raw integers are required.
  ///
  /// Example:
  /// ```dart
  /// final notes = [MidiNote.c4, MidiNote.e4, MidiNote.g4];
  /// final midiValues = notes.values;  // [60, 64, 67]
  /// midiService.sendNotes(midiValues);
  /// ```
  List<int> get values => map((note) => note.value).toList();

  /// Gets the lowest (minimum MIDI value) note in the list.
  ///
  /// Throws [StateError] if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// final chord = [MidiNote(60), MidiNote(64), MidiNote(67)];
  /// print(chord.lowest);  // MidiNote(60, C4)
  /// ```
  MidiNote get lowest => reduce((a, b) => a.value < b.value ? a : b);

  /// Gets the highest (maximum MIDI value) note in the list.
  ///
  /// Throws [StateError] if the list is empty.
  ///
  /// Example:
  /// ```dart
  /// final chord = [MidiNote(60), MidiNote(64), MidiNote(67)];
  /// print(chord.highest);  // MidiNote(67, G4)
  /// ```
  MidiNote get highest => reduce((a, b) => a.value > b.value ? a : b);

  /// Gets all unique pitch classes in this list of notes.
  ///
  /// Returns a Set of integers (0-11) representing the distinct pitch
  /// classes, ignoring octave information.
  ///
  /// Example:
  /// ```dart
  /// final notes = [MidiNote(60), MidiNote(72), MidiNote(64)];
  /// print(notes.pitchClasses);  // {0, 4} (C and E, ignoring octaves)
  /// ```
  Set<int> get pitchClasses => map((note) => note.pitchClass).toSet();
}

/// Extension on List<int> to convert raw MIDI numbers to MidiNote objects.
extension MidiNumberList on List<int> {
  /// Converts a list of raw MIDI numbers to MidiNote objects.
  ///
  /// Throws [ArgumentError] if any value is outside the valid MIDI range (0-127).
  ///
  /// Example:
  /// ```dart
  /// final midiValues = [60, 64, 67];
  /// final notes = midiValues.toMidiNotes();  // [MidiNote.c4, MidiNote.e4, MidiNote.g4]
  /// ```
  List<MidiNote> toMidiNotes() => map(MidiNote.new).toList();
}
