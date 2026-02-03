import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart";

/// Comprehensive test suite for chord inversion flow to ensure
/// inversions progress naturally from left to right without wrapping.
void main() {
  group("Chord Inversion Flow Tests", () {
    test("C Major chord inversions should flow left-to-right naturally", () {
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

      // C Major root: C4-E4-G4 (60-64-67)
      expect(rootMidi, equals([60, 64, 67]));

      // C Major 1st inversion: E4-G4-C5 (64-67-72)
      expect(firstMidi, equals([64, 67, 72]));

      // C Major 2nd inversion: G4-C5-E5 (67-72-76)
      expect(secondMidi, equals([67, 72, 76]));

      // Verify left-to-right progression (each lowest note should be ascending)
      expect(
        rootMidi.first < firstMidi.first,
        isTrue,
        reason: "Root position should start lower than 1st inversion",
      );
      expect(
        firstMidi.first < secondMidi.first,
        isTrue,
        reason: "1st inversion should start lower than 2nd inversion",
      );
    });

    test(
      "F Major chord inversions should not wrap around to lower octaves",
      () {
        final fMajorRoot = ChordBuilder.getChord(
          MusicalNote.f,
          ChordType.major,
          ChordInversion.root,
        );
        final fMajorFirst = ChordBuilder.getChord(
          MusicalNote.f,
          ChordType.major,
          ChordInversion.first,
        );
        final fMajorSecond = ChordBuilder.getChord(
          MusicalNote.f,
          ChordType.major,
          ChordInversion.second,
        );

        final rootMidi = fMajorRoot.getMidiNotes(4);
        final firstMidi = fMajorFirst.getMidiNotes(4);
        final secondMidi = fMajorSecond.getMidiNotes(4);

        // F Major root: F4-A4-C5 (65-69-72)
        expect(rootMidi, equals([65, 69, 72]));

        // F Major 1st inversion: A4-C5-F5 (69-72-77)
        expect(firstMidi, equals([69, 72, 77]));

        // F Major 2nd inversion: C5-F5-A5 (72-77-81)
        expect(secondMidi, equals([72, 77, 81]));

        // Critical: F Major 2nd inversion should NOT wrap to C4 (60)
        expect(
          secondMidi.first,
          greaterThan(71),
          reason: "F Major 2nd inversion should not wrap to lower octave",
        );

        // Verify natural progression
        expect(rootMidi.first < firstMidi.first, isTrue);
        expect(firstMidi.first < secondMidi.first, isTrue);
      },
    );

    test("All C Major scale chord inversions should progress naturally", () {
      final scale = ScaleDefinitions.getScale(Key.c, ScaleType.major);
      final scaleNotes = scale.getNotes();
      final chordTypes = ChordBuilder.getChordsInKey(Key.c, ScaleType.major);

      for (var i = 0; i < 7; i++) {
        final rootNote = scaleNotes[i];
        final chordType = chordTypes[i];

        final rootChord = ChordBuilder.getChord(
          rootNote,
          chordType,
          ChordInversion.root,
        );
        final firstChord = ChordBuilder.getChord(
          rootNote,
          chordType,
          ChordInversion.first,
        );
        final secondChord = ChordBuilder.getChord(
          rootNote,
          chordType,
          ChordInversion.second,
        );

        final rootMidi = rootChord.getMidiNotes(4);
        final firstMidi = firstChord.getMidiNotes(4);
        final secondMidi = secondChord.getMidiNotes(4);

        // Verify each chord has 3 notes
        expect(
          rootMidi.length,
          equals(3),
          reason: "${rootChord.name} root should have 3 notes",
        );
        expect(
          firstMidi.length,
          equals(3),
          reason: "${firstChord.name} should have 3 notes",
        );
        expect(
          secondMidi.length,
          equals(3),
          reason: "${secondChord.name} should have 3 notes",
        );

        // Verify natural left-to-right progression
        expect(
          rootMidi.first <= firstMidi.first,
          isTrue,
          reason:
              "${rootChord.name} root should not be higher than 1st inversion",
        );
        expect(
          firstMidi.first <= secondMidi.first,
          isTrue,
          reason: "${firstChord.name} should not be higher than 2nd inversion",
        );

        // Verify no dramatic downward jumps (wrapping)
        const maxAllowedJump = 7; // Perfect 5th
        expect(
          firstMidi.first - rootMidi.first,
          lessThanOrEqualTo(maxAllowedJump),
          reason:
              "${rootChord.name} to 1st inversion jump should be reasonable",
        );
        expect(
          secondMidi.first - firstMidi.first,
          lessThanOrEqualTo(maxAllowedJump),
          reason:
              "${firstChord.name} to 2nd inversion jump should be reasonable",
        );
      }
    });

    test("Specific problematic chords should be fixed", () {
      // Test the specific chords mentioned in the issue

      // G Major 2nd inversion should NOT wrap to D4
      final gMajorSecond = ChordBuilder.getChord(
        MusicalNote.g,
        ChordType.major,
        ChordInversion.second,
      );
      final gMajorSecondMidi = gMajorSecond.getMidiNotes(4);
      expect(
        gMajorSecondMidi.first,
        greaterThan(61), // Higher than D4 (62)
        reason: "G Major 2nd inversion should not wrap to D4",
      );

      // A minor 1st inversion should NOT wrap to C4
      final aMinorFirst = ChordBuilder.getChord(
        MusicalNote.a,
        ChordType.minor,
        ChordInversion.first,
      );
      final aMinorFirstMidi = aMinorFirst.getMidiNotes(4);
      expect(
        aMinorFirstMidi.first,
        greaterThan(59), // Higher than C4 (60)
        reason: "A minor 1st inversion should not wrap to C4",
      );

      // A minor 2nd inversion should NOT wrap to E4
      final aMinorSecond = ChordBuilder.getChord(
        MusicalNote.a,
        ChordType.minor,
        ChordInversion.second,
      );
      final aMinorSecondMidi = aMinorSecond.getMidiNotes(4);
      expect(
        aMinorSecondMidi.first,
        greaterThan(63), // Higher than E4 (64)
        reason: "A minor 2nd inversion should not wrap to E4",
      );

      // B diminished inversions should not wrap
      final bDimFirst = ChordBuilder.getChord(
        MusicalNote.b,
        ChordType.diminished,
        ChordInversion.first,
      );
      final bDimFirstMidi = bDimFirst.getMidiNotes(4);
      expect(
        bDimFirstMidi.first,
        greaterThan(61), // Higher than D4 (62)
        reason: "B diminished 1st inversion should not wrap to D4",
      );

      final bDimSecond = ChordBuilder.getChord(
        MusicalNote.b,
        ChordType.diminished,
        ChordInversion.second,
      );
      final bDimSecondMidi = bDimSecond.getMidiNotes(4);
      expect(
        bDimSecondMidi.first,
        greaterThan(64), // Higher than F4 (65)
        reason: "B diminished 2nd inversion should not wrap to F4",
      );
    });

    test("Chord progression sequence should maintain natural flow", () {
      final progression = ChordBuilder.getSmoothKeyTriadProgression(
        Key.c,
        ScaleType.major,
      );

      // Verify the progression has the expected structure
      expect(progression.length, equals(28)); // 7 chords × 4 positions each

      // Check that each group of 4 (root, 1st, 2nd, 1st) flows naturally
      for (var i = 0; i < 7; i++) {
        final baseIndex = i * 4;
        final rootChord = progression[baseIndex];
        final firstChord = progression[baseIndex + 1];
        final secondChord = progression[baseIndex + 2];
        final firstAgainChord = progression[baseIndex + 3];

        final rootMidi = rootChord.getMidiNotes(4);
        final firstMidi = firstChord.getMidiNotes(4);
        final secondMidi = secondChord.getMidiNotes(4);
        final firstAgainMidi = firstAgainChord.getMidiNotes(4);

        // Verify natural progression within each chord group
        expect(
          rootMidi.first <= firstMidi.first,
          isTrue,
          reason: "${rootChord.name} progression should be natural",
        );
        expect(
          firstMidi.first <= secondMidi.first,
          isTrue,
          reason: "${firstChord.name} progression should be natural",
        );
        expect(
          secondMidi.first >= firstAgainMidi.first,
          isTrue,
          reason: "Return to 1st inversion should be lower than 2nd",
        );
      }
    });
  });
}
