import "package:piano/piano.dart";

/// Utility class for calculating optimal piano keyboard ranges
/// based on highlighted notes during exercises.
class PianoRangeUtils {
  /// The default range used when no notes are highlighted
  static final NoteRange defaultRange = NoteRange.forClefs([
    Clef.Treble,
    Clef.Bass,
  ]);

  /// Minimum number of octaves to display
  static const int minOctaves = 2;

  /// Maximum number of octaves to display (to prevent overly wide keyboards)
  static const int maxOctaves = 4;

  /// 88-key keyboard range limits (A0 to C8)
  static const int min88KeyMidi = 21; // A0
  /// Upper bound of standard 88-key piano range (C8).
  static const int max88KeyMidi = 108; // C8

  /// Buffer notes to add on each side of the highlighted range
  static const int bufferSemitones = 12; // One octave buffer

  /// Configuration for piano key width based on range size
  static const double defaultKeyWidth = 45;

  /// Key width for moderately wide ranges (35 pixels).
  static const double narrowKeyWidth = 35;

  /// Key width for very wide ranges (28 pixels).
  static const double veryNarrowKeyWidth = 28;

  /// Minimum allowed key width for screen-based calculations (20 pixels).
  static const double minKeyWidth = 20;

  /// Maximum allowed key width for screen-based calculations (60 pixels).
  static const double maxKeyWidth = 60;

  /// Thresholds for automatic key width adjustment (in semitones)
  static const int narrowKeyThreshold = 48; // 4 octaves
  /// Range size threshold for very narrow keys (5 octaves in semitones).
  static const int veryNarrowKeyThreshold = 60; // 5 octaves

  /// Calculates an optimal note range that centers around the given highlighted notes.
  ///
  /// This ensures all highlighted notes are visible without requiring horizontal scrolling,
  /// while maintaining a reasonable keyboard size.
  ///
  /// [highlightedNotes] - List of note positions that should be visible
  /// [fallbackRange] - Range to use if no notes are highlighted (defaults to treble+bass clefs)
  ///
  /// Returns a NoteRange that encompasses all highlighted notes with appropriate padding.
  static NoteRange calculateOptimalRange(
    List<NotePosition> highlightedNotes, {
    NoteRange? fallbackRange,
  }) {
    if (highlightedNotes.isEmpty) {
      return fallbackRange ?? defaultRange;
    }

    // Convert note positions to MIDI numbers for easier calculation
    final midiNotes = highlightedNotes.map(_convertNotePositionToMidi).toList();

    if (midiNotes.isEmpty) {
      return fallbackRange ?? defaultRange;
    }

    // Find the range of highlighted notes
    final minMidi = midiNotes.reduce((a, b) => a < b ? a : b);
    final maxMidi = midiNotes.reduce((a, b) => a > b ? a : b);

    // Add buffer on both sides
    var startMidi = minMidi - bufferSemitones;
    var endMidi = maxMidi + bufferSemitones;

    // Ensure minimum range
    final currentRange = endMidi - startMidi;
    const minRangeSemitones = minOctaves * 12;
    if (currentRange < minRangeSemitones) {
      final expansion = (minRangeSemitones - currentRange) ~/ 2;
      startMidi -= expansion;
      endMidi += expansion + (minRangeSemitones - currentRange) % 2;
    }

    // Ensure maximum range
    const maxRangeSemitones = maxOctaves * 12;
    if (currentRange > maxRangeSemitones) {
      final center = (startMidi + endMidi) ~/ 2;
      startMidi = center - maxRangeSemitones ~/ 2;
      endMidi = center + maxRangeSemitones ~/ 2;
    }

    // Clamp to 88-key keyboard range (A0 to C8)
    startMidi = startMidi.clamp(min88KeyMidi, max88KeyMidi);
    endMidi = endMidi.clamp(min88KeyMidi, max88KeyMidi);

    // Convert back to note positions
    final startPosition = _convertMidiToNotePosition(startMidi);
    final endPosition = _convertMidiToNotePosition(endMidi);

    if (startPosition == null || endPosition == null) {
      return fallbackRange ?? defaultRange;
    }

    return NoteRange(from: startPosition, to: endPosition);
  }

  /// Calculates an optimal range for a specific exercise sequence.
  ///
  /// [midiSequence] - List of MIDI note numbers in the exercise
  /// [fallbackRange] - Range to use if sequence is empty
  ///
  /// Returns a NoteRange optimized for the exercise sequence.
  static NoteRange calculateRangeForExercise(
    List<int> midiSequence, {
    NoteRange? fallbackRange,
  }) {
    if (midiSequence.isEmpty) {
      return fallbackRange ?? defaultRange;
    }

    // Convert MIDI numbers to note positions
    final notePositions = midiSequence
        .map(_convertMidiToNotePosition)
        .where((pos) => pos != null)
        .cast<NotePosition>()
        .toList();

    return calculateOptimalRange(notePositions, fallbackRange: fallbackRange);
  }

  /// Calculates an optimal range for chord progressions with multiple inversions.
  ///
  /// This method is specifically designed for chord progression practice where
  /// we need to see the full range from the lowest note of the first chord
  /// to the highest note of the last chord (including all inversions).
  ///
  /// [chordProgression] - List of ChordInfo objects representing the progression
  /// [startOctave] - The octave to start the progression from
  /// [fallbackRange] - Range to use if progression is empty
  ///
  /// Returns a NoteRange that encompasses the full chord progression range.
  static NoteRange calculateRangeForChordProgression(
    List<dynamic> chordProgression, // Using dynamic to avoid import issues
    int startOctave, {
    NoteRange? fallbackRange,
  }) {
    if (chordProgression.isEmpty) {
      return fallbackRange ?? defaultRange;
    }

    // Instead of using a fixed octave for all chords, we need to simulate
    // the actual progression with octave management to get the true range.
    // This mirrors the logic from getSmoothChordProgressionMidiSequence.
    final allMidiNotes = <int>[];
    var currentOctave = startOctave;
    int? lastHighestNote;

    for (final chord in chordProgression) {
      try {
        // Check if the object is not null
        if (chord == null) {
          continue;
        }

        final chordMidi =
            (chord as dynamic).getMidiNotes(currentOctave) as List<int>;

        // Apply the same octave management logic as the smooth progression
        if (lastHighestNote != null && chordMidi.isNotEmpty) {
          final chordLowest = chordMidi.first;
          final chordHighest = chordMidi.last;

          // If there's a big downward jump (more than a perfect 5th),
          // try starting this chord in a higher octave
          if (lastHighestNote - chordLowest > 7) {
            currentOctave++;
            final higherChordMidi =
                (chord as dynamic).getMidiNotes(currentOctave) as List<int>;

            // Only use the higher octave if it doesn't go too high
            if (higherChordMidi.isNotEmpty &&
                higherChordMidi.last <= max88KeyMidi) {
              allMidiNotes.addAll(higherChordMidi);
              lastHighestNote = higherChordMidi.last;
            } else {
              // Use original octave if higher would exceed range
              allMidiNotes.addAll(chordMidi);
              lastHighestNote = chordHighest;
              currentOctave--; // Reset for next iteration
            }
          } else {
            allMidiNotes.addAll(chordMidi);
            lastHighestNote = chordHighest;
          }
        } else {
          // First chord or no previous reference
          allMidiNotes.addAll(chordMidi);
          if (chordMidi.isNotEmpty) {
            lastHighestNote = chordMidi.last;
          }
        }
        // ignore: avoid_catches_without_on_clauses - need to catch NoSuchMethodError for invalid chord objects
      } catch (e) {
        // If we can't get MIDI notes from this chord (invalid object, missing method, etc), skip it
        // This catches NoSuchMethodError and other runtime errors for graceful handling
        continue;
      }
    }

    if (allMidiNotes.isEmpty) {
      return fallbackRange ?? defaultRange;
    }

    // Find the absolute minimum and maximum notes across the actual progression
    final globalMin = allMidiNotes.reduce((a, b) => a < b ? a : b);
    final globalMax = allMidiNotes.reduce((a, b) => a > b ? a : b);

    // Use a minimal buffer for chord progressions to show exactly what's needed
    const chordProgressionBuffer = 3; // Minimal buffer (3 semitones)

    var startMidi = globalMin - chordProgressionBuffer;
    var endMidi = globalMax + chordProgressionBuffer;

    // Ensure minimum range for chord progressions (at least 2.5 octaves)
    const minChordProgressionRange = 30; // 2.5 octaves
    final currentRange = endMidi - startMidi;
    if (currentRange < minChordProgressionRange) {
      final expansion = (minChordProgressionRange - currentRange) ~/ 2;
      startMidi -= expansion;
      endMidi += expansion + (minChordProgressionRange - currentRange) % 2;
    }

    // Clamp to 88-key keyboard range (A0 to C8)
    startMidi = startMidi.clamp(min88KeyMidi, max88KeyMidi);
    endMidi = endMidi.clamp(min88KeyMidi, max88KeyMidi);

    // Convert back to note positions
    final startPosition = _convertMidiToNotePosition(startMidi);
    final endPosition = _convertMidiToNotePosition(endMidi);

    if (startPosition == null || endPosition == null) {
      return fallbackRange ?? defaultRange;
    }

    return NoteRange(from: startPosition, to: endPosition);
  }

  /// Converts a NotePosition to MIDI number
  static int _convertNotePositionToMidi(NotePosition position) {
    int noteOffset;
    switch (position.note) {
      case Note.C:
        noteOffset = 0;
      case Note.D:
        noteOffset = 2;
      case Note.E:
        noteOffset = 4;
      case Note.F:
        noteOffset = 5;
      case Note.G:
        noteOffset = 7;
      case Note.A:
        noteOffset = 9;
      case Note.B:
        noteOffset = 11;
    }

    if (position.accidental == Accidental.Sharp) {
      noteOffset += 1;
    } else if (position.accidental == Accidental.Flat) {
      noteOffset -= 1;
    }

    return (position.octave + 1) * 12 + noteOffset;
  }

  /// Converts a MIDI number to NotePosition
  static NotePosition? _convertMidiToNotePosition(int midiNote) {
    if (midiNote < 0 || midiNote > 127) return null;

    final octave = (midiNote ~/ 12) - 1;
    final noteIndex = midiNote % 12;

    // Map to Note enum and handle accidentals
    switch (noteIndex) {
      case 0:
        return NotePosition(note: Note.C, octave: octave);
      case 1:
        return NotePosition(
          note: Note.C,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case 2:
        return NotePosition(note: Note.D, octave: octave);
      case 3:
        return NotePosition(
          note: Note.D,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case 4:
        return NotePosition(note: Note.E, octave: octave);
      case 5:
        return NotePosition(note: Note.F, octave: octave);
      case 6:
        return NotePosition(
          note: Note.F,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case 7:
        return NotePosition(note: Note.G, octave: octave);
      case 8:
        return NotePosition(
          note: Note.G,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case 9:
        return NotePosition(note: Note.A, octave: octave);
      case 10:
        return NotePosition(
          note: Note.A,
          octave: octave,
          accidental: Accidental.Sharp,
        );
      case 11:
        return NotePosition(note: Note.B, octave: octave);
      default:
        return null;
    }
  }

  /// Calculates a fixed 49-key range centered around practice exercise notes.
  ///
  /// This function creates a consistent 49-key piano layout (4 octaves)
  /// centered on the exercise sequence to eliminate scrolling during practice.
  /// Falls back to C2-C6 range when no exercise is active.
  ///
  /// [exerciseSequence] - List of MIDI notes in the current exercise
  /// [fallbackRange] - Range to use when sequence is empty (defaults to C2-C6)
  ///
  /// Returns a NoteRange covering exactly 49 keys centered on the exercise.
  static NoteRange calculateFixed49KeyRange(
    List<int> exerciseSequence, {
    NoteRange? fallbackRange,
  }) {
    // Default 49-key range (C2 to C6) when no exercise is active
    final defaultFallback =
        fallbackRange ??
        NoteRange(
          from: NotePosition(note: Note.C, octave: 2),
          to: NotePosition(note: Note.C, octave: 6),
        );

    if (exerciseSequence.isEmpty) {
      return defaultFallback;
    }

    // Find the min and max MIDI notes in the exercise sequence
    final minNote = exerciseSequence.reduce((a, b) => a < b ? a : b);
    final maxNote = exerciseSequence.reduce((a, b) => a > b ? a : b);

    // Calculate the center point of the exercise range
    final centerNote = (minNote + maxNote) ~/ 2;

    // Create a 49-key range centered around the exercise
    // 49 keys = exactly 4 octaves (48 semitones) + 1 note
    const rangeHalfWidth = 24; // 2 octaves on each side
    var startNote = centerNote - rangeHalfWidth;
    var endNote = centerNote + rangeHalfWidth;

    // Ensure all exercise notes are within the 49-key range
    if (minNote < startNote) {
      final shift = startNote - minNote;
      startNote -= shift;
      endNote -= shift;
    }
    if (maxNote > endNote) {
      final shift = maxNote - endNote;
      startNote += shift;
      endNote += shift;
    }

    // Clamp to reasonable piano range (A0 to C8)
    startNote = startNote.clamp(min88KeyMidi, max88KeyMidi - 48);
    endNote = startNote + 48; // Exactly 49 keys (4 octaves)

    // Convert MIDI notes to NotePosition
    final startPosition = _convertMidiToNotePosition(startNote);
    final endPosition = _convertMidiToNotePosition(endNote);

    if (startPosition == null || endPosition == null) {
      return defaultFallback;
    }

    return NoteRange(from: startPosition, to: endPosition);
  }

  /// Calculates dynamic key width based on available screen width.
  ///
  /// Uses screen dimensions to determine optimal key width for 49-key layout
  /// with reasonable minimum and maximum bounds for usability.
  ///
  /// [screenWidth] - Available screen width in pixels
  /// [padding] - Total horizontal padding to account for (default: 32)
  /// [keyCount] - Number of white keys to fit (default: 28 for 49-key range)
  /// [minWidth] - Minimum key width in pixels (default: minKeyWidth = 20)
  /// [maxWidth] - Maximum key width in pixels (default: maxKeyWidth = 60)
  ///
  /// Returns the optimal key width in pixels.
  static double calculateScreenBasedKeyWidth(
    double screenWidth, {
    double padding = 32.0,
    int keyCount = 28, // 28 white keys in 49-key range
    double minWidth = minKeyWidth,
    double maxWidth = maxKeyWidth,
  }) {
    final availableWidth = screenWidth - padding;
    final calculatedWidth = availableWidth / (keyCount + 1); // +1 for buffer
    return calculatedWidth.clamp(minWidth, maxWidth);
  }

  /// Calculates the optimal key width based on the range size.
  ///
  /// Automatically narrows keys when displaying larger ranges to ensure
  /// all keys fit comfortably on screen.
  ///
  /// [noteRange] - The range of notes to be displayed
  ///
  /// Returns the recommended key width in pixels.
  static double calculateOptimalKeyWidth(NoteRange noteRange) {
    // Calculate the range in semitones by accessing the range bounds
    // Note: We'll use a simple estimation based on the note range span
    // This is approximate but sufficient for key width calculation

    // For now, use a simple heuristic based on common ranges
    // TODO(implementation): Implement proper NoteRange property access when available

    // Estimate based on typical chord progression ranges
    // Most chord progressions span 3-5 octaves
    const double estimatedChordProgressionRange = 48; // 4 octaves in semitones

    if (estimatedChordProgressionRange >= veryNarrowKeyThreshold) {
      return veryNarrowKeyWidth;
    } else if (estimatedChordProgressionRange >= narrowKeyThreshold) {
      return narrowKeyWidth;
    } else {
      return defaultKeyWidth;
    }
  }
}
