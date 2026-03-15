import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

void main() {
  group("MidiNote", () {
    group("construction", () {
      test("creates note with valid MIDI value", () {
        final note = MidiNote(60);
        expect(note.value, equals(60));
      });

      test("accepts minimum MIDI value (0)", () {
        final note = MidiNote(0);
        expect(note.value, equals(0));
      });

      test("accepts maximum MIDI value (127)", () {
        final note = MidiNote(127);
        expect(note.value, equals(127));
      });

      test("throws assertion error for negative value", () {
        expect(() => MidiNote(-1), throwsAssertionError);
      });

      test("throws assertion error for value above 127", () {
        expect(() => MidiNote(128), throwsAssertionError);
      });
    });

    group("fromNote factory", () {
      test("creates middle C (C4) correctly", () {
        final note = MidiNote.fromNote(MusicalNote.c, 4);
        expect(note.value, equals(60));
      });

      test("creates A440 (A4) correctly", () {
        final note = MidiNote.fromNote(MusicalNote.a, 4);
        expect(note.value, equals(69));
      });

      test("creates low C (C-1) correctly", () {
        final note = MidiNote.fromNote(MusicalNote.c, -1);
        expect(note.value, equals(0));
      });

      test("creates high G (G9) correctly", () {
        final note = MidiNote.fromNote(MusicalNote.g, 9);
        expect(note.value, equals(127));
      });

      test("creates all chromatic notes in octave 4", () {
        final expectedValues = {
          MusicalNote.c: 60,
          MusicalNote.cSharp: 61,
          MusicalNote.d: 62,
          MusicalNote.dSharp: 63,
          MusicalNote.e: 64,
          MusicalNote.f: 65,
          MusicalNote.fSharp: 66,
          MusicalNote.g: 67,
          MusicalNote.gSharp: 68,
          MusicalNote.a: 69,
          MusicalNote.aSharp: 70,
          MusicalNote.b: 71,
        };

        for (final entry in expectedValues.entries) {
          final note = MidiNote.fromNote(entry.key, 4);
          expect(
            note.value,
            equals(entry.value),
            reason: "${entry.key} at octave 4 should be MIDI ${entry.value}",
          );
        }
      });
    });

    group("pitchClass property", () {
      test("returns 0 for C notes at any octave", () {
        expect(MidiNote(0).pitchClass, equals(0)); // C-1
        expect(MidiNote(12).pitchClass, equals(0)); // C0
        expect(MidiNote(60).pitchClass, equals(0)); // C4
        expect(MidiNote(72).pitchClass, equals(0)); // C5
        expect(MidiNote(120).pitchClass, equals(0)); // C9
      });

      test("returns correct pitch class for all chromatic notes", () {
        for (var pc = 0; pc < 12; pc++) {
          final midiValue = 60 + pc; // Octave 4
          expect(
            MidiNote(midiValue).pitchClass,
            equals(pc),
            reason: "MIDI $midiValue should have pitch class $pc",
          );
        }
      });

      test("returns 11 for B notes at any octave", () {
        expect(MidiNote(11).pitchClass, equals(11)); // B-1
        expect(MidiNote(23).pitchClass, equals(11)); // B0
        expect(MidiNote(71).pitchClass, equals(11)); // B4
        expect(MidiNote(83).pitchClass, equals(11)); // B5
      });
    });

    group("octave property", () {
      test("returns -1 for MIDI 0-11", () {
        expect(MidiNote(0).octave, equals(-1));
        expect(MidiNote(11).octave, equals(-1));
      });

      test("returns 0 for MIDI 12-23", () {
        expect(MidiNote(12).octave, equals(0));
        expect(MidiNote(23).octave, equals(0));
      });

      test("returns 4 for middle octave (MIDI 60-71)", () {
        expect(MidiNote(60).octave, equals(4)); // C4
        expect(MidiNote(71).octave, equals(4)); // B4
      });

      test("returns 9 for highest octave (MIDI 120-127)", () {
        expect(MidiNote(120).octave, equals(9)); // C9
        expect(MidiNote(127).octave, equals(9)); // G9
      });
    });

    group("musicalNote property", () {
      test("returns correct MusicalNote for middle C", () {
        expect(MidiNote(60).musicalNote, equals(MusicalNote.c));
      });

      test("returns correct MusicalNote for all chromatic notes", () {
        final expectedNotes = [
          MusicalNote.c,
          MusicalNote.cSharp,
          MusicalNote.d,
          MusicalNote.dSharp,
          MusicalNote.e,
          MusicalNote.f,
          MusicalNote.fSharp,
          MusicalNote.g,
          MusicalNote.gSharp,
          MusicalNote.a,
          MusicalNote.aSharp,
          MusicalNote.b,
        ];

        for (var i = 0; i < 12; i++) {
          expect(
            MidiNote(60 + i).musicalNote,
            equals(expectedNotes[i]),
            reason: "MIDI ${60 + i} should be ${expectedNotes[i]}",
          );
        }
      });
    });

    group("displayName property", () {
      test("returns correct display name for middle C", () {
        expect(MidiNote(60).displayName, equals("C4"));
      });

      test("returns correct display name for A440", () {
        expect(MidiNote(69).displayName, equals("A4"));
      });

      test("returns correct display name for sharps", () {
        expect(MidiNote(61).displayName, equals("C#4"));
        expect(MidiNote(66).displayName, equals("F#4"));
      });

      test("returns correct display name with negative octave", () {
        expect(MidiNote(0).displayName, equals("C-1"));
      });

      test("returns correct display name for high notes", () {
        expect(MidiNote(127).displayName, equals("G9"));
      });
    });

    group("noteName property", () {
      test("returns note name without octave for middle C", () {
        expect(MidiNote(60).noteName, equals("C"));
      });

      test("returns note name without octave for sharps", () {
        expect(MidiNote(61).noteName, equals("C#"));
        expect(MidiNote(66).noteName, equals("F#"));
      });

      test(
        "returns same note name for same pitch class at different octaves",
        () {
          expect(MidiNote(60).noteName, equals("C")); // C4
          expect(MidiNote(72).noteName, equals("C")); // C5
          expect(MidiNote(48).noteName, equals("C")); // C3
        },
      );
    });

    group("distanceTo", () {
      test("returns 0 for same note", () {
        final c4 = MidiNote(60);
        expect(c4.distanceTo(c4), equals(0));
      });

      test("returns correct distance between ascending notes", () {
        final c4 = MidiNote(60);
        final g4 = MidiNote(67);
        expect(c4.distanceTo(g4), equals(7));
      });

      test("returns correct distance between descending notes", () {
        final c4 = MidiNote(60);
        final f3 = MidiNote(53);
        expect(c4.distanceTo(f3), equals(7));
      });

      test("returns absolute distance (always positive)", () {
        final c4 = MidiNote(60);
        final c5 = MidiNote(72);
        expect(c4.distanceTo(c5), equals(12));
        expect(c5.distanceTo(c4), equals(12)); // Same distance
      });

      test("returns octave distance for same pitch class", () {
        final c4 = MidiNote(60);
        final c5 = MidiNote(72);
        expect(c4.distanceTo(c5), equals(12)); // One octave
      });
    });

    group("hasSamePitchClass", () {
      test("returns true for same note", () {
        final c4 = MidiNote(60);
        expect(c4.hasSamePitchClass(c4), isTrue);
      });

      test("returns true for same pitch class at different octaves", () {
        final c4 = MidiNote(60);
        final c5 = MidiNote(72);
        final c3 = MidiNote(48);
        expect(c4.hasSamePitchClass(c5), isTrue);
        expect(c4.hasSamePitchClass(c3), isTrue);
      });

      test("returns false for different pitch classes", () {
        final c4 = MidiNote(60);
        final d4 = MidiNote(62);
        final g4 = MidiNote(67);
        expect(c4.hasSamePitchClass(d4), isFalse);
        expect(c4.hasSamePitchClass(g4), isFalse);
      });
    });

    group("transpose", () {
      test("transposes up by semitones", () {
        final c4 = MidiNote(60);
        final g4 = c4.transpose(7); // Perfect fifth up
        expect(g4.value, equals(67));
      });

      test("transposes down by semitones", () {
        final c4 = MidiNote(60);
        final f3 = c4.transpose(-7); // Perfect fifth down
        expect(f3.value, equals(53));
      });

      test("transposes by zero returns equivalent note", () {
        final c4 = MidiNote(60);
        final same = c4.transpose(0);
        expect(same.value, equals(60));
      });

      test("transposes up by octave", () {
        final c4 = MidiNote(60);
        final c5 = c4.transpose(12);
        expect(c5.value, equals(72));
      });

      test("throws when transposing below MIDI 0", () {
        final c0 = MidiNote(12);
        expect(() => c0.transpose(-13), throwsArgumentError);
      });

      test("throws when transposing above MIDI 127", () {
        final g9 = MidiNote(127);
        expect(() => g9.transpose(1), throwsArgumentError);
      });

      test("allows transposition to exactly MIDI 0", () {
        final cSharp0 = MidiNote(13);
        final cMinus1 = cSharp0.transpose(-13);
        expect(cMinus1.value, equals(0));
      });

      test("allows transposition to exactly MIDI 127", () {
        final fSharp9 = MidiNote(126);
        final g9 = fSharp9.transpose(1);
        expect(g9.value, equals(127));
      });
    });

    group("equality", () {
      test("two notes with same value are equal", () {
        final note1 = MidiNote(60);
        final note2 = MidiNote(60);
        expect(note1, equals(note2));
      });

      test("two notes with different values are not equal", () {
        final note1 = MidiNote(60);
        final note2 = MidiNote(62);
        expect(note1, isNot(equals(note2)));
      });

      test("note equals itself", () {
        final note = MidiNote(60);
        expect(note, equals(note));
      });

      test("note does not equal non-MidiNote object", () {
        final note = MidiNote(60);
        expect(note, isNot(equals(60)));
        expect(note, isNot(equals("C4")));
      });
    });

    group("hashCode", () {
      test("two equal notes have same hashCode", () {
        final note1 = MidiNote(60);
        final note2 = MidiNote(60);
        expect(note1.hashCode, equals(note2.hashCode));
      });

      test("can be used in Sets to remove duplicates", () {
        final noteSet = {
          MidiNote(60),
          MidiNote(60),
          MidiNote(62),
          MidiNote(62),
        };
        expect(noteSet.length, equals(2));
      });

      test("can be used as Map keys", () {
        final noteMap = {MidiNote(60): "C4", MidiNote(62): "D4"};
        expect(noteMap[MidiNote(60)], equals("C4"));
      });
    });

    group("toString", () {
      test("returns readable string with value and display name", () {
        final c4 = MidiNote(60);
        expect(c4.toString(), equals("MidiNote(60, C4)"));
      });
    });

    group("static constants", () {
      test("c4 is middle C (MIDI 60)", () {
        expect(MidiNote.c4.value, equals(60));
      });

      test("all chromatic notes in octave 4 are defined", () {
        expect(MidiNote.c4.value, equals(60));
        expect(MidiNote.cSharp4.value, equals(61));
        expect(MidiNote.d4.value, equals(62));
        expect(MidiNote.dSharp4.value, equals(63));
        expect(MidiNote.e4.value, equals(64));
        expect(MidiNote.f4.value, equals(65));
        expect(MidiNote.fSharp4.value, equals(66));
        expect(MidiNote.g4.value, equals(67));
        expect(MidiNote.gSharp4.value, equals(68));
        expect(MidiNote.a4.value, equals(69));
        expect(MidiNote.aSharp4.value, equals(70));
        expect(MidiNote.b4.value, equals(71));
      });
    });
  });

  group("MidiNoteList extension", () {
    test("values returns raw MIDI numbers", () {
      final notes = [MidiNote(60), MidiNote(64), MidiNote(67)];
      expect(notes.values, equals([60, 64, 67]));
    });

    test("values returns empty list for empty input", () {
      final notes = <MidiNote>[];
      expect(notes.values, isEmpty);
    });

    test("lowest returns note with minimum MIDI value", () {
      final notes = [MidiNote(67), MidiNote(60), MidiNote(64)];
      expect(notes.lowest.value, equals(60));
    });

    test("lowest works with single note", () {
      final notes = [MidiNote(60)];
      expect(notes.lowest.value, equals(60));
    });

    test("highest returns note with maximum MIDI value", () {
      final notes = [MidiNote(60), MidiNote(67), MidiNote(64)];
      expect(notes.highest.value, equals(67));
    });

    test("highest works with single note", () {
      final notes = [MidiNote(60)];
      expect(notes.highest.value, equals(60));
    });

    test("pitchClasses returns unique pitch classes", () {
      final notes = [
        MidiNote(60), // C4 (pc 0)
        MidiNote(72), // C5 (pc 0)
        MidiNote(64), // E4 (pc 4)
        MidiNote(76), // E5 (pc 4)
        MidiNote(67), // G4 (pc 7)
      ];
      expect(notes.pitchClasses, equals({0, 4, 7}));
    });

    test("pitchClasses returns empty set for empty list", () {
      final notes = <MidiNote>[];
      expect(notes.pitchClasses, isEmpty);
    });
  });

  group("MidiNumberList extension", () {
    test("toMidiNotes converts list of ints to MidiNotes", () {
      final midiValues = [60, 64, 67];
      final notes = midiValues.toMidiNotes();
      expect(notes.length, equals(3));
      expect(notes[0].value, equals(60));
      expect(notes[1].value, equals(64));
      expect(notes[2].value, equals(67));
    });

    test("toMidiNotes works with empty list", () {
      final midiValues = <int>[];
      final notes = midiValues.toMidiNotes();
      expect(notes, isEmpty);
    });

    test("toMidiNotes throws for invalid MIDI values", () {
      final invalidValues = [60, 128];
      expect(() => invalidValues.toMidiNotes(), throwsAssertionError);
    });
  });

  group("integration scenarios", () {
    test("voice leading: common tone detection", () {
      // G7 = G4, B4, D5, F5
      final g7 = [MidiNote(67), MidiNote(71), MidiNote(74), MidiNote(77)];
      // Cmaj7 = C4, E4, G4, B4
      final cmaj7 = [MidiNote(60), MidiNote(64), MidiNote(67), MidiNote(71)];

      final g7PitchClasses = g7.pitchClasses;
      final cmaj7PitchClasses = cmaj7.pitchClasses;
      final commonPitchClasses = g7PitchClasses.intersection(cmaj7PitchClasses);

      // G (pc 7) and B (pc 11) are common tones
      expect(commonPitchClasses, equals({7, 11}));
    });

    test("voice leading: stepwise motion validation", () {
      final f5 = MidiNote(77);
      final e4 = MidiNote(64);
      final distance = f5.distanceTo(e4);

      // F5 to E4 is a large leap (13 semitones)
      expect(distance, equals(13));
      expect(distance > 2, isTrue); // Violates stepwise motion
    });

    test("round-trip: MidiNote -> value -> MidiNote", () {
      final original = MidiNote(60);
      final value = original.value;
      final reconstructed = MidiNote(value);
      expect(reconstructed, equals(original));
    });

    test("round-trip: MusicalNote -> MidiNote -> MusicalNote", () {
      final originalNote = MusicalNote.c;
      final octave = 4;
      final midiNote = MidiNote.fromNote(originalNote, octave);
      final reconstructedNote = midiNote.musicalNote;
      final reconstructedOctave = midiNote.octave;

      expect(reconstructedNote, equals(originalNote));
      expect(reconstructedOctave, equals(octave));
    });
  });
}
