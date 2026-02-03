import "package:flutter/foundation.dart" show kDebugMode;
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart";

/// Provides static definitions and factory methods for creating chords.
///
/// This class contains the logic for generating chord progressions, determining
/// chord types within keys, and creating smooth voice-led chord sequences
/// for practice exercises.
class ChordBuilder {
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
        if (notes.length == 4) {
          return [notes[3], notes[0], notes[1], notes[2]];
        } else {
          if (kDebugMode) {
            print(
              "Warning: Third inversion requested for triad (${notes.length} notes)",
            );
          }
          return notes; // Return unchanged for triads (invalid inversion)
        }
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
