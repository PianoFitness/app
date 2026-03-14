import "package:piano/piano.dart";
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// Bridges between the app's internal note representation and the piano
/// package's [NotePosition] system.
///
/// These methods live in the application layer (not domain) because they
/// depend on [package:piano], a Flutter package.  Domain code represents
/// notes as [MusicalNote] + octave or raw MIDI numbers; conversion to or
/// from [NotePosition] is an infrastructure concern and belongs here.
class PianoNoteBridge {
  PianoNoteBridge._();

  /// Converts a [MusicalNote] and octave to a [NotePosition] for the piano widget.
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

  /// Converts a [NotePosition] from the piano widget to a MIDI note number.
  ///
  /// Throws [ArgumentError] if the calculated MIDI number is outside 0–127.
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

    if (midiNumber < 0 || midiNumber > 127) {
      throw ArgumentError(
        "Calculated MIDI number $midiNumber is outside valid range (0-127). "
        "Note: ${position.note}, Octave: ${position.octave}, "
        "Accidental: ${position.accidental}",
      );
    }

    return midiNumber;
  }

  /// Converts a MIDI note number to a [NotePosition] for the piano widget.
  ///
  /// Returns `null` if [midiNumber] is outside the valid range (0–127).
  static NotePosition? midiNumberToNotePosition(int midiNumber) {
    if (midiNumber < 0 || midiNumber > 127) {
      return null;
    }
    final noteInfo = NoteUtils.midiNumberToNote(midiNumber);
    return noteToNotePosition(noteInfo.note, noteInfo.octave);
  }
}
