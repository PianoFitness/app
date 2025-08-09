import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart";

/// The different chord qualities supported for chord practice.
///
/// Each type represents a different harmonic structure with its own
/// characteristic sound and theoretical function.
enum ChordType {
  /// Major chord - bright, stable sound (1-3-5)
  major,

  /// Minor chord - darker, more melancholic sound (1-♭3-5)
  minor,

  /// Diminished chord - tense, unstable sound (1-♭3-♭5)
  diminished,

  /// Augmented chord - mysterious, floating sound (1-3-#5)
  augmented,
}

/// The different inversions available for chord practice.
///
/// Inversions change the bass note of the chord while preserving
/// the harmony, creating smoother voice leading in progressions.
enum ChordInversion {
  /// Root position - root note in bass
  root,

  /// First inversion - third in bass
  first,

  /// Second inversion - fifth in bass
  second,
}

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
  /// Returns a list of MIDI note numbers representing the chord tones.
  /// The [octave] parameter determines the starting octave for the chord.
  List<int> getMidiNotes(int octave) {
    final midiNotes = <int>[];

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
        final previousMidi = midiNotes.last;

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
        midiNotes.add(baseMidiNote);
      }
    }

    return midiNotes;
  }
}

/// Provides static definitions and factory methods for creating chords.
///
/// This class contains the logic for generating chord progressions, determining
/// chord types within keys, and creating smooth voice-led chord sequences
/// for practice exercises.
class ChordDefinitions {
  static const Map<ChordType, List<int>> _chordIntervals = {
    ChordType.major: [0, 4, 7],
    ChordType.minor: [0, 3, 7],
    ChordType.diminished: [0, 3, 6],
    ChordType.augmented: [0, 4, 8],
  };

  static const Map<ChordType, String> _chordTypeNames = {
    ChordType.major: "",
    ChordType.minor: "m",
    ChordType.diminished: "°",
    ChordType.augmented: "+",
  };

  static const Map<ChordInversion, String> _inversionNames = {
    ChordInversion.root: "",
    ChordInversion.first: "1st inv",
    ChordInversion.second: "2nd inv",
  };

  /// Creates a ChordInfo object for the specified parameters.
  ///
  /// This is the main factory method for creating chords with proper
  /// note sequences and naming.
  static ChordInfo getChord(
    MusicalNote rootNote,
    ChordType type,
    ChordInversion inversion,
  ) {
    final intervals = _chordIntervals[type]!;
    final notes = <MusicalNote>[];

    for (final interval in intervals) {
      final noteIndex = (rootNote.index + interval) % 12;
      notes.add(MusicalNote.values[noteIndex]);
    }

    final invertedNotes = _applyInversion(notes, inversion);
    final chordName = _buildChordName(rootNote, type, inversion);

    return ChordInfo(
      notes: invertedNotes,
      type: type,
      inversion: inversion,
      name: chordName,
      rootNote: rootNote,
    );
  }

  static List<MusicalNote> _applyInversion(
    List<MusicalNote> notes,
    ChordInversion inversion,
  ) {
    switch (inversion) {
      case ChordInversion.root:
        return notes;
      case ChordInversion.first:
        return [notes[1], notes[2], notes[0]];
      case ChordInversion.second:
        return [notes[2], notes[0], notes[1]];
    }
  }

  static String _buildChordName(
    MusicalNote rootNote,
    ChordType type,
    ChordInversion inversion,
  ) {
    final rootName = NoteUtils.noteDisplayName(rootNote, 0).replaceAll("0", "");
    final typeName = _chordTypeNames[type]!;
    final inversionName = _inversionNames[inversion]!;

    if (inversionName.isEmpty) {
      return "$rootName$typeName";
    } else {
      return "$rootName$typeName ($inversionName)";
    }
  }

  /// Returns a list of chord types that naturally occur in the given key and scale.
  ///
  /// This method analyzes the scale degrees and returns the appropriate chord types
  /// (major, minor, diminished) that are built on each scale degree.
  static List<ChordType> getChordsInKey(Key key, ScaleType scaleType) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chords = <ChordType>[];

    for (var i = 0; i < 7; i++) {
      final firstInterval = _getIntervalBetweenNotes(
        scaleNotes[i],
        scaleNotes[(i + 2) % 7],
      );
      final secondInterval = _getIntervalBetweenNotes(
        scaleNotes[(i + 2) % 7],
        scaleNotes[(i + 4) % 7],
      );

      if (firstInterval == 4 && secondInterval == 3) {
        chords.add(ChordType.major);
      } else if (firstInterval == 3 && secondInterval == 4) {
        chords.add(ChordType.minor);
      } else if (firstInterval == 3 && secondInterval == 3) {
        chords.add(ChordType.diminished);
      } else if (firstInterval == 4 && secondInterval == 4) {
        chords.add(ChordType.augmented);
      } else {
        chords.add(ChordType.major);
      }
    }

    return chords;
  }

  /// Returns the interval in semitones between two musical notes.
  ///
  /// The interval is calculated by finding the difference between the notes'
  /// indices and ensuring the result is positive (0-11 semitones).
  static int _getIntervalBetweenNotes(MusicalNote note1, MusicalNote note2) {
    var interval = note2.index - note1.index;
    if (interval < 0) interval += 12;
    return interval;
  }

  /// Generates a complete triad progression for the given key and scale type.
  ///
  /// Returns a list of [ChordInfo] objects representing the triads built on
  /// each degree of the scale, with appropriate chord types and inversions.
  static List<ChordInfo> getKeyTriadProgression(Key key, ScaleType scaleType) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chordTypes = getChordsInKey(key, scaleType);
    final progression = <ChordInfo>[];

    for (var i = 0; i < 7; i++) {
      final rootNote = scaleNotes[i];
      final chordType = chordTypes[i];

      progression
        ..add(getChord(rootNote, chordType, ChordInversion.root))
        ..add(getChord(rootNote, chordType, ChordInversion.first))
        ..add(getChord(rootNote, chordType, ChordInversion.second));
    }

    return progression;
  }

  /// Returns a smoother chord progression sequence for learning inversions.
  /// Sequence: root, 1st inversion, 2nd inversion, 1st inversion, next chord...
  /// This creates a more natural hand movement pattern for students.
  /// Creates a smooth chord progression in the specified key.
  ///
  /// This method generates a chord progression with voice leading
  /// considerations to create smoother transitions between chords.
  static List<ChordInfo> getSmoothKeyTriadProgression(
    Key key,
    ScaleType scaleType,
  ) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chordTypes = getChordsInKey(key, scaleType);
    final progression = <ChordInfo>[];

    for (var i = 0; i < 7; i++) {
      final rootNote = scaleNotes[i];
      final chordType = chordTypes[i];

      // Smooth sequence: root -> 1st -> 2nd -> 1st -> (next chord)
      progression
        ..add(getChord(rootNote, chordType, ChordInversion.root))
        ..add(getChord(rootNote, chordType, ChordInversion.first))
        ..add(getChord(rootNote, chordType, ChordInversion.second))
        ..add(getChord(rootNote, chordType, ChordInversion.first));
    }

    return progression;
  }

  /// Generates a MIDI note sequence from a chord progression in the specified key.
  ///
  /// Returns a flattened list of MIDI note numbers representing all the notes
  /// in the chord progression, starting from the specified octave.
  static List<int> getChordProgressionMidiSequence(
    Key key,
    ScaleType scaleType,
    int startOctave,
  ) {
    final progression = getKeyTriadProgression(key, scaleType);
    final midiSequence = <int>[];

    for (final chord in progression) {
      final chordMidi = chord.getMidiNotes(startOctave);
      midiSequence.addAll(chordMidi);
    }

    return midiSequence;
  }

  /// Returns a MIDI sequence for smooth chord progression with progressive octave management.
  /// This version uses the smooth progression (root->1st->2nd->1st) and allows notes to
  /// progress naturally upward without artificial octave limiting, providing a more
  /// intuitive learning experience on 88-key keyboards.
  /// Generates MIDI note sequences for smooth chord progressions.
  ///
  /// Creates MIDI data for chord progressions with proper voice leading
  /// and octave placement for practice exercises.
  static List<int> getSmoothChordProgressionMidiSequence(
    Key key,
    ScaleType scaleType,
    int startOctave,
  ) {
    final progression = getSmoothKeyTriadProgression(key, scaleType);
    final midiSequence = <int>[];
    var currentOctave = startOctave;
    int? lastHighestNote;

    for (final chord in progression) {
      final chordMidi = chord.getMidiNotes(currentOctave);

      // If this chord's lowest note would be significantly lower than
      // the previous chord's highest note, bump up the octave
      if (lastHighestNote != null && chordMidi.isNotEmpty) {
        final chordLowest = chordMidi.first;
        final chordHighest = chordMidi.last;

        // If there's a big downward jump (more than a perfect 5th),
        // try starting this chord in a higher octave
        if (lastHighestNote - chordLowest > 7) {
          currentOctave++;
          final higherChordMidi = chord.getMidiNotes(currentOctave);

          // Only use the higher octave if it doesn't go too high
          if (higherChordMidi.isNotEmpty && higherChordMidi.last <= 127) {
            midiSequence.addAll(higherChordMidi);
            lastHighestNote = higherChordMidi.last;
          } else {
            // Use original octave if higher would exceed range
            midiSequence.addAll(chordMidi);
            lastHighestNote = chordHighest;
            currentOctave--; // Reset for next iteration
          }
        } else {
          midiSequence.addAll(chordMidi);
          lastHighestNote = chordHighest;
        }
      } else {
        // First chord or no previous reference
        midiSequence.addAll(chordMidi);
        if (chordMidi.isNotEmpty) {
          lastHighestNote = chordMidi.last;
        }
      }
    }

    return midiSequence;
  }
}
