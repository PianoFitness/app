import "package:piano_fitness/domain/services/music_theory/chord_builder.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

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

    for (final rootNote in rootNotes) {
      // Add root position
      chords.add(ChordBuilder.getChord(rootNote, type, ChordInversion.root));

      if (includeInversions) {
        // Add inversions
        chords.add(ChordBuilder.getChord(rootNote, type, ChordInversion.first));
        chords.add(
          ChordBuilder.getChord(rootNote, type, ChordInversion.second),
        );

        // Add third inversion for seventh chords
        if (type.isSeventhChord) {
          chords.add(
            ChordBuilder.getChord(rootNote, type, ChordInversion.third),
          );
        }
      }
    }

    return chords;
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
