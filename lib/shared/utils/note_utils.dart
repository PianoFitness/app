import "package:piano/piano.dart";
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

/// The twelve chromatic musical notes in Western music.
///
/// This enum represents all semitones in an octave using sharp notation
/// for accidentals. Each note corresponds to a specific semitone offset
/// from C (0 semitones).
enum MusicalNote {
  /// C natural (0 semitones from C)
  c,

  /// C sharp / D flat (1 semitone from C)
  cSharp,

  /// D natural (2 semitones from C)
  d,

  /// D sharp / E flat (3 semitones from C)
  dSharp,

  /// E natural (4 semitones from C)
  e,

  /// F natural (5 semitones from C)
  f,

  /// F sharp / G flat (6 semitones from C)
  fSharp,

  /// G natural (7 semitones from C)
  g,

  /// G sharp / A flat (8 semitones from C)
  gSharp,

  /// A natural (9 semitones from C)
  a,

  /// A sharp / B flat (10 semitones from C)
  aSharp,

  /// B natural (11 semitones from C)
  b,
}

/// Contains comprehensive information about a musical note.
///
/// This class packages together all the different representations of a musical note:
/// the note name, octave, MIDI number, and display string. It's typically used
/// when converting between different note representations.
class NoteInfo {
  /// Creates a NoteInfo with all note representations.
  ///
  /// All parameters are required to ensure complete note information.
  const NoteInfo({
    required this.note,
    required this.octave,
    required this.midiNumber,
    required this.displayName,
  });

  /// The musical note as a MusicalNote enum value.
  final MusicalNote note;

  /// The octave number (typically -1 to 9 for MIDI range).
  final int octave;

  /// The MIDI note number (0-127).
  final int midiNumber;

  /// The human-readable display name (e.g., "C4", "F#3").
  final String displayName;
}

/// Utility class for converting between different musical note representations.
///
/// This class provides static methods to convert between MusicalNote enums,
/// MIDI numbers, NotePosition objects (from the piano package), and display strings.
/// It handles the complex mapping between these different systems.
class NoteUtils {
  static const Map<MusicalNote, int> _noteToSemitone = {
    MusicalNote.c: 0,
    MusicalNote.cSharp: 1,
    MusicalNote.d: 2,
    MusicalNote.dSharp: 3,
    MusicalNote.e: 4,
    MusicalNote.f: 5,
    MusicalNote.fSharp: 6,
    MusicalNote.g: 7,
    MusicalNote.gSharp: 8,
    MusicalNote.a: 9,
    MusicalNote.aSharp: 10,
    MusicalNote.b: 11,
  };

  static const Map<MusicalNote, String> _noteToString = {
    MusicalNote.c: "C",
    MusicalNote.cSharp: "C#",
    MusicalNote.d: "D",
    MusicalNote.dSharp: "D#",
    MusicalNote.e: "E",
    MusicalNote.f: "F",
    MusicalNote.fSharp: "F#",
    MusicalNote.g: "G",
    MusicalNote.gSharp: "G#",
    MusicalNote.a: "A",
    MusicalNote.aSharp: "A#",
    MusicalNote.b: "B",
  };

  /// Converts a MusicalNote and octave to a MIDI note number.
  ///
  /// The [note] parameter specifies which note to convert.
  /// The [octave] parameter follows the standard convention where middle C is C4.
  /// Returns a MIDI note number in the range 0-127.
  ///
  /// Example: `noteToMidiNumber(MusicalNote.c, 4)` returns 60 (middle C).
  static int noteToMidiNumber(MusicalNote note, int octave) {
    final semitone = _noteToSemitone[note]!;
    return (octave + 1) * 12 + semitone;
  }

  /// Converts a MIDI note number to comprehensive note information.
  ///
  /// The [midiNumber] must be in the valid MIDI range (0-127).
  /// Returns a [NoteInfo] object containing the note, octave, MIDI number,
  /// and display name.
  ///
  /// Throws [ArgumentError] if the MIDI number is outside the valid range.
  ///
  /// Example: `midiNumberToNote(60)` returns info for middle C (C4).
  static NoteInfo midiNumberToNote(int midiNumber) {
    // Validate MIDI number is within valid range
    if (midiNumber < 0 || midiNumber > 127) {
      throw ArgumentError(
        "MIDI number must be between 0 and 127, got: $midiNumber",
      );
    }

    final octave = (midiNumber ~/ 12) - 1;
    final semitone = midiNumber % 12;

    // Find the note for this semitone, with fallback for safety
    final noteEntry = _noteToSemitone.entries
        .where((entry) => entry.value == semitone)
        .firstOrNull;

    if (noteEntry == null) {
      throw StateError(
        "No note found for semitone $semitone (MIDI: $midiNumber). This should not happen.",
      );
    }

    final note = noteEntry.key;
    final displayName = "${_noteToString[note]}$octave";

    return NoteInfo(
      note: note,
      octave: octave,
      midiNumber: midiNumber,
      displayName: displayName,
    );
  }

  /// Converts a MusicalNote and octave to a NotePosition for the piano widget.
  ///
  /// This method bridges between the app's internal note representation and
  /// the piano package's NotePosition system. The [note] and [octave] parameters
  /// specify which note to convert.
  ///
  /// Returns a [NotePosition] that can be used with the InteractivePiano widget.
  static NotePosition noteToNotePosition(MusicalNote note, int octave) {
    switch (note) {
      case MusicalNote.c:
        return NotePosition(note: Note.C, octave: octave);
      case MusicalNote.cSharp:
        return NotePosition(
          note: Note.C,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case MusicalNote.d:
        return NotePosition(note: Note.D, octave: octave);
      case MusicalNote.dSharp:
        return NotePosition(
          note: Note.D,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case MusicalNote.e:
        return NotePosition(note: Note.E, octave: octave);
      case MusicalNote.f:
        return NotePosition(note: Note.F, octave: octave);
      case MusicalNote.fSharp:
        return NotePosition(
          note: Note.F,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case MusicalNote.g:
        return NotePosition(note: Note.G, octave: octave);
      case MusicalNote.gSharp:
        return NotePosition(
          note: Note.G,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case MusicalNote.a:
        return NotePosition(note: Note.A, octave: octave);
      case MusicalNote.aSharp:
        return NotePosition(
          note: Note.A,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case MusicalNote.b:
        return NotePosition(note: Note.B, octave: octave);
    }
  }

  /// Converts a NotePosition from the piano widget to a MIDI note number.
  ///
  /// This method converts from the piano package's NotePosition system back
  /// to MIDI note numbers for processing. The [position] parameter contains
  /// the note, octave, and any accidental information.
  ///
  /// Returns a MIDI note number in the range 0-127.
  /// Throws [ArgumentError] if the calculated MIDI number is outside the valid range.
  static int convertNotePositionToMidi(NotePosition position) {
    int noteOffset;
    switch (position.note) {
      case Note.C:
        noteOffset = MusicalConstants.cOffset;
      case Note.D:
        noteOffset = MusicalConstants.dOffset;
      case Note.E:
        noteOffset = MusicalConstants.eOffset;
      case Note.F:
        noteOffset = MusicalConstants.fOffset;
      case Note.G:
        noteOffset = MusicalConstants.gOffset;
      case Note.A:
        noteOffset = MusicalConstants.aOffset;
      case Note.B:
        noteOffset = MusicalConstants.bOffset;
    }

    if (position.accidental == Accidental.Sharp) {
      noteOffset += 1;
    } else if (position.accidental == Accidental.Flat) {
      noteOffset -= 1;
    }

    final midiNumber = (position.octave + 1) * 12 + noteOffset;

    // Validate the calculated MIDI number is within valid range
    if (midiNumber < 0 || midiNumber > 127) {
      throw ArgumentError(
        "Calculated MIDI number $midiNumber is outside valid range (0-127). "
        "Note: ${position.note}, Octave: ${position.octave}, "
        "Accidental: ${position.accidental}",
      );
    }

    return midiNumber;
  }

  /// Converts a MIDI note number to a NotePosition for the piano widget.
  ///
  /// This method provides a direct conversion from MIDI numbers to NotePosition
  /// objects that can be used with the InteractivePiano widget. It combines
  /// [midiNumberToNote] and [noteToNotePosition] into a single operation.
  ///
  /// The [midiNumber] must be in the valid MIDI range (0-127).
  /// Returns null if the MIDI number is outside the valid range.
  ///
  /// Example: `midiNumberToNotePosition(60)` returns NotePosition for middle C.
  static NotePosition? midiNumberToNotePosition(int midiNumber) {
    // Pre-validate MIDI number to avoid exceptions
    if (midiNumber < 0 || midiNumber > 127) {
      return null;
    }

    final noteInfo = midiNumberToNote(midiNumber);
    return noteToNotePosition(noteInfo.note, noteInfo.octave);
  }

  /// Generates a human-readable display name for a musical note.
  ///
  /// The [note] and [octave] parameters specify which note to format.
  /// Returns a string like "C4", "F#3", "Bb2", etc.
  ///
  /// This is commonly used in UI elements to show note names to users.
  static String noteDisplayName(MusicalNote note, int octave) {
    return "${_noteToString[note]}$octave";
  }

  /// Gets a compact note name without octave information.
  ///
  /// This is useful for UI elements where space is limited, such as piano key labels.
  /// The [midiNumber] must be in the valid MIDI range (0-127).
  /// Returns just the note name (e.g., "C", "F#", "A#").
  ///
  /// Throws [ArgumentError] if the MIDI number is outside the valid range.
  ///
  /// Example: `getCompactNoteName(60)` returns "C" (for middle C).
  /// Example: `getCompactNoteName(61)` returns "C#" (for C# above middle C).
  static String getCompactNoteName(int midiNumber) {
    final noteInfo = midiNumberToNote(midiNumber);
    return _noteToString[noteInfo.note]!;
  }

  /// Converts a musical Key to a MusicalNote.
  ///
  /// This is useful when you need to convert a Key enum (used in scales, chords,
  /// and progressions) to a MusicalNote enum (used for arpeggios and MIDI).
  /// Both enums follow the same chromatic ordering (c, cSharp, d, etc.).
  ///
  /// Example: `keyToMusicalNote(music.Key.c)` returns `MusicalNote.c`.
  /// Example: `keyToMusicalNote(music.Key.fSharp)` returns `MusicalNote.fSharp`.
  static MusicalNote keyToMusicalNote(music.Key key) {
    const keyToNote = {
      music.Key.c: MusicalNote.c,
      music.Key.cSharp: MusicalNote.cSharp,
      music.Key.d: MusicalNote.d,
      music.Key.dSharp: MusicalNote.dSharp,
      music.Key.e: MusicalNote.e,
      music.Key.f: MusicalNote.f,
      music.Key.fSharp: MusicalNote.fSharp,
      music.Key.g: MusicalNote.g,
      music.Key.gSharp: MusicalNote.gSharp,
      music.Key.a: MusicalNote.a,
      music.Key.aSharp: MusicalNote.aSharp,
      music.Key.b: MusicalNote.b,
    };

    return keyToNote[key]!;
  }

  /// Converts a musical Key to its corresponding MIDI note number in the base octave.
  ///
  /// This is useful for chord progression calculations where you need the root
  /// note in a specific octave. The [key] parameter specifies which key to convert.
  /// Returns the MIDI note number for that key in the base octave (e.g., C4 = 60).
  ///
  /// Example: `keyToMidiNumber(music.Key.c)` returns 60 (middle C).
  /// Example: `keyToMidiNumber(music.Key.fSharp)` returns 66 (F#4).
  static int keyToMidiNumber(music.Key key) {
    // Map keys to MIDI note numbers (base octave)
    const keyToMidi = {
      music.Key.c: 60,
      music.Key.cSharp: 61, // C#/Db
      music.Key.d: 62,
      music.Key.dSharp: 63, // D#/Eb
      music.Key.e: 64,
      music.Key.f: 65,
      music.Key.fSharp: 66, // F#/Gb
      music.Key.g: 67,
      music.Key.gSharp: 68, // G#/Ab
      music.Key.a: 69,
      music.Key.aSharp: 70, // A#/Bb
      music.Key.b: 71,
    };

    return keyToMidi[key] ?? 60; // Default to C if not found
  }
}
