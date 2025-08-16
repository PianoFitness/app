import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

/// Difficulty levels for chord progressions based on complexity and voice leading.
enum ProgressionDifficulty {
  /// Simple two-chord progressions with basic voice leading
  beginner,

  /// Common four-chord progressions with standard voice leading
  intermediate,

  /// Complex progressions with sophisticated voice leading
  advanced,
}

/// Extension to provide display names for progression difficulty levels.
extension ProgressionDifficultyExtension on ProgressionDifficulty {
  String get displayName {
    switch (this) {
      case ProgressionDifficulty.beginner:
        return "Beginner";
      case ProgressionDifficulty.intermediate:
        return "Intermediate";
      case ProgressionDifficulty.advanced:
        return "Advanced";
    }
  }
}

/// Represents a chord progression with roman numeral notation and interval-based chord definitions.
///
/// Each progression contains the chord intervals from the root note, allowing for
/// both diatonic and chromatic progressions. This approach supports advanced
/// progressions like diminished chords, flat seven chords, and chord planing exercises.
class ChordProgression {
  /// Creates a chord progression with all required information.
  const ChordProgression({
    required this.name,
    required this.romanNumerals,
    required this.chords,
    required this.difficulty,
    this.description,
  });

  /// The roman numeral name of the progression (e.g., "I - V", "I - ♭VII").
  final String name;

  /// List of roman numerals for display (e.g., ["I", "V"], ["I", "♭VII"]).
  final List<String> romanNumerals;

  /// List of chord definitions, where each chord is defined as a list of intervals
  /// from the root note in semitones. For example:
  /// - Major triad: [0, 4, 7] (root, major third, perfect fifth)
  /// - Minor triad: [0, 3, 7] (root, minor third, perfect fifth)
  /// - Diminished triad: [0, 3, 6] (root, minor third, diminished fifth)
  /// - ♭VII major: [10, 14, 17] (♭7, ♭7+M3, ♭7+P5)
  final List<List<int>> chords;

  /// The difficulty level of this progression.
  final ProgressionDifficulty difficulty;

  /// Optional educational description explaining harmonic concepts.
  final String? description;

  /// Generates the actual ChordInfo objects for this progression in the given key.
  ///
  /// This method creates the chord progression by calculating each chord's notes
  /// based on the interval definitions and the root key.
  List<ChordInfo> generateChords(music.Key key) {
    final rootMidiNote = NoteUtils.keyToMidiNumber(key);
    final chordInfos = <ChordInfo>[];

    for (int i = 0; i < chords.length; i++) {
      final chordIntervals = chords[i];
      final romanNumeral = i < romanNumerals.length ? romanNumerals[i] : "?";

      // Create a custom ChordInfo from intervals
      final chordInfo = _createChordFromIntervals(
        rootMidiNote,
        chordIntervals,
        romanNumeral,
      );

      chordInfos.add(chordInfo);
    }

    return chordInfos;
  }

  /// Creates a ChordInfo object from interval definitions.
  ChordInfo _createChordFromIntervals(
    int rootMidiNote,
    List<int> intervals,
    String name,
  ) {
    final midiNotes = intervals
        .map((interval) => rootMidiNote + interval)
        .toList();

    return IntervalBasedChordInfo(name: name, midiNotes: midiNotes);
  }

  /// Returns a display-friendly string representation.
  String get displayName => name;
}

/// A custom ChordInfo implementation for interval-based chords.
///
/// This allows us to create chords from arbitrary intervals rather than
/// being limited to the predefined chord types in the existing ChordDefinitions.
class IntervalBasedChordInfo implements ChordInfo {
  const IntervalBasedChordInfo({required this.name, required this.midiNotes});

  @override
  final String name;

  final List<int> midiNotes;

  @override
  List<int> getMidiNotes(int octave) {
    // Adjust the pre-calculated MIDI notes to the desired octave
    final octaveOffset = (octave - 4) * 12; // Our base is octave 4
    return midiNotes.map((note) => note + octaveOffset).toList();
  }

  // Provide implementations for the required ChordInfo properties
  @override
  List<MusicalNote> get notes {
    // Convert MIDI notes back to MusicalNote objects
    // This is a simplified implementation
    return midiNotes.map((midiNote) {
      final noteInfo = NoteUtils.midiNumberToNote(midiNote);
      return noteInfo.note;
    }).toList();
  }

  @override
  MusicalNote get rootNote {
    // Return the first note as the root note
    if (midiNotes.isNotEmpty) {
      final noteInfo = NoteUtils.midiNumberToNote(midiNotes.first);
      return noteInfo.note;
    }
    return MusicalNote.c; // Default fallback
  }

  @override
  ChordType get type => ChordType.major; // Simplified - could be enhanced to detect type

  @override
  ChordInversion get inversion => ChordInversion.root; // Simplified for now
}

/// Library of predefined chord progressions.
class ChordProgressionLibrary {
  /// All available chord progressions in a flat list.
  static const List<ChordProgression> progressions = [
    // Beginner progressions
    ChordProgression(
      name: "I - V",
      romanNumerals: ["I", "V"],
      chords: [
        [0, 4, 7], // I: Major triad (root, major third, perfect fifth)
        [7, 11, 14], // V: Major triad on the fifth (7 semitones up)
      ],
      difficulty: ProgressionDifficulty.beginner,
      description:
          "Basic cadential progression moving from tonic (home) to dominant (tension). "
          "This fundamental progression forms the backbone of Western harmony.",
    ),
    ChordProgression(
      name: "I - vi",
      romanNumerals: ["I", "vi"],
      chords: [
        [0, 4, 7], // I: Major triad
        [9, 12, 16], // vi: Minor triad on the sixth (9 semitones = minor sixth)
      ],
      difficulty: ProgressionDifficulty.beginner,
      description:
          "Tonic to relative minor progression. Creates a gentle, melancholic movement "
          "while maintaining harmonic stability.",
    ),
    ChordProgression(
      name: "vi - IV",
      romanNumerals: ["vi", "IV"],
      chords: [
        [9, 12, 16], // vi: Minor triad on the sixth
        [5, 9, 12], // IV: Major triad on the fourth (5 semitones)
      ],
      difficulty: ProgressionDifficulty.beginner,
      description:
          "Minor to major progression that creates a sense of uplift and resolution. "
          "Common in popular music for emotional contrast.",
    ),

    // Intermediate progressions
    ChordProgression(
      name: "I - V - vi - IV",
      romanNumerals: ["I", "V", "vi", "IV"],
      chords: [
        [0, 4, 7], // I: Major triad
        [7, 11, 14], // V: Major triad on the fifth
        [9, 12, 16], // vi: Minor triad on the sixth
        [5, 9, 12], // IV: Major triad on the fourth
      ],
      difficulty: ProgressionDifficulty.intermediate,
      description:
          "The classic pop progression. Moves from tonic through dominant to relative minor, "
          "then to subdominant, creating a complete harmonic journey with strong voice leading.",
    ),
    ChordProgression(
      name: "vi - IV - I - V",
      romanNumerals: ["vi", "IV", "I", "V"],
      chords: [
        [9, 12, 16], // vi: Minor triad on the sixth
        [5, 9, 12], // IV: Major triad on the fourth
        [0, 4, 7], // I: Major triad
        [7, 11, 14], // V: Major triad on the fifth
      ],
      difficulty: ProgressionDifficulty.intermediate,
      description:
          "Alternative ordering of the classic progression, starting with minor and building "
          "to a strong dominant-tonic resolution.",
    ),
    ChordProgression(
      name: "I - vi - IV - V",
      romanNumerals: ["I", "vi", "IV", "V"],
      chords: [
        [0, 4, 7], // I: Major triad
        [9, 12, 16], // vi: Minor triad on the sixth
        [5, 9, 12], // IV: Major triad on the fourth
        [7, 11, 14], // V: Major triad on the fifth
      ],
      difficulty: ProgressionDifficulty.intermediate,
      description:
          "Circle progression with smooth voice leading. Each chord connects naturally to the next, "
          "ending with the classic dominant-tonic resolution.",
    ),

    // Advanced progressions
    ChordProgression(
      name: "ii - V - I",
      romanNumerals: ["ii", "V", "I"],
      chords: [
        [2, 5, 9], // ii: Minor triad on the second (2 semitones)
        [7, 11, 14], // V: Major triad on the fifth
        [0, 4, 7], // I: Major triad
      ],
      difficulty: ProgressionDifficulty.advanced,
      description:
          "The fundamental jazz progression. Uses subdominant minor function (ii) leading "
          "through dominant to tonic, creating sophisticated harmonic motion.",
    ),
    ChordProgression(
      name: "I - ♭VII - IV",
      romanNumerals: ["I", "♭VII", "IV"],
      chords: [
        [0, 4, 7], // I: Major triad
        [10, 14, 17], // ♭VII: Major triad on the flat seventh (10 semitones)
        [5, 9, 12], // IV: Major triad on the fourth
      ],
      difficulty: ProgressionDifficulty.advanced,
      description:
          "Rock progression featuring the borrowed flat seven chord. "
          "Creates a strong descending motion and modal sound.",
    ),
  ];

  /// Returns all progressions for a specific difficulty level.
  static List<ChordProgression> getProgressionsForDifficulty(
    ProgressionDifficulty difficulty,
  ) {
    return progressions
        .where((progression) => progression.difficulty == difficulty)
        .toList();
  }

  /// Returns all available progressions as a flat list.
  static List<ChordProgression> getAllProgressions() {
    return progressions;
  }

  /// Returns a progression by its roman numeral name.
  static ChordProgression? getProgressionByName(String name) {
    return progressions
        .where((progression) => progression.name == name)
        .firstOrNull;
  }
}
