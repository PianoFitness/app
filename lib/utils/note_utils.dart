import 'package:piano/piano.dart';

enum MusicalNote { c, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b }

class NoteInfo {
  final MusicalNote note;
  final int octave;
  final int midiNumber;
  final String displayName;

  const NoteInfo({
    required this.note,
    required this.octave,
    required this.midiNumber,
    required this.displayName,
  });
}

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
    MusicalNote.c: 'C',
    MusicalNote.cSharp: 'C#',
    MusicalNote.d: 'D',
    MusicalNote.dSharp: 'D#',
    MusicalNote.e: 'E',
    MusicalNote.f: 'F',
    MusicalNote.fSharp: 'F#',
    MusicalNote.g: 'G',
    MusicalNote.gSharp: 'G#',
    MusicalNote.a: 'A',
    MusicalNote.aSharp: 'A#',
    MusicalNote.b: 'B',
  };

  static int noteToMidiNumber(MusicalNote note, int octave) {
    final semitone = _noteToSemitone[note]!;
    return (octave + 1) * 12 + semitone;
  }

  static NoteInfo midiNumberToNote(int midiNumber) {
    // Validate MIDI number is within valid range
    if (midiNumber < 0 || midiNumber > 127) {
      throw ArgumentError(
        'MIDI number must be between 0 and 127, got: $midiNumber',
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
        'No note found for semitone $semitone (MIDI: $midiNumber). This should not happen.',
      );
    }

    final note = noteEntry.key;
    final displayName = '${_noteToString[note]}$octave';

    return NoteInfo(
      note: note,
      octave: octave,
      midiNumber: midiNumber,
      displayName: displayName,
    );
  }

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

  static int convertNotePositionToMidi(NotePosition position) {
    int noteOffset;
    switch (position.note) {
      case Note.C:
        noteOffset = 0;
        break;
      case Note.D:
        noteOffset = 2;
        break;
      case Note.E:
        noteOffset = 4;
        break;
      case Note.F:
        noteOffset = 5;
        break;
      case Note.G:
        noteOffset = 7;
        break;
      case Note.A:
        noteOffset = 9;
        break;
      case Note.B:
        noteOffset = 11;
        break;
    }

    if (position.accidental == Accidental.Sharp) {
      noteOffset += 1;
    } else if (position.accidental == Accidental.Flat) {
      noteOffset -= 1;
    }

    return (position.octave + 1) * 12 + noteOffset;
  }

  static String noteDisplayName(MusicalNote note, int octave) {
    return '${_noteToString[note]}$octave';
  }
}
