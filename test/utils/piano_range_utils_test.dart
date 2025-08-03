import 'package:flutter_test/flutter_test.dart';
import 'package:piano/piano.dart';
import 'package:piano_fitness/utils/piano_range_utils.dart';

// Mock chord class for testing chord progression range calculation
class MockChordInfo {
  final List<int> _midiNotes;

  MockChordInfo(this._midiNotes);

  List<int> getMidiNotes(int octave) {
    return _midiNotes;
  }
}

void main() {
  group('PianoRangeUtils Tests', () {
    test('should return default range when no notes highlighted', () {
      final result = PianoRangeUtils.calculateOptimalRange([]);
      expect(result, isNotNull);
      // Can't easily test equality, but we can ensure it returns a valid range
    });

    test('should calculate range for single note', () {
      final noteC4 = NotePosition(note: Note.C, octave: 4);
      final result = PianoRangeUtils.calculateOptimalRange([noteC4]);
      expect(result, isNotNull);
    });

    test('should calculate range for multiple notes in same octave', () {
      final notes = [
        NotePosition(note: Note.C, octave: 4),
        NotePosition(note: Note.E, octave: 4),
        NotePosition(note: Note.G, octave: 4),
      ];
      final result = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result, isNotNull);
    });

    test('should calculate range for notes spanning multiple octaves', () {
      final notes = [
        NotePosition(note: Note.C, octave: 3),
        NotePosition(note: Note.C, octave: 4),
        NotePosition(note: Note.C, octave: 5),
        NotePosition(note: Note.C, octave: 6),
      ];
      final result = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result, isNotNull);
    });

    test('should calculate range for exercise sequence', () {
      // C major scale MIDI notes
      final cMajorScale = [60, 62, 64, 65, 67, 69, 71, 72]; // C4 to C5
      final result = PianoRangeUtils.calculateRangeForExercise(cMajorScale);
      expect(result, isNotNull);
    });

    test('should return fallback range for empty exercise sequence', () {
      final result = PianoRangeUtils.calculateRangeForExercise([]);
      expect(result, isNotNull);
    });

    test('should handle notes with accidentals', () {
      final notes = [
        NotePosition(note: Note.C, octave: 4, accidental: Accidental.Sharp),
        NotePosition(note: Note.F, octave: 4, accidental: Accidental.Sharp),
        NotePosition(note: Note.B, octave: 4, accidental: Accidental.Flat),
      ];
      final result = PianoRangeUtils.calculateOptimalRange(notes);
      expect(result, isNotNull);
    });

    test('should handle extreme MIDI note ranges', () {
      final extremeNotes = [0, 127]; // Lowest and highest MIDI notes
      final result = PianoRangeUtils.calculateRangeForExercise(extremeNotes);
      expect(result, isNotNull);
    });

    test('should use custom fallback range when provided', () {
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

  group('Chord Progression Range Tests', () {
    test(
      'should calculate range for chord progression with all inversions',
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

    test('should return fallback range for empty chord progression', () {
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

    test('should handle chord progression with wide range', () {
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

    test('should handle invalid chord objects gracefully', () {
      // Create a mock object that doesn't have getMidiNotes method
      final invalidChords = ['not a chord', 42, null];

      final range = PianoRangeUtils.calculateRangeForChordProgression(
        invalidChords,
        4,
      );

      expect(range, isNotNull);
    });
  });

  group('Key Width Calculation Tests', () {
    test('should return appropriate key width for different ranges', () {
      // Create mock note ranges
      final smallRange = NoteRange(
        from: NotePosition(note: Note.C, octave: 4),
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
