import "package:flutter/foundation.dart" show kDebugMode;
import "package:piano_fitness/shared/constants/musical_constants.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
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

  /// Major seventh chord - bright, jazzy sound (1-3-5-7)
  major7,

  /// Dominant seventh chord - bluesy, tension-seeking sound (1-3-5-♭7)
  dominant7,

  /// Minor seventh chord - smooth, mellow sound (1-♭3-5-♭7)
  minor7,

  /// Half-diminished seventh chord - jazzy, ambiguous sound (1-♭3-♭5-♭7)
  halfDiminished7,

  /// Fully diminished seventh chord - intense, dramatic sound (1-♭3-♭5-♭♭7)
  diminished7,

  /// Minor-major seventh chord - haunting, mysterious sound (1-♭3-5-7)
  minorMajor7,

  /// Augmented seventh chord - exotic, unstable sound (1-3-#5-♭7)
  augmented7,
}

/// Extension methods for ChordType to provide consistent display names.
extension ChordTypeDisplay on ChordType {
  /// Returns the short display name for the chord type (e.g., "Major").
  String get shortName {
    switch (this) {
      case ChordType.major:
        return "Major";
      case ChordType.minor:
        return "Minor";
      case ChordType.diminished:
        return "Diminished";
      case ChordType.augmented:
        return "Augmented";
      case ChordType.major7:
        return "Major 7th";
      case ChordType.dominant7:
        return "Dominant 7th";
      case ChordType.minor7:
        return "Minor 7th";
      case ChordType.halfDiminished7:
        return "Half-Diminished 7th";
      case ChordType.diminished7:
        return "Diminished 7th";
      case ChordType.minorMajor7:
        return "Minor-Major 7th";
      case ChordType.augmented7:
        return "Augmented 7th";
    }
  }

  /// Returns the long display name for the chord type (e.g., "Major Chords").
  String get longName {
    switch (this) {
      case ChordType.major:
        return "Major Chords";
      case ChordType.minor:
        return "Minor Chords";
      case ChordType.diminished:
        return "Diminished Chords";
      case ChordType.augmented:
        return "Augmented Chords";
      case ChordType.major7:
        return "Major 7th Chords";
      case ChordType.dominant7:
        return "Dominant 7th Chords";
      case ChordType.minor7:
        return "Minor 7th Chords";
      case ChordType.halfDiminished7:
        return "Half-Diminished 7th Chords";
      case ChordType.diminished7:
        return "Diminished 7th Chords";
      case ChordType.minorMajor7:
        return "Minor-Major 7th Chords";
      case ChordType.augmented7:
        return "Augmented 7th Chords";
    }
  }
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

  /// Third inversion - seventh in bass (for seventh chords only)
  third,
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
  List<int> getMidiNotesForHand(int octave, HandSelection hand) {
    final allNotes = getMidiNotes(octave);

    switch (hand) {
      case HandSelection.both:
        // Both hands: full chord in each hand, left hand one octave lower
        // For triads (3 notes) and seventh chords (4 notes), each hand plays
        // the complete chord structure for pattern awareness and muscle memory.
        // This matches the scales/arpeggios pattern for pedagogical consistency.
        if (allNotes.isEmpty) return [];

        final result = <int>[];
        // Left hand: all notes one octave lower
        final octaveDown = MusicalConstants.semitonesPerOctave;
        result.addAll(
          allNotes
              .map((note) => note - octaveDown)
              .where((note) => note >= 0) // Guard against negative MIDI notes
              .toList(),
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
        return allNotes
            .map((note) => note - octaveDown)
            .where((note) => note >= 0) // Guard against negative MIDI notes
            .toList();
      case HandSelection.right:
        // Right hand plays full chord at specified octave
        // This matches the scales/arpeggios pattern for pedagogical consistency
        return allNotes;
    }
  }
}

/// Provides static definitions and factory methods for creating chords.
///
/// This class contains the logic for generating chord progressions, determining
/// chord types within keys, and creating smooth voice-led chord sequences
/// for practice exercises.
class ChordDefinitions {
  static const Map<ChordType, List<int>> _chordIntervals = {
    // Triads (3-note chords)
    ChordType.major: [0, 4, 7],
    ChordType.minor: [0, 3, 7],
    ChordType.diminished: [0, 3, 6],
    ChordType.augmented: [0, 4, 8],

    // Seventh chords (4-note chords)
    ChordType.major7: [0, 4, 7, 11], // Major triad + major 7th
    ChordType.dominant7: [0, 4, 7, 10], // Major triad + minor 7th
    ChordType.minor7: [0, 3, 7, 10], // Minor triad + minor 7th
    ChordType.halfDiminished7: [0, 3, 6, 10], // Diminished triad + minor 7th
    ChordType.diminished7: [0, 3, 6, 9], // Diminished triad + diminished 7th
    ChordType.minorMajor7: [0, 3, 7, 11], // Minor triad + major 7th
    ChordType.augmented7: [0, 4, 8, 10], // Augmented triad + minor 7th
  };

  static const Map<ChordType, String> _chordTypeNames = {
    // Triads
    ChordType.major: "",
    ChordType.minor: "m",
    ChordType.diminished: "°",
    ChordType.augmented: "+",

    // Seventh chords (standard jazz notation)
    ChordType.major7: "maj7", // Also written as △7 or M7
    ChordType.dominant7: "7", // Standard dominant seventh
    ChordType.minor7: "m7", // Also written as -7
    ChordType.halfDiminished7: "ø7", // Also written as m7♭5
    ChordType.diminished7: "°7", // Fully diminished seventh
    ChordType.minorMajor7: "m(maj7)", // Also written as -△7
    ChordType.augmented7: "aug7", // Also written as +7
  };

  static const Map<ChordInversion, String> _inversionNames = {
    ChordInversion.root: "",
    ChordInversion.first: "1st inv",
    ChordInversion.second: "2nd inv",
    ChordInversion.third: "3rd inv",
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
    // Inversions reorder chord notes to place different chord tones in the bass.
    // For triads (3 notes): root position, 1st, and 2nd inversions
    // For seventh chords (4 notes): root position, 1st, 2nd, and 3rd inversions
    switch (inversion) {
      case ChordInversion.root:
        return notes;
      case ChordInversion.first:
        // Third in bass: move root to end
        return notes.length == 3
            ? [notes[1], notes[2], notes[0]]
            : [notes[1], notes[2], notes[3], notes[0]];
      case ChordInversion.second:
        // Fifth in bass: move root and third to end
        return notes.length == 3
            ? [notes[2], notes[0], notes[1]]
            : [notes[2], notes[3], notes[0], notes[1]];
      case ChordInversion.third:
        // Seventh in bass: only for seventh chords (4 notes)
        // Move root, third, and fifth to end
        return notes.length == 4
            ? [notes[3], notes[0], notes[1], notes[2]]
            : notes; // Return unchanged for triads (invalid inversion)
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

      if (firstInterval == MusicalConstants.majorThird &&
          secondInterval == MusicalConstants.minorThird) {
        chords.add(ChordType.major);
      } else if (firstInterval == MusicalConstants.minorThird &&
          secondInterval == MusicalConstants.majorThird) {
        chords.add(ChordType.minor);
      } else if (firstInterval == MusicalConstants.minorThird &&
          secondInterval == MusicalConstants.minorThird) {
        chords.add(ChordType.diminished);
      } else if (firstInterval == MusicalConstants.majorThird &&
          secondInterval == MusicalConstants.majorThird) {
        chords.add(ChordType.augmented);
      } else {
        chords.add(ChordType.major);
      }
    }

    return chords;
  }

  /// Returns a list of seventh chord types that naturally occur in the given key and scale.
  ///
  /// This method analyzes the scale degrees and returns the appropriate seventh chord types
  /// built on each scale degree. For major scales:
  /// - I: major7 (Imaj7)
  /// - ii: minor7 (ii7)
  /// - iii: minor7 (iii7)
  /// - IV: major7 (IVmaj7)
  /// - V: dominant7 (V7)
  /// - vi: minor7 (vi7)
  /// - vii: half-diminished7 (viiø7)
  ///
  /// For other scales, the seventh chord quality is determined by analyzing
  /// the intervals between the 1st, 3rd, 5th, and 7th scale degrees.
  static List<ChordType> getSeventhChordsInKey(Key key, ScaleType scaleType) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chords = <ChordType>[];

    for (var i = 0; i < 7; i++) {
      // Calculate intervals for seventh chords (root-3rd, 3rd-5th, 5th-7th)
      final firstInterval = _getIntervalBetweenNotes(
        scaleNotes[i],
        scaleNotes[(i + 2) % 7],
      );
      final secondInterval = _getIntervalBetweenNotes(
        scaleNotes[(i + 2) % 7],
        scaleNotes[(i + 4) % 7],
      );
      final thirdInterval = _getIntervalBetweenNotes(
        scaleNotes[(i + 4) % 7],
        scaleNotes[(i + 6) % 7],
      );

      // Determine seventh chord type based on triad quality and seventh interval
      // Major triad (M3 + m3)
      if (firstInterval == MusicalConstants.majorThird &&
          secondInterval == MusicalConstants.minorThird) {
        if (thirdInterval == MusicalConstants.majorThird) {
          chords.add(ChordType.major7); // Major triad + major 7th
        } else {
          chords.add(ChordType.dominant7); // Major triad + minor 7th
        }
      }
      // Minor triad (m3 + M3)
      else if (firstInterval == MusicalConstants.minorThird &&
          secondInterval == MusicalConstants.majorThird) {
        if (thirdInterval == MusicalConstants.majorThird) {
          chords.add(ChordType.minorMajor7); // Minor triad + major 7th
        } else {
          chords.add(ChordType.minor7); // Minor triad + minor 7th
        }
      }
      // Diminished triad (m3 + m3)
      else if (firstInterval == MusicalConstants.minorThird &&
          secondInterval == MusicalConstants.minorThird) {
        if (thirdInterval == MusicalConstants.majorThird) {
          chords.add(ChordType.halfDiminished7); // Diminished triad + minor 7th
        } else {
          chords.add(
            ChordType.diminished7,
          ); // Diminished triad + diminished 7th
        }
      }
      // Augmented triad (M3 + M3)
      else if (firstInterval == MusicalConstants.majorThird &&
          secondInterval == MusicalConstants.majorThird) {
        chords.add(ChordType.augmented7); // Augmented triad + minor 7th
      }
      // Default to dominant7 for unexpected interval combinations
      else {
        if (kDebugMode) {
          print(
            "Unexpected interval combination in getSeventhChordsInKey: "
            "scale degree=$i, root=${scaleNotes[i].name}, "
            "firstInterval=$firstInterval, secondInterval=$secondInterval, "
            "thirdInterval=$thirdInterval",
          );
        }
        chords.add(ChordType.dominant7);
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

  /// Creates a smooth seventh chord progression in the specified key.
  ///
  /// This method generates a seventh chord progression sequence for foundational learning.
  /// The progression uses simple pattern sequences without voice leading optimization,
  /// focusing on pattern awareness and muscle memory development.
  ///
  /// Sequence pattern for each chord: root -> 1st -> 2nd -> 3rd -> 2nd -> 1st -> (next chord)
  /// This creates a natural hand movement pattern that helps students learn seventh chord
  /// inversions systematically while building muscle memory.
  static List<ChordInfo> getSmoothKeySeventhChordProgression(
    Key key,
    ScaleType scaleType,
  ) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chordTypes = getSeventhChordsInKey(key, scaleType);
    final progression = <ChordInfo>[];

    for (var i = 0; i < 7; i++) {
      final rootNote = scaleNotes[i];
      final chordType = chordTypes[i];

      // Smooth sequence through all inversions for seventh chords
      // root -> 1st -> 2nd -> 3rd -> 2nd -> 1st (creates arc pattern)
      progression
        ..add(getChord(rootNote, chordType, ChordInversion.root))
        ..add(getChord(rootNote, chordType, ChordInversion.first))
        ..add(getChord(rootNote, chordType, ChordInversion.second))
        ..add(getChord(rootNote, chordType, ChordInversion.third))
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

/// Represents a chord planing practice exercise focusing on a specific chord type.
///
/// Chord planing involves practicing the same chord type (major, minor, diminished,
/// augmented) across all 12 chromatic root notes in sequence. This technique helps
/// students develop consistent chord recognition and fingering patterns while
/// understanding how chord qualities sound in different harmonic contexts.
class ChordByType {
  /// Creates a new ChordByType practice exercise.
  const ChordByType({
    required this.type,
    required this.rootNotes,
    required this.includeInversions,
    required this.name,
  });

  /// The chord type to practice (major, minor, diminished, augmented).
  final ChordType type;

  /// List of root notes to practice this chord type on.
  final List<MusicalNote> rootNotes;

  /// Whether to include chord inversions in the practice sequence.
  final bool includeInversions;

  /// The human-readable name of this practice exercise.
  final String name;

  /// Generates the complete practice sequence for this chord type.
  ///
  /// Returns a list of [ChordInfo] objects representing all chords
  /// in the practice sequence, optionally including inversions.
  /// Seventh chords include third inversion when inversions are enabled.
  List<ChordInfo> generateChordSequence() {
    final chords = <ChordInfo>[];
    final isSeventhChord = _isSeventhChordType(type);

    for (final rootNote in rootNotes) {
      // Add root position
      chords.add(
        ChordDefinitions.getChord(rootNote, type, ChordInversion.root),
      );

      if (includeInversions) {
        // Add inversions
        chords.add(
          ChordDefinitions.getChord(rootNote, type, ChordInversion.first),
        );
        chords.add(
          ChordDefinitions.getChord(rootNote, type, ChordInversion.second),
        );

        // Add third inversion for seventh chords
        if (isSeventhChord) {
          chords.add(
            ChordDefinitions.getChord(rootNote, type, ChordInversion.third),
          );
        }
      }
    }

    return chords;
  }

  /// Helper to determine if a chord type is a seventh chord
  bool _isSeventhChordType(ChordType type) {
    return type == ChordType.major7 ||
        type == ChordType.dominant7 ||
        type == ChordType.minor7 ||
        type == ChordType.halfDiminished7 ||
        type == ChordType.diminished7 ||
        type == ChordType.minorMajor7 ||
        type == ChordType.augmented7;
  }

  /// Returns the complete MIDI note sequence for this chord type practice.
  ///
  /// Generates MIDI note numbers for all chords in the sequence,
  /// starting from the specified octave.
  List<int> getMidiSequence(int startOctave) {
    final chords = generateChordSequence();
    final midiSequence = <int>[];

    for (final chord in chords) {
      midiSequence.addAll(chord.getMidiNotes(startOctave));
    }

    return midiSequence;
  }

  /// Convenience: builds MIDI from a provided chord sequence to avoid recomputation.
  List<int> getMidiSequenceFrom(List<ChordInfo> chords, int startOctave) {
    final midiSequence = <int>[];
    for (final chord in chords) {
      midiSequence.addAll(chord.getMidiNotes(startOctave));
    }
    return midiSequence;
  }
}

/// Provides static definitions and factory methods for creating chord planing exercises.
///
/// This class focuses on chord planing - practicing specific chord types across all
/// 12 chromatic root notes. This complements key-based chord practice by emphasizing
/// intervallic patterns, chord quality recognition, and consistent fingering across keys.
class ChordByTypeDefinitions {
  /// All 12 chromatic root notes for chord planing practice.
  static const List<MusicalNote> _chromaticRootNotes = [
    MusicalNote.c,
    MusicalNote.cSharp,
    MusicalNote.d,
    MusicalNote.dSharp,
    MusicalNote.e,
    MusicalNote.f,
    MusicalNote.fSharp,
    MusicalNote.g,
    MusicalNote.gSharp,
    MusicalNote.a,
    MusicalNote.aSharp,
    MusicalNote.b,
  ];

  /// Creates a chord planing exercise for the specified chord type.
  ///
  /// Chord planing involves practicing the same chord type across all 12 chromatic
  /// root notes in sequence, which helps students learn to recognize and play
  /// chord qualities consistently across different keys.
  ///
  /// [type] - The chord type to practice across all keys
  /// [includeInversions] - Whether to include chord inversions
  static ChordByType getChordTypeExercise(
    ChordType type, {
    bool includeInversions = true,
  }) {
    final typeName = type.longName;
    final inversionSuffix = includeInversions ? " (with inversions)" : "";

    return ChordByType(
      type: type,
      rootNotes:
          _chromaticRootNotes, // Always use all 12 keys for chord planing
      includeInversions: includeInversions,
      name: "$typeName$inversionSuffix - All 12 Keys",
    );
  }

  /// Returns a practice exercise for major chords.
  static ChordByType getMajorChordExercise({bool includeInversions = true}) {
    return getChordTypeExercise(
      ChordType.major,
      includeInversions: includeInversions,
    );
  }

  /// Returns a practice exercise for minor chords.
  static ChordByType getMinorChordExercise({bool includeInversions = true}) {
    return getChordTypeExercise(
      ChordType.minor,
      includeInversions: includeInversions,
    );
  }

  /// Returns a practice exercise for diminished chords.
  static ChordByType getDiminishedChordExercise({
    bool includeInversions = true,
  }) {
    return getChordTypeExercise(
      ChordType.diminished,
      includeInversions: includeInversions,
    );
  }

  /// Returns a practice exercise for augmented chords.
  static ChordByType getAugmentedChordExercise({
    bool includeInversions = true,
  }) {
    return getChordTypeExercise(
      ChordType.augmented,
      includeInversions: includeInversions,
    );
  }

  /// Returns all basic chord type exercises (major, minor, diminished, augmented).
  static List<ChordByType> getAllBasicChordTypeExercises({
    bool includeInversions = true,
  }) {
    return [
      getMajorChordExercise(includeInversions: includeInversions),
      getMinorChordExercise(includeInversions: includeInversions),
      getDiminishedChordExercise(includeInversions: includeInversions),
      getAugmentedChordExercise(includeInversions: includeInversions),
    ];
  }

  /// Returns the display name for a chord type.
  static String getChordTypeDisplayName(ChordType type) {
    return type.longName;
  }
}
