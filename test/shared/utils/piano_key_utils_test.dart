// Unit tests for piano key utility functions.
//
// Tests the core logic for identifying black vs white keys on a piano
// and utility functions for working with piano key ranges.

import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/utils/piano_key_utils.dart";

void main() {
  group("Piano Key Identification", () {
    test("should correctly identify black keys in C major octave", () {
      // Test MIDI notes 60-71 (C4 to B4)
      expect(isBlackKey(60), false); // C4 - white
      expect(isBlackKey(61), true); // C#4 - black
      expect(isBlackKey(62), false); // D4 - white
      expect(isBlackKey(63), true); // D#4 - black
      expect(isBlackKey(64), false); // E4 - white
      expect(isBlackKey(65), false); // F4 - white
      expect(isBlackKey(66), true); // F#4 - black
      expect(isBlackKey(67), false); // G4 - white
      expect(isBlackKey(68), true); // G#4 - black
      expect(isBlackKey(69), false); // A4 - white
      expect(isBlackKey(70), true); // A#4 - black
      expect(isBlackKey(71), false); // B4 - white
    });

    test("should correctly identify white keys in C major octave", () {
      // Test MIDI notes 60-71 (C4 to B4)
      expect(isWhiteKey(60), true); // C4 - white
      expect(isWhiteKey(61), false); // C#4 - black
      expect(isWhiteKey(62), true); // D4 - white
      expect(isWhiteKey(63), false); // D#4 - black
      expect(isWhiteKey(64), true); // E4 - white
      expect(isWhiteKey(65), true); // F4 - white
      expect(isWhiteKey(66), false); // F#4 - black
      expect(isWhiteKey(67), true); // G4 - white
      expect(isWhiteKey(68), false); // G#4 - black
      expect(isWhiteKey(69), true); // A4 - white
      expect(isWhiteKey(70), false); // A#4 - black
      expect(isWhiteKey(71), true); // B4 - white
    });

    test("should maintain pattern consistency across octaves", () {
      // Test pattern consistency across different octaves
      // Black key pattern should repeat every 12 semitones

      // Test octave 3 (MIDI 48-59)
      expect(isBlackKey(48), false); // C3 - white
      expect(isBlackKey(49), true); // C#3 - black
      expect(isBlackKey(50), false); // D3 - white
      expect(isBlackKey(51), true); // D#3 - black
      expect(isBlackKey(52), false); // E3 - white
      expect(isBlackKey(53), false); // F3 - white
      expect(isBlackKey(54), true); // F#3 - black
      expect(isBlackKey(55), false); // G3 - white
      expect(isBlackKey(56), true); // G#3 - black
      expect(isBlackKey(57), false); // A3 - white
      expect(isBlackKey(58), true); // A#3 - black
      expect(isBlackKey(59), false); // B3 - white

      // Test octave 5 (MIDI 72-83)
      expect(isBlackKey(72), false); // C5 - white
      expect(isBlackKey(73), true); // C#5 - black
      expect(isBlackKey(74), false); // D5 - white
      expect(isBlackKey(75), true); // D#5 - black
      expect(isBlackKey(76), false); // E5 - white
      expect(isBlackKey(77), false); // F5 - white
      expect(isBlackKey(78), true); // F#5 - black
      expect(isBlackKey(79), false); // G5 - white
      expect(isBlackKey(80), true); // G#5 - black
      expect(isBlackKey(81), false); // A5 - white
      expect(isBlackKey(82), true); // A#5 - black
      expect(isBlackKey(83), false); // B5 - white
    });

    test("should work at octave boundaries", () {
      // Test edge cases at octave boundaries
      expect(isBlackKey(0), false); // C-1 - white
      expect(isBlackKey(11), false); // B-1 - white
      expect(isBlackKey(12), false); // C0 - white
      expect(isBlackKey(127), false); // G9 - white (MIDI max)
    });
  });

  group("Piano Key Range Functions", () {
    test("should get correct white keys in range 60-71", () {
      final whiteKeys = getWhiteKeysInRange(60, 71);

      // Should be exactly 7 white keys: C, D, E, F, G, A, B
      expect(whiteKeys.length, equals(7));
      expect(whiteKeys, equals([60, 62, 64, 65, 67, 69, 71]));
    });

    test("should get correct black keys in range 60-71", () {
      final blackKeys = getBlackKeysInRange(60, 71);

      // Should be exactly 5 black keys: C#, D#, F#, G#, A#
      expect(blackKeys.length, equals(5));
      expect(blackKeys, equals([61, 63, 66, 68, 70]));
    });

    test("should handle single note ranges", () {
      // Test single white key
      expect(getWhiteKeysInRange(60, 60), equals([60])); // C4
      expect(getBlackKeysInRange(60, 60), isEmpty);

      // Test single black key
      expect(getBlackKeysInRange(61, 61), equals([61])); // C#4
      expect(getWhiteKeysInRange(61, 61), isEmpty);
    });

    test("should handle empty ranges", () {
      // Test invalid range (end < start)
      expect(getWhiteKeysInRange(71, 60), isEmpty);
      expect(getBlackKeysInRange(71, 60), isEmpty);
    });

    test("should handle larger ranges correctly", () {
      // Test two octave range (24 semitones)
      final whiteKeys = getWhiteKeysInRange(48, 71);
      final blackKeys = getBlackKeysInRange(48, 71);

      // Two octaves should have 14 white keys and 10 black keys
      expect(whiteKeys.length, equals(14));
      expect(blackKeys.length, equals(10));
      expect(whiteKeys.length + blackKeys.length, equals(24));
    });
  });

  group("Piano Key Logic Validation", () {
    test("should have complementary white/black key functions", () {
      // Test that isWhiteKey and isBlackKey are perfect complements
      for (int note = 0; note <= 127; note++) {
        expect(
          isWhiteKey(note),
          equals(!isBlackKey(note)),
          reason:
              "Note $note should be either white XOR black, not both or neither",
        );
      }
    });

    test("should maintain 7:5 white:black ratio per octave", () {
      // Test that each complete octave has exactly 7 white and 5 black keys
      for (int octaveStart = 0; octaveStart <= 120; octaveStart += 12) {
        final whiteCount = getWhiteKeysInRange(
          octaveStart,
          octaveStart + 11,
        ).length;
        final blackCount = getBlackKeysInRange(
          octaveStart,
          octaveStart + 11,
        ).length;

        expect(
          whiteCount,
          equals(7),
          reason: "Octave starting at $octaveStart should have 7 white keys",
        );
        expect(
          blackCount,
          equals(5),
          reason: "Octave starting at $octaveStart should have 5 black keys",
        );
      }
    });

    test("should correctly identify standard piano black key positions", () {
      // Test the standard piano black key pattern within each octave
      // Black keys occur at positions: 1, 3, 6, 8, 10 (C#, D#, F#, G#, A#)
      const expectedBlackPositions = {1, 3, 6, 8, 10};

      for (int note = 0; note <= 127; note++) {
        final positionInOctave = note % 12;
        final shouldBeBlack = expectedBlackPositions.contains(positionInOctave);

        expect(
          isBlackKey(note),
          equals(shouldBeBlack),
          reason:
              "Note $note (position $positionInOctave in octave) black key identification failed",
        );
      }
    });
  });
}
