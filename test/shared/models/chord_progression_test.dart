import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("ChordProgression", () {
    test("should generate correct I-V progression in C major", () {
      final progression = ChordProgressionLibrary.getProgressionByName("I - V");
      expect(progression, isNotNull);
      expect(progression!.name, equals("I - V"));
      expect(progression.romanNumerals, equals(["I", "V"]));
      expect(progression.difficulty, equals(ProgressionDifficulty.beginner));

      // Generate chords in C major
      final chords = progression.generateChords(music.Key.c);
      expect(chords.length, equals(2));

      // Check I chord (C major: C-E-G at octave 4 = MIDI 60,64,67)
      final iChord = chords[0];
      final iMidiNotes = iChord.getMidiNotes(4);
      expect(iMidiNotes, equals([60, 64, 67])); // C, E, G

      // Check V chord (G major: G-B-D at octave 4 = MIDI 67,71,74)
      final vChord = chords[1];
      final vMidiNotes = vChord.getMidiNotes(4);
      expect(vMidiNotes, equals([67, 71, 74])); // G, B, D
    });

    test("should generate correct I-V progression in different keys", () {
      final progression = ChordProgressionLibrary.getProgressionByName("I - V");
      expect(progression, isNotNull);

      // Test in D major (D = MIDI 62)
      final chordsInD = progression!.generateChords(music.Key.d);
      final iChordInD = chordsInD[0].getMidiNotes(4);
      final vChordInD = chordsInD[1].getMidiNotes(4);

      expect(iChordInD, equals([62, 66, 69])); // D, F#, A
      expect(vChordInD, equals([69, 73, 76])); // A, C#, E
    });

    test("should support chromatic progressions with flat seven", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - ♭VII - IV",
      );
      expect(progression, isNotNull);
      expect(progression!.romanNumerals, equals(["I", "♭VII", "IV"]));
      expect(progression.difficulty, equals(ProgressionDifficulty.advanced));

      // Generate chords in C major
      final chords = progression.generateChords(music.Key.c);
      expect(chords.length, equals(3));

      // Check I chord (C major)
      final iChord = chords[0];
      expect(iChord.getMidiNotes(4), equals([60, 64, 67])); // C, E, G

      // Check ♭VII chord (Bb major: Bb-D-F = MIDI 70,74,77)
      final flatSevenChord = chords[1];
      expect(flatSevenChord.getMidiNotes(4), equals([70, 74, 77])); // Bb, D, F

      // Check IV chord (F major: F-A-C = MIDI 65,69,72)
      final ivChord = chords[2];
      expect(ivChord.getMidiNotes(4), equals([65, 69, 72])); // F, A, C
    });

    test("should provide progressions organized by difficulty", () {
      final beginnerProgressions =
          ChordProgressionLibrary.getProgressionsForDifficulty(
            ProgressionDifficulty.beginner,
          );
      expect(beginnerProgressions.length, equals(3));
      expect(beginnerProgressions.map((p) => p.name), contains("I - V"));
      expect(beginnerProgressions.map((p) => p.name), contains("I - vi"));
      expect(beginnerProgressions.map((p) => p.name), contains("vi - IV"));

      final intermediateProgressions =
          ChordProgressionLibrary.getProgressionsForDifficulty(
            ProgressionDifficulty.intermediate,
          );
      expect(intermediateProgressions.length, equals(3));
      expect(
        intermediateProgressions.map((p) => p.name),
        contains("I - V - vi - IV"),
      );

      final advancedProgressions =
          ChordProgressionLibrary.getProgressionsForDifficulty(
            ProgressionDifficulty.advanced,
          );
      expect(advancedProgressions.length, equals(2));
      expect(advancedProgressions.map((p) => p.name), contains("ii - V - I"));
      expect(
        advancedProgressions.map((p) => p.name),
        contains("I - ♭VII - IV"),
      );
    });

    test("should generate chords at different octaves", () {
      final progression = ChordProgressionLibrary.getProgressionByName("I - V");
      final chords = progression!.generateChords(music.Key.c);

      // Test octave 3
      final iChordOctave3 = chords[0].getMidiNotes(3);
      expect(iChordOctave3, equals([48, 52, 55])); // C3, E3, G3

      // Test octave 5
      final iChordOctave5 = chords[0].getMidiNotes(5);
      expect(iChordOctave5, equals([72, 76, 79])); // C5, E5, G5
    });
  });

  group("ProgressionDifficulty", () {
    test("should have correct display names", () {
      expect(ProgressionDifficulty.beginner.displayName, equals("Beginner"));
      expect(
        ProgressionDifficulty.intermediate.displayName,
        equals("Intermediate"),
      );
      expect(ProgressionDifficulty.advanced.displayName, equals("Advanced"));
    });
  });

  group("ChordProgression Integration with NoteUtils", () {
    test("should use NoteUtils.keyToMidiNumber for consistent key mapping", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V",
      )!;
      final cMajorChords = progression.generateChords(music.Key.c);
      final fMajorChords = progression.generateChords(music.Key.f);

      // Check that C major I chord uses MIDI 60 (middle C) as root
      final cMajorIChord = cMajorChords[0] as IntervalBasedChordInfo;
      expect(cMajorIChord.midiNotes[0], equals(60)); // C4

      // Check that F major I chord uses MIDI 65 (F4) as root
      final fMajorIChord = fMajorChords[0] as IntervalBasedChordInfo;
      expect(fMajorIChord.midiNotes[0], equals(65)); // F4

      // Verify the utility method produces the same results
      expect(NoteUtils.keyToMidiNumber(music.Key.c), equals(60));
      expect(NoteUtils.keyToMidiNumber(music.Key.f), equals(65));
    });

    test("should generate correct chord intervals in different keys", () {
      final progression = ChordProgressionLibrary.getProgressionByName(
        "I - V",
      )!;

      // Test in C major
      final cMajorChords = progression.generateChords(music.Key.c);
      final cMajorI = cMajorChords[0] as IntervalBasedChordInfo;
      final cMajorV = cMajorChords[1] as IntervalBasedChordInfo;

      // C major: I = C E G (60, 64, 67), V = G B D (67, 71, 74)
      expect(cMajorI.midiNotes, equals([60, 64, 67]));
      expect(cMajorV.midiNotes, equals([67, 71, 74]));

      // Test in G major (MIDI 67)
      final gMajorChords = progression.generateChords(music.Key.g);
      final gMajorI = gMajorChords[0] as IntervalBasedChordInfo;
      final gMajorV = gMajorChords[1] as IntervalBasedChordInfo;

      // G major: I = G B D (67, 71, 74), V = D F# A (74, 78, 81)
      expect(gMajorI.midiNotes, equals([67, 71, 74]));
      expect(gMajorV.midiNotes, equals([74, 78, 81]));
    });
  });
}
