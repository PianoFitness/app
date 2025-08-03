import 'package:flutter_test/flutter_test.dart';
import 'package:piano/piano.dart';
import 'package:piano_fitness/utils/note_utils.dart';

void main() {
  group('NoteUtils', () {
    group('noteToMidiNumber', () {
      test('should convert C4 correctly', () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 4), equals(60));
      });

      test('should convert A4 correctly', () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.a, 4), equals(69));
      });

      test('should handle chromatic notes', () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.cSharp, 4), equals(61));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.fSharp, 4), equals(66));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.aSharp, 4), equals(70));
      });

      test('should handle different octaves', () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 0), equals(12));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 1), equals(24));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 2), equals(36));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 3), equals(48));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 5), equals(72));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 6), equals(84));
      });
    });

    group('midiNumberToNote', () {
      test('should convert MIDI 60 to C4', () {
        final note = NoteUtils.midiNumberToNote(60);
        expect(note.note, equals(MusicalNote.c));
        expect(note.octave, equals(4));
        expect(note.midiNumber, equals(60));
        expect(note.displayName, equals('C4'));
      });

      test('should convert MIDI 69 to A4', () {
        final note = NoteUtils.midiNumberToNote(69);
        expect(note.note, equals(MusicalNote.a));
        expect(note.octave, equals(4));
        expect(note.midiNumber, equals(69));
        expect(note.displayName, equals('A4'));
      });

      test('should handle chromatic notes', () {
        final cSharp = NoteUtils.midiNumberToNote(61);
        expect(cSharp.note, equals(MusicalNote.cSharp));
        expect(cSharp.displayName, equals('C#4'));

        final fSharp = NoteUtils.midiNumberToNote(66);
        expect(fSharp.note, equals(MusicalNote.fSharp));
        expect(fSharp.displayName, equals('F#4'));

        final aSharp = NoteUtils.midiNumberToNote(70);
        expect(aSharp.note, equals(MusicalNote.aSharp));
        expect(aSharp.displayName, equals('A#4'));
      });

      test('should handle extreme ranges', () {
        final lowC = NoteUtils.midiNumberToNote(0);
        expect(lowC.note, equals(MusicalNote.c));
        expect(lowC.octave, equals(-1));

        final highG = NoteUtils.midiNumberToNote(127);
        expect(highG.note, equals(MusicalNote.g));
        expect(highG.octave, equals(9));
      });
    });

    group('noteToNotePosition', () {
      test('should convert natural notes correctly', () {
        final c4 = NoteUtils.noteToNotePosition(MusicalNote.c, 4);
        expect(c4.note, equals(Note.C));
        expect(c4.octave, equals(4));
        expect(c4.accidental, equals(Accidental.None));

        final g4 = NoteUtils.noteToNotePosition(MusicalNote.g, 4);
        expect(g4.note, equals(Note.G));
        expect(g4.octave, equals(4));
        expect(g4.accidental, equals(Accidental.None));
      });

      test('should convert sharp notes correctly', () {
        final cSharp4 = NoteUtils.noteToNotePosition(MusicalNote.cSharp, 4);
        expect(cSharp4.note, equals(Note.C));
        expect(cSharp4.octave, equals(4));
        expect(cSharp4.accidental, equals(Accidental.Sharp));

        final fSharp4 = NoteUtils.noteToNotePosition(MusicalNote.fSharp, 4);
        expect(fSharp4.note, equals(Note.F));
        expect(fSharp4.octave, equals(4));
        expect(fSharp4.accidental, equals(Accidental.Sharp));
      });
    });

    group('convertNotePositionToMidi', () {
      test('should convert natural note positions correctly', () {
        final c4 = NotePosition(note: Note.C, octave: 4);
        expect(NoteUtils.convertNotePositionToMidi(c4), equals(60));

        final g4 = NotePosition(note: Note.G, octave: 4);
        expect(NoteUtils.convertNotePositionToMidi(g4), equals(67));
      });

      test('should convert sharp note positions correctly', () {
        final cSharp4 = NotePosition(
          note: Note.C,
          octave: 4,
          accidental: Accidental.Sharp,
        );
        expect(NoteUtils.convertNotePositionToMidi(cSharp4), equals(61));

        final fSharp4 = NotePosition(
          note: Note.F,
          octave: 4,
          accidental: Accidental.Sharp,
        );
        expect(NoteUtils.convertNotePositionToMidi(fSharp4), equals(66));
      });

      test('should convert flat note positions correctly', () {
        final dFlat4 = NotePosition(
          note: Note.D,
          octave: 4,
          accidental: Accidental.Flat,
        );
        expect(
          NoteUtils.convertNotePositionToMidi(dFlat4),
          equals(61),
        ); // Same as C#

        final bFlat4 = NotePosition(
          note: Note.B,
          octave: 4,
          accidental: Accidental.Flat,
        );
        expect(
          NoteUtils.convertNotePositionToMidi(bFlat4),
          equals(70),
        ); // Same as A#
      });
    });

    group('noteDisplayName', () {
      test('should format note names correctly', () {
        expect(NoteUtils.noteDisplayName(MusicalNote.c, 4), equals('C4'));
        expect(NoteUtils.noteDisplayName(MusicalNote.cSharp, 4), equals('C#4'));
        expect(NoteUtils.noteDisplayName(MusicalNote.fSharp, 2), equals('F#2'));
        expect(NoteUtils.noteDisplayName(MusicalNote.b, 6), equals('B6'));
      });
    });

    group('Bidirectional conversion', () {
      test('MIDI to note and back should be consistent', () {
        for (int midi = 0; midi <= 127; midi++) {
          final noteInfo = NoteUtils.midiNumberToNote(midi);
          final convertedBack = NoteUtils.noteToMidiNumber(
            noteInfo.note,
            noteInfo.octave,
          );
          expect(
            convertedBack,
            equals(midi),
            reason: 'MIDI $midi -> ${noteInfo.displayName} -> $convertedBack',
          );
        }
      });

      test('Note to MIDI and back should be consistent', () {
        for (final note in MusicalNote.values) {
          for (int octave = 0; octave <= 9; octave++) {
            final midi = NoteUtils.noteToMidiNumber(note, octave);
            if (midi >= 0 && midi <= 127) {
              final noteInfo = NoteUtils.midiNumberToNote(midi);
              expect(noteInfo.note, equals(note));
              expect(noteInfo.octave, equals(octave));
            }
          }
        }
      });
    });
  });
}
