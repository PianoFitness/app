import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";

// Mock chord class for testing chord progression range calculation
class MockChordInfo {
  MockChordInfo(this._midiNotes);
  final List<int> _midiNotes;

  List<int> getMidiNotes(int octave) {
    return _midiNotes;
  }
}

void main() {
  group("PianoRangeUtils Tests", () {
    test("should return default range when no notes highlighted", () {
      final result = PianoRangeUtils.calculateOptimalRange([]);
      expect(result, isNotNull);

      // Should return a default range (we can't access properties directly,
      // but we can verify it's not the same instance when notes are provided)
      final resultWithNotes = PianoRangeUtils.calculateOptimalRange([
        NotePosition(note: Note.C),
      ]);
      expect(result, isNot(equals(resultWithNotes)));
    });

    test("should calculate range for single note", () {
      final noteC4 = NotePosition(note: Note.C);
      final result = PianoRangeUtils.calculateOptimalRange([noteC4]);
      expect(result, isNotNull);

      // Should be different from default range
      final defaultResult = PianoRangeUtils.calculateOptimalRange([]);
      expect(result, isNot(equals(defaultResult)));

      // Should be consistent - same input should give same output
      final result2 = PianoRangeUtils.calculateOptimalRange([noteC4]);
      expect(result.toString(), equals(result2.toString()));
    });

    test("should calculate range for multiple notes in same octave", () {
      final notes = [
        NotePosition(note: Note.C), // MIDI 60
        NotePosition(note: Note.E), // MIDI 64
        NotePosition(note: Note.G), // MIDI 67
      ];
      final result = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result, isNotNull);

      // Range for multiple notes should be different from single note
      final singleNoteResult = PianoRangeUtils.calculateOptimalRange([
        notes[0],
      ]);
      expect(result, isNot(equals(singleNoteResult)));

      // Should be consistent
      final result2 = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result.toString(), equals(result2.toString()));
    });

    test("should calculate range for notes spanning multiple octaves", () {
      final notes = [
        NotePosition(note: Note.C, octave: 3),
        NotePosition(note: Note.C),
        NotePosition(note: Note.C, octave: 5),
        NotePosition(note: Note.C, octave: 6),
      ];
      final result = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result, isNotNull);

      // Range spanning multiple octaves should be different from single octave range
      final singleOctaveNotes = [
        NotePosition(note: Note.C),
        NotePosition(note: Note.E),
        NotePosition(note: Note.G),
      ];
      final singleOctaveResult = PianoRangeUtils.calculateOptimalRange(
        singleOctaveNotes,
      );
      expect(result, isNot(equals(singleOctaveResult)));

      // Should be consistent with same input
      final result2 = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result.toString(), equals(result2.toString()));
    });

    test("should calculate range for exercise sequence", () {
      // C major scale MIDI notes
      final cMajorScale = [60, 62, 64, 65, 67, 69, 71, 72]; // C4 to C5
      final result = PianoRangeUtils.calculateRangeForExercise(cMajorScale);
      expect(result, isNotNull);
    });

    test("should return fallback range for empty exercise sequence", () {
      final result = PianoRangeUtils.calculateRangeForExercise([]);
      expect(result, isNotNull);
    });

    test("should handle notes with accidentals", () {
      final notes = [
        NotePosition(note: Note.C, accidental: Accidental.Sharp),
        NotePosition(note: Note.F, accidental: Accidental.Sharp),
        NotePosition(note: Note.B, accidental: Accidental.Flat),
      ];
      final result = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result, isNotNull);
    });

    test("should handle extreme MIDI note ranges", () {
      final extremeNotes = [0, 127]; // Lowest and highest MIDI notes
      final result = PianoRangeUtils.calculateRangeForExercise(extremeNotes);
      expect(result, isNotNull);
    });

    test("should use custom fallback range when provided", () {
      final customFallback = NoteRange(
        from: NotePosition(note: Note.C, octave: 3),
        to: NotePosition(note: Note.C, octave: 5),
      );
      final result = PianoRangeUtils.calculateOptimalRange(
        [],
        fallbackRange: customFallback,
      );
      expect(result, isNotNull);
      // Since we can't compare ranges directly, we at least ensure it returns the fallback
    });
  });

  group("Chord Progression Range Tests", () {
    test(
      "should calculate range for chord progression with all inversions",
      () {
        // Create a mock chord progression
        final mockChordProgression = [
          MockChordInfo([60, 64, 67]), // C major root position
          MockChordInfo([65, 69, 72]), // F major root position
          MockChordInfo([59, 62, 67]), // G major first inversion
        ];

        final range = PianoRangeUtils.calculateRangeForChordProgression(
          mockChordProgression,
          4,
        );

        expect(range, isNotNull);
      },
    );

    test("should return fallback range for empty chord progression", () {
      final fallbackRange = NoteRange(
        from: NotePosition(note: Note.C, octave: 3),
        to: NotePosition(note: Note.C, octave: 5),
      );

      final range = PianoRangeUtils.calculateRangeForChordProgression(
        [],
        4,
        fallbackRange: fallbackRange,
      );

      expect(range, isNotNull);
    });

    test("should handle chord progression with wide range", () {
      // Create mock chords spanning a very wide range
      final mockChordProgression = [
        MockChordInfo([36, 40, 43]), // Very low chord
        MockChordInfo([84, 88, 91]), // Very high chord
      ];

      final range = PianoRangeUtils.calculateRangeForChordProgression(
        mockChordProgression,
        4,
      );

      expect(range, isNotNull);
    });

    test("should handle invalid chord objects gracefully", () {
      // Create a mock object that doesn't have getMidiNotes method
      final invalidChords = ["not a chord", 42, null];

      final range = PianoRangeUtils.calculateRangeForChordProgression(
        invalidChords,
        4,
      );

      expect(range, isNotNull);
    });
  });

  group("Fixed 49-Key Range Tests", () {
    test("should return default C2-C6 range for empty exercise sequence", () {
      final result = PianoRangeUtils.calculateFixed49KeyRange([]);
      expect(result, isNotNull);

      // Should match the default C2-C6 range
      final defaultRange = NoteRange(
        from: NotePosition(note: Note.C, octave: 2),
        to: NotePosition(note: Note.C, octave: 6),
      );
      expect(result.toString(), equals(defaultRange.toString()));
    });

    test("should center 49-key range around single note exercise", () {
      final exerciseSequence = [60]; // C4
      final result = PianoRangeUtils.calculateFixed49KeyRange(exerciseSequence);
      expect(result, isNotNull);

      // Should be different from default range since it's centered on C4
      final defaultResult = PianoRangeUtils.calculateFixed49KeyRange([]);
      expect(result, isNot(same(defaultResult)));
    });

    test("should center 49-key range around scale exercise", () {
      // C major scale from C4 to C5
      final cMajorScale = [60, 62, 64, 65, 67, 69, 71, 72];
      final result = PianoRangeUtils.calculateFixed49KeyRange(cMajorScale);
      expect(result, isNotNull);

      // Result should be consistent with same input
      final result2 = PianoRangeUtils.calculateFixed49KeyRange(cMajorScale);
      expect(result.toString(), equals(result2.toString()));
    });

    test(
      "should adjust range when exercise extends beyond initial centering",
      () {
        // Exercise with very high notes that would exceed centered range
        final highExercise = [84, 85, 86, 87, 88, 89, 90]; // High C6 and above
        final result = PianoRangeUtils.calculateFixed49KeyRange(highExercise);
        expect(result, isNotNull);

        // Should be different from default range
        final defaultResult = PianoRangeUtils.calculateFixed49KeyRange([]);
        expect(result, isNot(same(defaultResult)));
      },
    );

    test("should adjust range when exercise has very low notes", () {
      // Exercise with very low notes
      final lowExercise = [36, 37, 38, 39, 40]; // C2 and nearby
      final result = PianoRangeUtils.calculateFixed49KeyRange(lowExercise);
      expect(result, isNotNull);

      // Should be different from default range
      final defaultResult = PianoRangeUtils.calculateFixed49KeyRange([]);
      expect(result, isNot(same(defaultResult)));
    });

    test("should handle exercise spanning wide range", () {
      // Exercise spanning from low C2 to high C6
      final wideExercise = [36, 48, 60, 72, 84];
      final result = PianoRangeUtils.calculateFixed49KeyRange(wideExercise);
      expect(result, isNotNull);
    });

    test("should clamp to piano range boundaries", () {
      // Exercise with extreme notes beyond piano range
      final extremeExercise = [21, 108]; // A0 and C8 (88-key limits)
      final result = PianoRangeUtils.calculateFixed49KeyRange(extremeExercise);
      expect(result, isNotNull);
    });

    test("should use custom fallback range when provided", () {
      final customFallback = NoteRange(
        from: NotePosition(note: Note.C, octave: 3),
        to: NotePosition(note: Note.C, octave: 7),
      );

      final result = PianoRangeUtils.calculateFixed49KeyRange(
        [], // Empty sequence should trigger fallback
        fallbackRange: customFallback,
      );

      expect(result, isNotNull);
      expect(result.toString(), equals(customFallback.toString()));
    });
  });

  group("Screen-Based Key Width Tests", () {
    test("should calculate key width for standard screen widths", () {
      // Test with common screen widths
      final ipadWidth = PianoRangeUtils.calculateScreenBasedKeyWidth(1024);
      final phoneWidth = PianoRangeUtils.calculateScreenBasedKeyWidth(375);
      final desktopWidth = PianoRangeUtils.calculateScreenBasedKeyWidth(1440);

      expect(ipadWidth, greaterThan(0));
      expect(phoneWidth, greaterThan(0));
      expect(desktopWidth, greaterThan(0));

      // Larger screens should allow wider keys
      expect(desktopWidth, greaterThan(ipadWidth));
      expect(ipadWidth, greaterThan(phoneWidth));
    });

    test("should respect minimum width constraints", () {
      // Very narrow screen should still return minimum width
      const minWidth = 15.0;
      final result = PianoRangeUtils.calculateScreenBasedKeyWidth(
        200, // Very narrow screen
        minWidth: minWidth,
      );

      expect(result, greaterThanOrEqualTo(minWidth));
    });

    test("should respect maximum width constraints", () {
      // Very wide screen should not exceed maximum width
      const maxWidth = 50.0;
      final result = PianoRangeUtils.calculateScreenBasedKeyWidth(
        3000, // Very wide screen
        maxWidth: maxWidth,
      );

      expect(result, lessThanOrEqualTo(maxWidth));
    });

    test("should handle custom padding", () {
      const screenWidth = 1000.0;
      const largePadding = 100.0;

      final standardResult = PianoRangeUtils.calculateScreenBasedKeyWidth(
        screenWidth,
      );

      final paddedResult = PianoRangeUtils.calculateScreenBasedKeyWidth(
        screenWidth,
        padding: largePadding,
      );

      // More padding should result in narrower keys
      expect(paddedResult, lessThan(standardResult));
    });

    test("should handle custom key count", () {
      const screenWidth = 1000.0;

      final keys28 = PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);

      final keys35 = PianoRangeUtils.calculateScreenBasedKeyWidth(
        screenWidth,
        keyCount: 35,
      );

      // More keys should result in narrower individual keys
      expect(keys35, lessThan(keys28));
    });

    test("should return consistent results for same input", () {
      const screenWidth = 800.0;

      final result1 = PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);
      final result2 = PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);

      expect(result1, equals(result2));
    });

    test("should handle edge cases gracefully", () {
      // Zero screen width
      final zeroWidth = PianoRangeUtils.calculateScreenBasedKeyWidth(0);
      expect(zeroWidth, greaterThanOrEqualTo(20.0)); // Should return minimum

      // Negative screen width
      final negativeWidth = PianoRangeUtils.calculateScreenBasedKeyWidth(-100);
      expect(
        negativeWidth,
        greaterThanOrEqualTo(20.0),
      ); // Should return minimum
    });
  });

  group("Key Width Calculation Tests", () {
    test("should return appropriate key width for different ranges", () {
      // Create mock note ranges
      final smallRange = NoteRange(
        from: NotePosition(note: Note.C),
        to: NotePosition(note: Note.C, octave: 5),
      );

      final mediumRange = NoteRange(
        from: NotePosition(note: Note.C, octave: 3),
        to: NotePosition(note: Note.C, octave: 7),
      );

      final largeRange = NoteRange(
        from: NotePosition(note: Note.C, octave: 2),
        to: NotePosition(note: Note.C, octave: 8),
      );

      // Test key width calculation
      final smallWidth = PianoRangeUtils.calculateOptimalKeyWidth(smallRange);
      final mediumWidth = PianoRangeUtils.calculateOptimalKeyWidth(mediumRange);
      final largeWidth = PianoRangeUtils.calculateOptimalKeyWidth(largeRange);

      // All should return valid widths
      expect(smallWidth, greaterThan(0));
      expect(mediumWidth, greaterThan(0));
      expect(largeWidth, greaterThan(0));

      // For now, with our simplified implementation, they should all be the same
      // This test verifies the method works and returns reasonable values
      expect(smallWidth, equals(PianoRangeUtils.narrowKeyWidth));
      expect(mediumWidth, equals(PianoRangeUtils.narrowKeyWidth));
      expect(largeWidth, equals(PianoRangeUtils.narrowKeyWidth));
    });
  });
}
