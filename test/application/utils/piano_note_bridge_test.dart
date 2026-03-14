import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/application/utils/piano_note_bridge.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

void main() {
  group("PianoNoteBridge", () {
    group("noteToNotePosition", () {
      test("should convert natural notes correctly", () {
        final c4 = PianoNoteBridge.noteToNotePosition(MusicalNote.c, 4);
        expect(c4.note, equals(Note.C));
        expect(c4.octave, equals(4));
        expect(c4.accidental, equals(Accidental.None));

        final g4 = PianoNoteBridge.noteToNotePosition(MusicalNote.g, 4);
        expect(g4.note, equals(Note.G));
        expect(g4.octave, equals(4));
        expect(g4.accidental, equals(Accidental.None));
      });

      test("should convert sharp notes correctly", () {
        final cSharp4 = PianoNoteBridge.noteToNotePosition(
          MusicalNote.cSharp,
          4,
        );
        expect(cSharp4.note, equals(Note.C));
        expect(cSharp4.octave, equals(4));
        expect(cSharp4.accidental, equals(Accidental.Sharp));

        final fSharp4 = PianoNoteBridge.noteToNotePosition(
          MusicalNote.fSharp,
          4,
        );
        expect(fSharp4.note, equals(Note.F));
        expect(fSharp4.octave, equals(4));
        expect(fSharp4.accidental, equals(Accidental.Sharp));
      });
    });

    group("convertNotePositionToMidi", () {
      test("should convert natural note positions correctly", () {
        final c4 = NotePosition(note: Note.C);
        expect(PianoNoteBridge.convertNotePositionToMidi(c4), equals(60));

        final g4 = NotePosition(note: Note.G);
        expect(PianoNoteBridge.convertNotePositionToMidi(g4), equals(67));
      });

      test("should convert sharp note positions correctly", () {
        final cSharp4 = NotePosition(
          note: Note.C,
          accidental: Accidental.Sharp,
        );
        expect(PianoNoteBridge.convertNotePositionToMidi(cSharp4), equals(61));

        final fSharp4 = NotePosition(
          note: Note.F,
          accidental: Accidental.Sharp,
        );
        expect(PianoNoteBridge.convertNotePositionToMidi(fSharp4), equals(66));
      });

      test("should convert flat note positions correctly", () {
        final dFlat4 = NotePosition(note: Note.D, accidental: Accidental.Flat);
        expect(
          PianoNoteBridge.convertNotePositionToMidi(dFlat4),
          equals(61),
        ); // Same as C#

        final bFlat4 = NotePosition(note: Note.B, accidental: Accidental.Flat);
        expect(
          PianoNoteBridge.convertNotePositionToMidi(bFlat4),
          equals(70),
        ); // Same as A#
      });
    });

    group("midiNumberToNotePosition", () {
      test("should convert basic MIDI numbers to NotePosition", () {
        // Test middle C
        final c4 = PianoNoteBridge.midiNumberToNotePosition(60);
        expect(c4, isNotNull);
        expect(c4?.note, equals(Note.C));
        expect(c4?.octave, equals(4));
        expect(c4?.accidental, equals(Accidental.None));

        // Test A4
        final a4 = PianoNoteBridge.midiNumberToNotePosition(69);
        expect(a4, isNotNull);
        expect(a4?.note, equals(Note.A));
        expect(a4?.octave, equals(4));
        expect(a4?.accidental, equals(Accidental.None));
      });

      test("should convert sharp notes correctly", () {
        // Test C#4
        final cSharp4 = PianoNoteBridge.midiNumberToNotePosition(61);
        expect(cSharp4?.note, equals(Note.C));
        expect(cSharp4?.octave, equals(4));
        expect(cSharp4?.accidental, equals(Accidental.Sharp));

        // Test F#4
        final fSharp4 = PianoNoteBridge.midiNumberToNotePosition(66);
        expect(fSharp4?.note, equals(Note.F));
        expect(fSharp4?.octave, equals(4));
        expect(fSharp4?.accidental, equals(Accidental.Sharp));

        // Test A#4
        final aSharp4 = PianoNoteBridge.midiNumberToNotePosition(70);
        expect(aSharp4?.note, equals(Note.A));
        expect(aSharp4?.octave, equals(4));
        expect(aSharp4?.accidental, equals(Accidental.Sharp));
      });

      test("should handle different octaves", () {
        // Test C in different octaves
        final c0 = PianoNoteBridge.midiNumberToNotePosition(12);
        expect(c0?.note, equals(Note.C));
        expect(c0?.octave, equals(0));

        final c1 = PianoNoteBridge.midiNumberToNotePosition(24);
        expect(c1?.note, equals(Note.C));
        expect(c1?.octave, equals(1));

        final c2 = PianoNoteBridge.midiNumberToNotePosition(36);
        expect(c2?.note, equals(Note.C));
        expect(c2?.octave, equals(2));

        final c6 = PianoNoteBridge.midiNumberToNotePosition(84);
        expect(c6?.note, equals(Note.C));
        expect(c6?.octave, equals(6));
      });

      test("should handle extreme MIDI ranges", () {
        // Test lowest MIDI note (C-1)
        final lowestC = PianoNoteBridge.midiNumberToNotePosition(0);
        expect(lowestC?.note, equals(Note.C));
        expect(lowestC?.octave, equals(-1));

        // Test highest MIDI note (G9)
        final highestG = PianoNoteBridge.midiNumberToNotePosition(127);
        expect(highestG?.note, equals(Note.G));
        expect(highestG?.octave, equals(9));

        // Test 88-key piano range boundaries
        final a0 = PianoNoteBridge.midiNumberToNotePosition(
          21,
        ); // A0 - lowest piano key
        expect(a0?.note, equals(Note.A));
        expect(a0?.octave, equals(0));

        final c8 = PianoNoteBridge.midiNumberToNotePosition(
          108,
        ); // C8 - highest piano key
        expect(c8?.note, equals(Note.C));
        expect(c8?.octave, equals(8));
      });

      test("should return null for invalid MIDI numbers", () {
        expect(PianoNoteBridge.midiNumberToNotePosition(-1), isNull);
        expect(PianoNoteBridge.midiNumberToNotePosition(128), isNull);
        expect(PianoNoteBridge.midiNumberToNotePosition(200), isNull);
        expect(PianoNoteBridge.midiNumberToNotePosition(-100), isNull);
      });

      test("should handle all chromatic notes in an octave", () {
        // Test all 12 semitones in octave 4
        final expectedNotes = [
          (Note.C, Accidental.None), // MIDI 60
          (Note.C, Accidental.Sharp), // MIDI 61
          (Note.D, Accidental.None), // MIDI 62
          (Note.D, Accidental.Sharp), // MIDI 63
          (Note.E, Accidental.None), // MIDI 64
          (Note.F, Accidental.None), // MIDI 65
          (Note.F, Accidental.Sharp), // MIDI 66
          (Note.G, Accidental.None), // MIDI 67
          (Note.G, Accidental.Sharp), // MIDI 68
          (Note.A, Accidental.None), // MIDI 69
          (Note.A, Accidental.Sharp), // MIDI 70
          (Note.B, Accidental.None), // MIDI 71
        ];

        for (var i = 0; i < 12; i++) {
          final midiNumber = 60 + i; // C4 to B4
          final notePos = PianoNoteBridge.midiNumberToNotePosition(midiNumber);
          final expected = expectedNotes[i];

          expect(
            notePos?.note,
            equals(expected.$1),
            reason: "MIDI $midiNumber should be ${expected.$1}",
          );
          expect(
            notePos?.accidental,
            equals(expected.$2),
            reason: "MIDI $midiNumber should have accidental ${expected.$2}",
          );
          expect(
            notePos?.octave,
            equals(4),
            reason: "MIDI $midiNumber should be in octave 4",
          );
        }
      });
    });

    group("Bidirectional conversion", () {
      test("MIDI to NotePosition and back should be consistent", () {
        for (var midi = 0; midi <= 127; midi++) {
          final notePos = PianoNoteBridge.midiNumberToNotePosition(midi);
          expect(
            notePos,
            isNotNull,
            reason: "MIDI $midi should convert to valid NotePosition",
          );

          if (notePos != null) {
            final convertedBack = PianoNoteBridge.convertNotePositionToMidi(
              notePos,
            );
            expect(
              convertedBack,
              equals(midi),
              reason:
                  "MIDI $midi -> NotePosition -> $convertedBack should be consistent",
            );
          }
        }
      });

      test("NotePosition to MIDI to NotePosition should be consistent", () {
        final testCases = [
          NotePosition(note: Note.C),
          NotePosition(note: Note.C, accidental: Accidental.Sharp),
          NotePosition(note: Note.D),
          NotePosition(note: Note.D, accidental: Accidental.Sharp),
          NotePosition(note: Note.E),
          NotePosition(note: Note.F),
          NotePosition(note: Note.F, accidental: Accidental.Sharp),
          NotePosition(note: Note.G),
          NotePosition(note: Note.G, accidental: Accidental.Sharp),
          NotePosition(note: Note.A),
          NotePosition(note: Note.A, accidental: Accidental.Sharp),
          NotePosition(note: Note.B),
          // Test different octaves
          NotePosition(note: Note.C, octave: 0),
          NotePosition(note: Note.C, octave: 8),
          NotePosition(note: Note.A, octave: 0),
        ];

        // Special test cases for flat notes (which convert to sharp equivalents)
        final flatToSharpEquivalents = [
          (
            NotePosition(note: Note.D, accidental: Accidental.Flat),
            NotePosition(note: Note.C, accidental: Accidental.Sharp),
          ),
          (
            NotePosition(note: Note.B, accidental: Accidental.Flat),
            NotePosition(note: Note.A, accidental: Accidental.Sharp),
          ),
        ];

        // Test normal cases where the conversion should be identical
        for (final originalPos in testCases) {
          final midi = PianoNoteBridge.convertNotePositionToMidi(originalPos);
          final convertedPos = PianoNoteBridge.midiNumberToNotePosition(midi);

          expect(
            convertedPos,
            isNotNull,
            reason:
                "NotePosition ${originalPos.note}${originalPos.octave} should convert to valid MIDI and back",
          );

          if (convertedPos != null) {
            expect(convertedPos.note, equals(originalPos.note));
            expect(convertedPos.octave, equals(originalPos.octave));
            expect(convertedPos.accidental, equals(originalPos.accidental));
          }
        }

        // Test flat note equivalents (they should convert to their sharp equivalents)
        for (final (flatNote, expectedSharpNote) in flatToSharpEquivalents) {
          final midi = PianoNoteBridge.convertNotePositionToMidi(flatNote);
          final convertedPos = PianoNoteBridge.midiNumberToNotePosition(midi);

          expect(
            convertedPos,
            isNotNull,
            reason:
                "Flat note ${flatNote.note}${flatNote.octave} should convert to valid MIDI and back",
          );

          if (convertedPos != null) {
            expect(
              convertedPos.note,
              equals(expectedSharpNote.note),
              reason:
                  "${flatNote.note}♭ should convert to ${expectedSharpNote.note}♯",
            );
            expect(convertedPos.octave, equals(expectedSharpNote.octave));
            expect(
              convertedPos.accidental,
              equals(expectedSharpNote.accidental),
              reason:
                  "${flatNote.note}♭ should convert to ${expectedSharpNote.note}♯",
            );
          }
        }
      });
    });
  });
}
