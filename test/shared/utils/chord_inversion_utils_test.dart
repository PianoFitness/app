import "package:logging/logging.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/chord_inversion_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart";

final log = Logger("ChordInversionUtilsTest");

/// Test to demonstrate and fix chord inversion issues.
///
/// This test validates that chord inversions properly ascend from left to right
/// without wrapping lower notes to a lower octave.
void main() {
  group("Chord Inversion Issues and Fixes", () {
    test("C Major chord inversions should properly ascend", () {
      // Test the main ChordBuilder implementation
      final cMajorRoot = ChordBuilder.getChord(
        MusicalNote.c,
        ChordType.major,
        ChordInversion.root,
      );
      final cMajorFirst = ChordBuilder.getChord(
        MusicalNote.c,
        ChordType.major,
        ChordInversion.first,
      );
      final cMajorSecond = ChordBuilder.getChord(
        MusicalNote.c,
        ChordType.major,
        ChordInversion.second,
      );

      final rootMidi = cMajorRoot.getMidiNotes(4);
      final firstMidi = cMajorFirst.getMidiNotes(4);
      final secondMidi = cMajorSecond.getMidiNotes(4);

      log.info("C Major root: $rootMidi");
      log.info("C Major 1st: $firstMidi");
      log.info("C Major 2nd: $secondMidi");

      // Verify proper ascending order
      expect(rootMidi, equals([60, 64, 67])); // C4-E4-G4
      expect(firstMidi, equals([64, 67, 72])); // E4-G4-C5 (C goes UP to C5)
      expect(secondMidi, equals([67, 72, 76])); // G4-C5-E5

      // Verify left-to-right progression
      expect(rootMidi.first < firstMidi.first, isTrue);
      expect(firstMidi.first < secondMidi.first, isTrue);
    });

    test("All chord types should have proper inversion progression", () {
      final testCases = [
        (MusicalNote.c, ChordType.major),
        (MusicalNote.c, ChordType.minor),
        (MusicalNote.f, ChordType.major),
        (MusicalNote.g, ChordType.major),
        (MusicalNote.a, ChordType.minor),
        (MusicalNote.b, ChordType.diminished),
      ];

      for (final (rootNote, chordType) in testCases) {
        final root = ChordBuilder.getChord(
          rootNote,
          chordType,
          ChordInversion.root,
        );
        final first = ChordBuilder.getChord(
          rootNote,
          chordType,
          ChordInversion.first,
        );
        final second = ChordBuilder.getChord(
          rootNote,
          chordType,
          ChordInversion.second,
        );

        final rootMidi = root.getMidiNotes(4);
        final firstMidi = first.getMidiNotes(4);
        final secondMidi = second.getMidiNotes(4);

        final chordName =
            "${NoteUtils.noteDisplayName(rootNote, 0).replaceAll("0", "")} ${chordType.name}";

        // Each chord should be in ascending order
        expect(
          rootMidi[0] < rootMidi[1],
          isTrue,
          reason: "$chordName root should be ascending",
        );
        expect(
          rootMidi[1] < rootMidi[2],
          isTrue,
          reason: "$chordName root should be ascending",
        );

        expect(
          firstMidi[0] < firstMidi[1],
          isTrue,
          reason: "$chordName 1st should be ascending",
        );
        expect(
          firstMidi[1] < firstMidi[2],
          isTrue,
          reason: "$chordName 1st should be ascending",
        );

        expect(
          secondMidi[0] < secondMidi[1],
          isTrue,
          reason: "$chordName 2nd should be ascending",
        );
        expect(
          secondMidi[1] < secondMidi[2],
          isTrue,
          reason: "$chordName 2nd should be ascending",
        );

        // Inversions should progress left-to-right (bass notes ascending)
        expect(
          rootMidi.first <= firstMidi.first,
          isTrue,
          reason:
              "$chordName: root->1st should progress left-to-right (${rootMidi.first} -> ${firstMidi.first})",
        );
        expect(
          firstMidi.first <= secondMidi.first,
          isTrue,
          reason:
              "$chordName: 1st->2nd should progress left-to-right (${firstMidi.first} -> ${secondMidi.first})",
        );

        log.info("$chordName: Root $rootMidi, 1st $firstMidi, 2nd $secondMidi");
      }
    });

    test("Real-world problematic chord inversions should be fixed", () {
      // Test cases mentioned in the user's issue

      // C Major 1st inversion: should be E4-G4-C5, NOT E4-G4-C3
      final cMajorFirst = ChordBuilder.getChord(
        MusicalNote.c,
        ChordType.major,
        ChordInversion.first,
      );
      final cMajorFirstMidi = cMajorFirst.getMidiNotes(4);

      expect(cMajorFirstMidi, equals([64, 67, 72])); // E4-G4-C5
      expect(
        cMajorFirstMidi.last,
        greaterThan(cMajorFirstMidi.first),
        reason: "C should go UP to C5, not down to C3",
      );

      // C Major 2nd inversion: should be G4-C5-E5, NOT C4-E4-G4 (root position)
      final cMajorSecond = ChordBuilder.getChord(
        MusicalNote.c,
        ChordType.major,
        ChordInversion.second,
      );
      final cMajorSecondMidi = cMajorSecond.getMidiNotes(4);

      expect(cMajorSecondMidi, equals([67, 72, 76])); // G4-C5-E5
      expect(
        cMajorSecondMidi.first,
        equals(67),
        reason: "2nd inversion should start with G4 (67), not C4 (60)",
      );
    });

    test("ChordInversionUtils provides same results as ChordBuilder", () {
      final testCases = [
        (MusicalNote.c, ChordType.major),
        (MusicalNote.f, ChordType.major),
        (MusicalNote.a, ChordType.minor),
        (MusicalNote.b, ChordType.diminished),
      ];

      for (final (rootNote, chordType) in testCases) {
        for (final inversion in ChordInversion.values) {
          final directResult = ChordBuilder.getChord(
            rootNote,
            chordType,
            inversion,
          ).getMidiNotes(4);
          final utilityResult = ChordInversionUtils.getChordMidiNotes(
            rootNote: rootNote,
            chordType: chordType,
            inversion: inversion,
            octave: 4,
          );

          expect(
            utilityResult,
            equals(directResult),
            reason:
                "Utility should match ChordBuilder for ${rootNote.name} ${chordType.name} ${inversion.name}",
          );

          // Validate the voicing
          expect(
            ChordInversionUtils.validateChordVoicing(utilityResult),
            isTrue,
            reason:
                "Voicing should be valid for ${rootNote.name} ${chordType.name} ${inversion.name}",
          );
        }
      }
    });

    test("Scale MIDI notes are generated correctly", () {
      final cMajorNotes = ChordInversionUtils.getScaleMidiNotes(
        key: Key.c,
        scaleType: ScaleType.major,
        baseOctave: 4,
        octaveSpan: 1,
      );

      // C Major scale in octave 4: C4(60), D4(62), E4(64), F4(65), G4(67), A4(69), B4(71)
      final expectedNotes = {60, 62, 64, 65, 67, 69, 71};
      expect(cMajorNotes, equals(expectedNotes));
    });

    test("Key to MusicalNote conversion works correctly", () {
      expect(
        ChordInversionUtils.keyToMusicalNote(Key.c),
        equals(MusicalNote.c),
      );
      expect(
        ChordInversionUtils.keyToMusicalNote(Key.fSharp),
        equals(MusicalNote.fSharp),
      );
      expect(
        ChordInversionUtils.keyToMusicalNote(Key.b),
        equals(MusicalNote.b),
      );
    });

    test("Display names are user-friendly", () {
      expect(
        ChordInversionUtils.getInversionDisplayName(ChordInversion.root),
        equals("Root Position"),
      );
      expect(
        ChordInversionUtils.getInversionDisplayName(ChordInversion.first),
        equals("1st Inversion"),
      );
      expect(
        ChordInversionUtils.getInversionDisplayName(ChordInversion.second),
        equals("2nd Inversion"),
      );

      expect(
        ChordInversionUtils.getChordTypeDisplayName(ChordType.major),
        equals("Major"),
      );
      expect(
        ChordInversionUtils.getChordTypeDisplayName(ChordType.minor),
        equals("Minor"),
      );
      expect(
        ChordInversionUtils.getChordTypeDisplayName(ChordType.diminished),
        equals("Diminished"),
      );
      expect(
        ChordInversionUtils.getChordTypeDisplayName(ChordType.augmented),
        equals("Augmented"),
      );
    });
  });
}
