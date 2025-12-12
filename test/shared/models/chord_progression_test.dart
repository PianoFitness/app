import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
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

    group("Hand selection for chord progressions", () {
      test("should handle left hand for progression chords", () {
        final progression = ChordProgressionLibrary.getProgressionByName(
          "I - V",
        );
        final chords = progression!.generateChords(music.Key.c);

        // Test left hand returns only bass note
        for (final chord in chords) {
          final leftHandNotes = chord.getMidiNotesForHand(
            4,
            HandSelection.left,
          );
          expect(leftHandNotes, hasLength(1));
        }

        // I chord left hand: C4 (60)
        expect(
          chords[0].getMidiNotesForHand(4, HandSelection.left),
          equals([60]),
        );
        // V chord left hand: G4 (67)
        expect(
          chords[1].getMidiNotesForHand(4, HandSelection.left),
          equals([67]),
        );
      });

      test("should handle right hand for progression chords", () {
        final progression = ChordProgressionLibrary.getProgressionByName(
          "I - V",
        );
        final chords = progression!.generateChords(music.Key.c);

        // I chord right hand: E4,G4 (64, 67)
        final iRightHand = chords[0].getMidiNotesForHand(
          4,
          HandSelection.right,
        );
        expect(iRightHand, equals([64, 67]));

        // V chord right hand: B4,D5 (71, 74)
        final vRightHand = chords[1].getMidiNotesForHand(
          4,
          HandSelection.right,
        );
        expect(vRightHand, equals([71, 74]));
      });

      test("should handle both hands for progression chords", () {
        final progression = ChordProgressionLibrary.getProgressionByName(
          "I - V",
        );
        final chords = progression!.generateChords(music.Key.c);

        // I chord both hands: C3,E3,G3,C4,E4,G4 (48, 52, 55, 60, 64, 67)
        final iBothHands = chords[0].getMidiNotesForHand(4, HandSelection.both);
        expect(iBothHands, equals([48, 52, 55, 60, 64, 67]));

        // V chord both hands: G3,B3,D4,G4,B4,D5 (55, 59, 62, 67, 71, 74)
        final vBothHands = chords[1].getMidiNotesForHand(4, HandSelection.both);
        expect(vBothHands, equals([55, 59, 62, 67, 71, 74]));
      });

      test("should handle all hand selections for I-vi-IV-V progression", () {
        final progression = ChordProgressionLibrary.getProgressionByName(
          "I - vi - IV - V",
        );
        final chords = progression!.generateChords(music.Key.c);

        expect(chords.length, equals(4));

        // Test all four chords with each hand selection
        for (final chord in chords) {
          // Left hand should have 1 note
          final leftNotes = chord.getMidiNotesForHand(4, HandSelection.left);
          expect(leftNotes, hasLength(1));

          // Right hand should have 2 notes (upper tones)
          final rightNotes = chord.getMidiNotesForHand(4, HandSelection.right);
          expect(rightNotes, hasLength(2));

          // Both hands should have 6 notes (3 + 3)
          final bothNotes = chord.getMidiNotesForHand(4, HandSelection.both);
          expect(bothNotes, hasLength(6));

          // Verify both hands structure
          final regularMidi = chord.getMidiNotes(4);
          final expected = <int>[];
          expected.addAll(regularMidi.map((note) => note - 12));
          expected.addAll(regularMidi);
          expect(bothNotes, equals(expected));
        }
      });

      test("should handle chromatic progressions with hand selection", () {
        final progression = ChordProgressionLibrary.getProgressionByName(
          "I - ♭VII - IV",
        );
        final chords = progression!.generateChords(music.Key.c);

        // Test the flat VII chord with both hands
        final flatVIIBothHands = chords[1].getMidiNotesForHand(
          4,
          HandSelection.both,
        );
        final flatVIIRegular = chords[1].getMidiNotes(4);

        // Should follow standard pattern: all notes -12, then all notes
        expect(flatVIIBothHands.length, equals(flatVIIRegular.length * 2));

        final expected = <int>[];
        expected.addAll(flatVIIRegular.map((note) => note - 12));
        expected.addAll(flatVIIRegular);
        expect(flatVIIBothHands, equals(expected));
      });
    });

    group("Octave validation", () {
      test("should enforce minimum octave for both hands", () {
        final progression = ChordProgressionLibrary.getProgressionByName(
          "I - V",
        );
        final chords = progression!.generateChords(music.Key.c);

        // octave = 0 should fail assertion (left hand would be at -1)
        expect(
          () => chords[0].getMidiNotesForHand(0, HandSelection.both),
          throwsA(isA<AssertionError>()),
          reason: "octave must be >= 1 for both hands",
        );

        // octave = 1 should work (left hand at 0)
        expect(
          () => chords[0].getMidiNotesForHand(1, HandSelection.both),
          returnsNormally,
          reason: "octave = 1 should be valid for both hands",
        );
      });

      test("should allow any octave for left or right hand only", () {
        final progression = ChordProgressionLibrary.getProgressionByName(
          "I - V",
        );
        final chords = progression!.generateChords(music.Key.c);

        // Even octave = 0 should work for left/right hand (no offset)
        expect(
          () => chords[0].getMidiNotesForHand(0, HandSelection.left),
          returnsNormally,
          reason: "Left hand should accept any valid octave",
        );

        expect(
          () => chords[0].getMidiNotesForHand(0, HandSelection.right),
          returnsNormally,
          reason: "Right hand should accept any valid octave",
        );
      });
    });
  });
}
