import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart";

void main() {
  group("Smooth Chord Progression Tests", () {
    test("should generate smooth progression with 4 positions per chord", () {
      final smoothProgression = ChordBuilder.getSmoothKeyTriadProgression(
        Key.c,
        ScaleType.major,
      );

      // Should have 7 chords × 4 positions = 28 positions
      expect(smoothProgression.length, equals(28));

      // First chord (C major) should have sequence: root, 1st, 2nd, 1st
      expect(smoothProgression[0].inversion, equals(ChordInversion.root));
      expect(smoothProgression[1].inversion, equals(ChordInversion.first));
      expect(smoothProgression[2].inversion, equals(ChordInversion.second));
      expect(smoothProgression[3].inversion, equals(ChordInversion.first));

      // All first 4 chords should be C major
      for (var i = 0; i < 4; i++) {
        expect(smoothProgression[i].rootNote, equals(MusicalNote.c));
        expect(smoothProgression[i].type, equals(ChordType.major));
      }
    });

    test("should generate MIDI sequence without large downward jumps", () {
      final midiSequence = ChordBuilder.getSmoothChordProgressionMidiSequence(
        Key.c,
        ScaleType.major,
        4, // Start in 4th octave
      );

      expect(midiSequence.isNotEmpty, true);

      // Check for large downward jumps (more than an octave)
      var hasLargeDownwardJump = false;
      for (var i = 1; i < midiSequence.length; i++) {
        final jump = midiSequence[i] - midiSequence[i - 1];
        if (jump < -12) {
          // More than an octave down
          hasLargeDownwardJump = true;
          break;
        }
      }

      // Should not have large downward jumps with smooth progression
      expect(
        hasLargeDownwardJump,
        false,
        reason: "Smooth progression should avoid large downward jumps",
      );
    });

    test("should handle high octaves without exceeding MIDI range", () {
      final midiSequence = ChordBuilder.getSmoothChordProgressionMidiSequence(
        Key.c,
        ScaleType.major,
        6, // Start quite high
      );

      expect(midiSequence.isNotEmpty, true);

      // All notes should be within valid MIDI range
      for (final note in midiSequence) {
        expect(note, greaterThanOrEqualTo(0));
        expect(note, lessThanOrEqualTo(127));
      }
    });

    test("should allow progression up to higher octaves", () {
      final regularProgression = ChordBuilder.getChordProgressionMidiSequence(
        Key.c,
        ScaleType.major,
        4,
      );

      final smoothProgression =
          ChordBuilder.getSmoothChordProgressionMidiSequence(
            Key.c,
            ScaleType.major,
            4,
          );

      // Smooth progression should potentially reach higher notes
      // (since it avoids downward jumps by moving up octaves)
      final regularMax = regularProgression.reduce((a, b) => a > b ? a : b);
      final smoothMax = smoothProgression.reduce((a, b) => a > b ? a : b);

      // The smooth progression should reach at least as high as regular
      // (and likely higher due to avoiding downward jumps)
      expect(smoothMax, greaterThanOrEqualTo(regularMax));
    });
  });
}
