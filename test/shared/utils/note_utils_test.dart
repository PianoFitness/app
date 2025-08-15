import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";

void main() {
  group("NoteUtils", () {
    group("noteToMidiNumber", () {
      test("should convert C4 correctly", () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 4), equals(60));
      });

      test("should convert A4 correctly", () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.a, 4), equals(69));
      });

      test("should handle chromatic notes", () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.cSharp, 4), equals(61));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.fSharp, 4), equals(66));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.aSharp, 4), equals(70));
      });

      test("should handle different octaves", () {
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 0), equals(12));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 1), equals(24));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 2), equals(36));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 3), equals(48));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 5), equals(72));
        expect(NoteUtils.noteToMidiNumber(MusicalNote.c, 6), equals(84));
      });
    });

    group("midiNumberToNote", () {
      test("should convert MIDI 60 to C4", () {
        final note = NoteUtils.midiNumberToNote(60);
        expect(note.note, equals(MusicalNote.c));
        expect(note.octave, equals(4));
        expect(note.midiNumber, equals(60));
        expect(note.displayName, equals("C4"));
      });

      test("should convert MIDI 69 to A4", () {
        final note = NoteUtils.midiNumberToNote(69);
        expect(note.note, equals(MusicalNote.a));
        expect(note.octave, equals(4));
        expect(note.midiNumber, equals(69));
        expect(note.displayName, equals("A4"));
      });

      test("should handle chromatic notes", () {
        final cSharp = NoteUtils.midiNumberToNote(61);
        expect(cSharp.note, equals(MusicalNote.cSharp));
        expect(cSharp.displayName, equals("C#4"));

        final fSharp = NoteUtils.midiNumberToNote(66);
        expect(fSharp.note, equals(MusicalNote.fSharp));
        expect(fSharp.displayName, equals("F#4"));

        final aSharp = NoteUtils.midiNumberToNote(70);
        expect(aSharp.note, equals(MusicalNote.aSharp));
        expect(aSharp.displayName, equals("A#4"));
      });

      test("should handle extreme ranges", () {
        final lowC = NoteUtils.midiNumberToNote(0);
        expect(lowC.note, equals(MusicalNote.c));
        expect(lowC.octave, equals(-1));

        final highG = NoteUtils.midiNumberToNote(127);
        expect(highG.note, equals(MusicalNote.g));
        expect(highG.octave, equals(9));
      });
    });

    group("noteToNotePosition", () {
      test("should convert natural notes correctly", () {
        final c4 = NoteUtils.noteToNotePosition(MusicalNote.c, 4);
        expect(c4.note, equals(Note.C));
        expect(c4.octave, equals(4));
        expect(c4.accidental, equals(Accidental.None));

        final g4 = NoteUtils.noteToNotePosition(MusicalNote.g, 4);
        expect(g4.note, equals(Note.G));
        expect(g4.octave, equals(4));
        expect(g4.accidental, equals(Accidental.None));
      });

      test("should convert sharp notes correctly", () {
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

    group("convertNotePositionToMidi", () {
      test("should convert natural note positions correctly", () {
        final c4 = NotePosition(note: Note.C);
        expect(NoteUtils.convertNotePositionToMidi(c4), equals(60));

        final g4 = NotePosition(note: Note.G);
        expect(NoteUtils.convertNotePositionToMidi(g4), equals(67));
      });

      test("should convert sharp note positions correctly", () {
        final cSharp4 = NotePosition(
          note: Note.C,
          accidental: Accidental.Sharp,
        );
        expect(NoteUtils.convertNotePositionToMidi(cSharp4), equals(61));

        final fSharp4 = NotePosition(
          note: Note.F,
          accidental: Accidental.Sharp,
        );
        expect(NoteUtils.convertNotePositionToMidi(fSharp4), equals(66));
      });

      test("should convert flat note positions correctly", () {
        final dFlat4 = NotePosition(note: Note.D, accidental: Accidental.Flat);
        expect(
          NoteUtils.convertNotePositionToMidi(dFlat4),
          equals(61),
        ); // Same as C#

        final bFlat4 = NotePosition(note: Note.B, accidental: Accidental.Flat);
        expect(
          NoteUtils.convertNotePositionToMidi(bFlat4),
          equals(70),
        ); // Same as A#
      });
    });

    group("midiNumberToNotePosition", () {
      test("should convert basic MIDI numbers to NotePosition", () {
        // Test middle C
        final c4 = NoteUtils.midiNumberToNotePosition(60);
        expect(c4, isNotNull);
        expect(c4?.note, equals(Note.C));
        expect(c4?.octave, equals(4));
        expect(c4?.accidental, equals(Accidental.None));

        // Test A4
        final a4 = NoteUtils.midiNumberToNotePosition(69);
        expect(a4, isNotNull);
        expect(a4?.note, equals(Note.A));
        expect(a4?.octave, equals(4));
        expect(a4?.accidental, equals(Accidental.None));
      });

      test("should convert sharp notes correctly", () {
        // Test C#4
        final cSharp4 = NoteUtils.midiNumberToNotePosition(61);
        expect(cSharp4?.note, equals(Note.C));
        expect(cSharp4?.octave, equals(4));
        expect(cSharp4?.accidental, equals(Accidental.Sharp));

        // Test F#4
        final fSharp4 = NoteUtils.midiNumberToNotePosition(66);
        expect(fSharp4?.note, equals(Note.F));
        expect(fSharp4?.octave, equals(4));
        expect(fSharp4?.accidental, equals(Accidental.Sharp));

        // Test A#4
        final aSharp4 = NoteUtils.midiNumberToNotePosition(70);
        expect(aSharp4?.note, equals(Note.A));
        expect(aSharp4?.octave, equals(4));
        expect(aSharp4?.accidental, equals(Accidental.Sharp));
      });

      test("should handle different octaves", () {
        // Test C in different octaves
        final c0 = NoteUtils.midiNumberToNotePosition(12);
        expect(c0?.note, equals(Note.C));
        expect(c0?.octave, equals(0));

        final c1 = NoteUtils.midiNumberToNotePosition(24);
        expect(c1?.note, equals(Note.C));
        expect(c1?.octave, equals(1));

        final c2 = NoteUtils.midiNumberToNotePosition(36);
        expect(c2?.note, equals(Note.C));
        expect(c2?.octave, equals(2));

        final c6 = NoteUtils.midiNumberToNotePosition(84);
        expect(c6?.note, equals(Note.C));
        expect(c6?.octave, equals(6));
      });

      test("should handle extreme MIDI ranges", () {
        // Test lowest MIDI note (C-1)
        final lowestC = NoteUtils.midiNumberToNotePosition(0);
        expect(lowestC?.note, equals(Note.C));
        expect(lowestC?.octave, equals(-1));

        // Test highest MIDI note (G9)
        final highestG = NoteUtils.midiNumberToNotePosition(127);
        expect(highestG?.note, equals(Note.G));
        expect(highestG?.octave, equals(9));

        // Test 88-key piano range boundaries
        final a0 = NoteUtils.midiNumberToNotePosition(
          21,
        ); // A0 - lowest piano key
        expect(a0?.note, equals(Note.A));
        expect(a0?.octave, equals(0));

        final c8 = NoteUtils.midiNumberToNotePosition(
          108,
        ); // C8 - highest piano key
        expect(c8?.note, equals(Note.C));
        expect(c8?.octave, equals(8));
      });

      test("should return null for invalid MIDI numbers", () {
        expect(NoteUtils.midiNumberToNotePosition(-1), isNull);
        expect(NoteUtils.midiNumberToNotePosition(128), isNull);
        expect(NoteUtils.midiNumberToNotePosition(200), isNull);
        expect(NoteUtils.midiNumberToNotePosition(-100), isNull);
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
          final notePos = NoteUtils.midiNumberToNotePosition(midiNumber);
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

    group("noteDisplayName", () {
      test("should format note names correctly", () {
        expect(NoteUtils.noteDisplayName(MusicalNote.c, 4), equals("C4"));
        expect(NoteUtils.noteDisplayName(MusicalNote.cSharp, 4), equals("C#4"));
        expect(NoteUtils.noteDisplayName(MusicalNote.fSharp, 2), equals("F#2"));
        expect(NoteUtils.noteDisplayName(MusicalNote.b, 6), equals("B6"));
      });
    });

    group("getCompactNoteName", () {
      test("should return note names without octave", () {
        expect(NoteUtils.getCompactNoteName(60), equals("C")); // C4
        expect(NoteUtils.getCompactNoteName(61), equals("C#")); // C#4
        expect(NoteUtils.getCompactNoteName(62), equals("D")); // D4
        expect(NoteUtils.getCompactNoteName(63), equals("D#")); // D#4
        expect(NoteUtils.getCompactNoteName(64), equals("E")); // E4
        expect(NoteUtils.getCompactNoteName(65), equals("F")); // F4
        expect(NoteUtils.getCompactNoteName(66), equals("F#")); // F#4
        expect(NoteUtils.getCompactNoteName(67), equals("G")); // G4
        expect(NoteUtils.getCompactNoteName(68), equals("G#")); // G#4
        expect(NoteUtils.getCompactNoteName(69), equals("A")); // A4
        expect(NoteUtils.getCompactNoteName(70), equals("A#")); // A#4
        expect(NoteUtils.getCompactNoteName(71), equals("B")); // B4
      });

      test("should work consistently across octaves", () {
        // Test same note across different octaves
        expect(NoteUtils.getCompactNoteName(12), equals("C")); // C0
        expect(NoteUtils.getCompactNoteName(24), equals("C")); // C1
        expect(NoteUtils.getCompactNoteName(36), equals("C")); // C2
        expect(NoteUtils.getCompactNoteName(48), equals("C")); // C3
        expect(NoteUtils.getCompactNoteName(60), equals("C")); // C4
        expect(NoteUtils.getCompactNoteName(72), equals("C")); // C5
        expect(NoteUtils.getCompactNoteName(84), equals("C")); // C6

        // Test sharp notes across octaves
        expect(NoteUtils.getCompactNoteName(13), equals("C#")); // C#0
        expect(NoteUtils.getCompactNoteName(25), equals("C#")); // C#1
        expect(NoteUtils.getCompactNoteName(61), equals("C#")); // C#4
        expect(NoteUtils.getCompactNoteName(85), equals("C#")); // C#6
      });

      test("should handle extreme MIDI ranges", () {
        // Test lowest MIDI note (C-1)
        expect(NoteUtils.getCompactNoteName(0), equals("C"));

        // Test highest MIDI note (G9)
        expect(NoteUtils.getCompactNoteName(127), equals("G"));

        // Test some other extreme values
        expect(NoteUtils.getCompactNoteName(1), equals("C#")); // C#-1
        expect(NoteUtils.getCompactNoteName(126), equals("F#")); // F#9
      });

      test("should throw ArgumentError for invalid MIDI numbers", () {
        expect(
          () => NoteUtils.getCompactNoteName(-1),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("MIDI number must be between 0 and 127"),
            ),
          ),
        );

        expect(
          () => NoteUtils.getCompactNoteName(128),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("MIDI number must be between 0 and 127"),
            ),
          ),
        );

        expect(
          () => NoteUtils.getCompactNoteName(200),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              "message",
              contains("MIDI number must be between 0 and 127"),
            ),
          ),
        );
      });

      test("should be consistent with midiNumberToNote", () {
        // Test that compact note name matches the note part of full display name
        for (var midi = 0; midi <= 127; midi++) {
          final fullInfo = NoteUtils.midiNumberToNote(midi);
          final compactName = NoteUtils.getCompactNoteName(midi);

          // Extract note name from full display name (remove octave and minus signs)
          final expectedName = fullInfo.displayName.replaceAll(
            RegExp(r"[-\d]+$"),
            "",
          );

          expect(
            compactName,
            equals(expectedName),
            reason:
                "Compact name for MIDI $midi should match note part of ${fullInfo.displayName}",
          );
        }
      });
    });

    group("Bidirectional conversion", () {
      test("MIDI to note and back should be consistent", () {
        for (var midi = 0; midi <= 127; midi++) {
          final noteInfo = NoteUtils.midiNumberToNote(midi);
          final convertedBack = NoteUtils.noteToMidiNumber(
            noteInfo.note,
            noteInfo.octave,
          );
          expect(
            convertedBack,
            equals(midi),
            reason: "MIDI $midi -> ${noteInfo.displayName} -> $convertedBack",
          );
        }
      });

      test("Note to MIDI and back should be consistent", () {
        for (final note in MusicalNote.values) {
          for (var octave = 0; octave <= 9; octave++) {
            final midi = NoteUtils.noteToMidiNumber(note, octave);
            if (midi >= 0 && midi <= 127) {
              final noteInfo = NoteUtils.midiNumberToNote(midi);
              expect(noteInfo.note, equals(note));
              expect(noteInfo.octave, equals(octave));
            }
          }
        }
      });

      test("MIDI to NotePosition and back should be consistent", () {
        for (var midi = 0; midi <= 127; midi++) {
          final notePos = NoteUtils.midiNumberToNotePosition(midi);
          expect(
            notePos,
            isNotNull,
            reason: "MIDI $midi should convert to valid NotePosition",
          );

          if (notePos != null) {
            final convertedBack = NoteUtils.convertNotePositionToMidi(notePos);
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
          final midi = NoteUtils.convertNotePositionToMidi(originalPos);
          final convertedPos = NoteUtils.midiNumberToNotePosition(midi);

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
          final midi = NoteUtils.convertNotePositionToMidi(flatNote);
          final convertedPos = NoteUtils.midiNumberToNotePosition(midi);

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
