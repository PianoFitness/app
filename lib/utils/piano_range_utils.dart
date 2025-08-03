import 'package:piano/piano.dart';

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

  /// Buffer notes to add on each side of the highlighted range
  static const int bufferSemitones = 12; // One octave buffer

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
    final midiNotes = highlightedNotes
        .map((pos) => _convertNotePositionToMidi(pos))
        .toList();

    if (midiNotes.isEmpty) {
      return fallbackRange ?? defaultRange;
    }

    // Find the range of highlighted notes
    final minMidi = midiNotes.reduce((a, b) => a < b ? a : b);
    final maxMidi = midiNotes.reduce((a, b) => a > b ? a : b);

    // Add buffer on both sides
    int startMidi = minMidi - bufferSemitones;
    int endMidi = maxMidi + bufferSemitones;

    // Ensure minimum range
    final currentRange = endMidi - startMidi;
    final minRangeSemitones = minOctaves * 12;
    if (currentRange < minRangeSemitones) {
      final expansion = (minRangeSemitones - currentRange) ~/ 2;
      startMidi -= expansion;
      endMidi += expansion + (minRangeSemitones - currentRange) % 2;
    }

    // Ensure maximum range
    final maxRangeSemitones = maxOctaves * 12;
    if (currentRange > maxRangeSemitones) {
      final center = (startMidi + endMidi) ~/ 2;
      startMidi = center - maxRangeSemitones ~/ 2;
      endMidi = center + maxRangeSemitones ~/ 2;
    }

    // Clamp to valid MIDI range (0-127)
    startMidi = startMidi.clamp(0, 127);
    endMidi = endMidi.clamp(0, 127);

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

  /// Converts a NotePosition to MIDI number
  static int _convertNotePositionToMidi(NotePosition position) {
    int noteOffset;
    switch (position.note) {
      case Note.C:
        noteOffset = 0;
        break;
      case Note.D:
        noteOffset = 2;
        break;
      case Note.E:
        noteOffset = 4;
        break;
      case Note.F:
        noteOffset = 5;
        break;
      case Note.G:
        noteOffset = 7;
        break;
      case Note.A:
        noteOffset = 9;
        break;
      case Note.B:
        noteOffset = 11;
        break;
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
}
