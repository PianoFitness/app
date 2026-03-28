import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

export "package:piano_fitness/domain/models/music/chord_type.dart";

/// Contains information about a chord including its notes, type, and inversion.
///
/// This class represents a complete chord with all the information needed
/// for practice exercises, MIDI playback, and display purposes.
class ChordInfo {
  /// Creates a new ChordInfo with all required parameters.
  const ChordInfo({
    required this.notes,
    required this.type,
    required this.inversion,
    required this.name,
    required this.rootNote,
  });

  /// The musical notes that make up this chord.
  final List<MusicalNote> notes;

  /// The harmonic type of the chord (major, minor, etc.).
  final ChordType type;

  /// The inversion of the chord (root position, first inversion, etc.).
  final ChordInversion inversion;

  /// The human-readable name of the chord (e.g., "C Major").
  final String name;

  /// The root note of the chord.
  final MusicalNote rootNote;

  /// Converts the chord to MIDI note numbers for the specified octave.
  ///
  /// Returns a list of MIDI notes representing the chord tones.
  /// The [octave] parameter determines the starting octave for the chord.
  List<MidiNote> getMidiNotes(int octave) {
    final midiNotes = <MidiNote>[];

    // Adjust the starting octave based on inversion to maintain natural progression
    var adjustedOctave = octave;

    // For inversions, if the first note would be lower than the root note,
    // bump the entire chord up an octave to maintain the natural flow
    if (inversion != ChordInversion.root && notes.isNotEmpty) {
      final firstNoteMidi = NoteUtils.noteToMidiNumber(notes[0], octave);
      final rootNoteMidi = NoteUtils.noteToMidiNumber(rootNote, octave);

      // If the inversion starts with a note lower than the root,
      // move the whole chord up an octave
      if (firstNoteMidi < rootNoteMidi) {
        adjustedOctave++;
      }
    }

    for (var i = 0; i < notes.length; i++) {
      var noteOctave = adjustedOctave;
      var baseMidiNote = NoteUtils.noteToMidiNumber(notes[i], noteOctave);

      // For chord inversions, ensure ascending order by bumping notes up an octave as needed
      if (midiNotes.isNotEmpty) {
        final previousMidi =
            midiNotes.last.value; // Get int value from MidiNote

        // If this note would be lower than or equal to the previous note,
        // bump it up an octave to maintain proper ascending voicing
        const maxIterations = 10; // Safety limit to prevent infinite loops
        var iterations = 0;
        while (baseMidiNote <= previousMidi &&
            baseMidiNote < 127 &&
            iterations < maxIterations) {
          // Allow up to MIDI 127
          noteOctave++;
          baseMidiNote = NoteUtils.noteToMidiNumber(notes[i], noteOctave);
          iterations++;
        }
      }

      // Ensure we don't exceed MIDI range (but allow up to 127 for edge cases)
      // Prefer 88-key range (108) but allow higher for testing/edge cases
      if (baseMidiNote <= 127) {
        midiNotes.add(MidiNote(baseMidiNote));
      }
    }

    return midiNotes;
  }

  /// Returns MIDI note numbers for the specified hand selection.
  ///
  /// This method generates hand-specific chord voicings:
  /// - [HandSelection.both]: Full chord in left hand (one octave lower) + full chord in right hand
  /// - [HandSelection.left]: Full chord one octave lower than specified octave
  /// - [HandSelection.right]: Full chord at specified octave
  ///
  /// The hand-specific filtering follows standard piano pedagogy:
  /// - Both hands play the same chord shape for muscle memory and visualization
  /// - Left hand plays one octave lower for proper piano range
  /// - Single hand exercises practice the complete chord structure in each hand
  /// - For triads (3 notes), each hand plays all 3 notes
  /// - For seventh chords (4 notes), each hand plays all 4 notes
  /// - This approach prioritizes pattern awareness and muscle memory over voice leading
  /// - Students learn the full chord structure in both hands for foundational learning
  /// - This matches the scales/arpeggios pattern for pedagogical consistency
  List<MidiNote> getMidiNotesForHand(int octave, HandSelection hand) {
    final allNotes = getMidiNotes(octave);

    switch (hand) {
      case HandSelection.both:
        // Both hands: full chord in each hand, left hand one octave lower
        // For triads (3 notes) and seventh chords (4 notes), each hand plays
        // the complete chord structure for pattern awareness and muscle memory.
        // This matches the scales/arpeggios pattern for pedagogical consistency.
        if (allNotes.isEmpty) return [];

        final result = <MidiNote>[];
        // Left hand: all notes one octave lower
        final octaveDown = MusicalConstants.semitonesPerOctave;
        result.addAll(
          allNotes.map((note) => note.transpose(-octaveDown)).toList(),
        );
        // Right hand: all notes at the specified octave
        result.addAll(allNotes);
        return result;
      case HandSelection.left:
        // Left hand plays full chord one octave lower
        // This matches the scales/arpeggios pattern where each hand
        // practices the complete musical structure
        if (allNotes.isEmpty) return [];
        final octaveDown = MusicalConstants.semitonesPerOctave;
        return allNotes.map((note) => note.transpose(-octaveDown)).toList();
      case HandSelection.right:
        // Right hand plays full chord at specified octave
        // This matches the scales/arpeggios pattern for pedagogical consistency
        return allNotes;
    }
  }
}
