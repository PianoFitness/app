import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

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
    });
  });

  group("keyToMusicalNote", () {
    test("should convert all 12 chromatic keys correctly", () {
      expect(NoteUtils.keyToMusicalNote(music.Key.c), equals(MusicalNote.c));
      expect(
        NoteUtils.keyToMusicalNote(music.Key.cSharp),
        equals(MusicalNote.cSharp),
      );
      expect(NoteUtils.keyToMusicalNote(music.Key.d), equals(MusicalNote.d));
      expect(
        NoteUtils.keyToMusicalNote(music.Key.dSharp),
        equals(MusicalNote.dSharp),
      );
      expect(NoteUtils.keyToMusicalNote(music.Key.e), equals(MusicalNote.e));
      expect(NoteUtils.keyToMusicalNote(music.Key.f), equals(MusicalNote.f));
      expect(
        NoteUtils.keyToMusicalNote(music.Key.fSharp),
        equals(MusicalNote.fSharp),
      );
      expect(NoteUtils.keyToMusicalNote(music.Key.g), equals(MusicalNote.g));
      expect(
        NoteUtils.keyToMusicalNote(music.Key.gSharp),
        equals(MusicalNote.gSharp),
      );
      expect(NoteUtils.keyToMusicalNote(music.Key.a), equals(MusicalNote.a));
      expect(
        NoteUtils.keyToMusicalNote(music.Key.aSharp),
        equals(MusicalNote.aSharp),
      );
      expect(NoteUtils.keyToMusicalNote(music.Key.b), equals(MusicalNote.b));
    });
  });
}
