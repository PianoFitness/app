import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// The different types of arpeggio chord qualities supported by Piano Fitness.
///
/// Each type represents a different chord structure that creates unique
/// harmonic sounds when played as broken chords (arpeggios).
enum ArpeggioType {
  /// Major arpeggio (1-3-5-8) - bright, happy sound
  major,

  /// Minor arpeggio (1-♭3-5-8) - darker, more melancholic sound
  minor,

  /// Diminished arpeggio (1-♭3-♭5-8) - tense, unstable sound
  diminished,

  /// Augmented arpeggio (1-3-#5-8) - mysterious, dreamy sound
  augmented,

  /// Dominant 7th arpeggio (1-3-5-♭7-8) - jazzy, bluesy sound
  dominant7,

  /// Minor 7th arpeggio (1-♭3-5-♭7-8) - smooth, jazzy minor sound
  minor7,

  /// Major 7th arpeggio (1-3-5-7-8) - sophisticated, jazzy major sound
  major7,
}

/// The octave range options for arpeggio exercises.
///
/// Determines how many octaves the arpeggio pattern spans,
/// affecting both difficulty and musical range.
enum ArpeggioOctaves {
  /// Single octave arpeggio - easier, more focused
  one,

  /// Two octave arpeggio - more challenging, greater range
  two,
}

/// Represents an arpeggio (broken chord) pattern for piano practice.
///
/// An arpeggio is a sequence of notes from a chord played one after another
/// rather than simultaneously. This class defines the pattern and provides
/// methods to generate practice sequences.
class Arpeggio {
  /// Creates a new Arpeggio with the specified parameters.
  ///
  /// The [intervals] list defines the semitone distances from the root note
  /// to each chord tone in the arpeggio pattern.
  const Arpeggio({
    required this.rootNote,
    required this.type,
    required this.octaves,
    required this.intervals,
    required this.name,
  });

  /// The root note of the arpeggio (starting pitch).
  final MusicalNote rootNote;

  /// The chord quality/type of the arpeggio.
  final ArpeggioType type;

  /// The octave range the arpeggio spans.
  final ArpeggioOctaves octaves;

  /// The interval pattern as semitone distances from the root.
  final List<int> intervals;

  /// The human-readable name of the arpeggio (e.g., "C Major (1 Octave)").
  final String name;

  /// Returns the sequence of musical notes in this arpeggio.
  ///
  /// Generates the arpeggio by applying the interval pattern starting from
  /// the root note. Returns a list of [MusicalNote] enum values.
  List<MusicalNote> getNotes() {
    final notes = <MusicalNote>[];

    for (final interval in intervals) {
      final noteIndex = (rootNote.index + interval) % 12;
      notes.add(MusicalNote.values[noteIndex]);
    }

    return notes;
  }

  /// Returns the MIDI note numbers for this arpeggio starting at the specified octave.
  ///
  /// The [startOctave] parameter determines which octave to start the arpeggio in.
  /// Returns a list of MIDI note numbers (0-127) representing the chord tones.
  List<int> getMidiNotes(int startOctave) {
    final arpeggioNotes = getNotes();
    final midiNotes = <int>[];

    var currentOctave = startOctave;
    MusicalNote? previousNote;

    for (final note in arpeggioNotes) {
      if (previousNote != null && note.index < previousNote.index) {
        currentOctave++;
      }

      midiNotes.add(NoteUtils.noteToMidiNumber(note, currentOctave));
      previousNote = note;
    }

    return midiNotes;
  }

  /// Returns a complete arpeggio practice sequence going up and back down.
  ///
  /// Creates a practice sequence that ascends the arpeggio pattern and then
  /// descends, spanning the specified number of octaves. The [startOctave]
  /// determines the starting octave for the sequence.
  List<int> getFullArpeggioSequence(int startOctave) {
    final baseNotes = getMidiNotes(startOctave);

    if (octaves == ArpeggioOctaves.one) {
      // One octave: up and down
      final descendingNotes = baseNotes.reversed.skip(1).toList();
      return [...baseNotes, ...descendingNotes];
    } else {
      // Two octaves: up two octaves, then down
      final secondOctaveNotes = <int>[];

      // Add the second octave (skip the first note to avoid duplication)
      // Each note should be in the next octave relative to its position in the first octave
      for (var i = 1; i < baseNotes.length; i++) {
        final originalMidi = baseNotes[i];
        // Add 12 semitones to get the same note one octave higher
        secondOctaveNotes.add(originalMidi + 12);
      }

      final allAscendingNotes = [...baseNotes, ...secondOctaveNotes];
      final descendingNotes = allAscendingNotes.reversed.skip(1).toList();
      return [...allAscendingNotes, ...descendingNotes];
    }
  }

  /// Returns an arpeggio sequence adapted for the specified hand selection.
  ///
  /// This method generates hand-specific practice sequences:
  /// - [HandSelection.both]: Returns notes with both hands paired (encoded as pairs)
  /// - [HandSelection.right]: Right hand plays in the original octave
  /// - [HandSelection.left]: Left hand plays one octave lower
  ///
  /// For both hands mode, each "step" in the sequence contains two MIDI notes
  /// that should be played simultaneously (one in each hand). These are returned
  /// as alternating values in the list: [left1, right1, left2, right2, ...].
  /// The caller must process pairs of notes for simultaneous playback.
  ///
  /// **Precondition**: [startOctave] must be at least 1 when using [HandSelection.left]
  /// or [HandSelection.both] to ensure the left hand (startOctave - 1) stays in
  /// a musically practical range.
  List<int> getHandSequence(int startOctave, HandSelection hand) {
    switch (hand) {
      case HandSelection.both:
        if (startOctave < 1) {
          throw ArgumentError(
            "startOctave must be >= 1 for both hands (left hand plays at startOctave - 1), got: $startOctave",
          );
        }
        // Both hands play in parallel: left hand one octave lower, right hand at startOctave
        final rightHand = getFullArpeggioSequence(startOctave);
        final leftHand = getFullArpeggioSequence(startOctave - 1);
        // Interleave: [L1, R1, L2, R2, ...] to encode pairs
        final paired = <int>[];
        for (var i = 0; i < rightHand.length; i++) {
          paired.add(leftHand[i]);
          paired.add(rightHand[i]);
        }
        return paired;
      case HandSelection.right:
        // Right hand uses the original octave
        return getFullArpeggioSequence(startOctave);
      case HandSelection.left:
        if (startOctave < 1) {
          throw ArgumentError(
            "startOctave must be >= 1 for left hand (plays at startOctave - 1), got: $startOctave",
          );
        }
        // Left hand plays one octave lower
        return getFullArpeggioSequence(startOctave - 1);
    }
  }
}

/// Provides static definitions and factory methods for creating arpeggios.
///
/// This class contains the interval patterns for all supported arpeggio types
/// and provides methods to create Arpeggio objects with proper configurations.
class ArpeggioDefinitions {
  /// Maps arpeggio types to their interval patterns in semitones from the root.
  ///
  /// Each list represents the semitone distances from the root note to each
  /// chord tone. For example, major arpeggio: [0, 4, 7, 12] (root, 3rd, 5th, octave).
  static const Map<ArpeggioType, List<int>> _arpeggioIntervals = {
    ArpeggioType.major: [0, 4, 7, 12],
    ArpeggioType.minor: [0, 3, 7, 12],
    ArpeggioType.diminished: [0, 3, 6, 12],
    ArpeggioType.augmented: [0, 4, 8, 12],
    ArpeggioType.dominant7: [0, 4, 7, 10, 12],
    ArpeggioType.minor7: [0, 3, 7, 10, 12],
    ArpeggioType.major7: [0, 4, 7, 11, 12],
  };

  static const Map<ArpeggioType, String> _arpeggioTypeNames = {
    ArpeggioType.major: "Major",
    ArpeggioType.minor: "Minor",
    ArpeggioType.diminished: "Diminished",
    ArpeggioType.augmented: "Augmented",
    ArpeggioType.dominant7: "Dominant 7th",
    ArpeggioType.minor7: "Minor 7th",
    ArpeggioType.major7: "Major 7th",
  };

  /// Creates an Arpeggio object for the specified root note, type, and octave range.
  ///
  /// This is the main factory method for creating arpeggios. It looks up the
  /// appropriate interval pattern and generates a proper arpeggio name.
  static Arpeggio getArpeggio(
    MusicalNote rootNote,
    ArpeggioType type,
    ArpeggioOctaves octaves,
  ) {
    final intervals = _arpeggioIntervals[type]!;
    final typeName = _arpeggioTypeNames[type]!;
    final rootName = NoteUtils.noteDisplayName(rootNote, 0).replaceAll("0", "");
    final octaveName = octaves == ArpeggioOctaves.one
        ? "1 Octave"
        : "2 Octaves";

    return Arpeggio(
      rootNote: rootNote,
      type: type,
      octaves: octaves,
      intervals: intervals,
      name: "$rootName $typeName ($octaveName)",
    );
  }

  /// Returns a list of common arpeggio types for the specified root note.
  ///
  /// Includes major, minor, diminished, and augmented arpeggios - the most
  /// fundamental arpeggio types that form the basis of piano technique.
  static List<Arpeggio> getCommonArpeggios(
    MusicalNote rootNote,
    ArpeggioOctaves octaves,
  ) {
    return [
      getArpeggio(rootNote, ArpeggioType.major, octaves),
      getArpeggio(rootNote, ArpeggioType.minor, octaves),
      getArpeggio(rootNote, ArpeggioType.diminished, octaves),
      getArpeggio(rootNote, ArpeggioType.augmented, octaves),
    ];
  }

  /// Returns an extended list of arpeggios including 7th chord types.
  ///
  /// Includes all common arpeggios plus dominant 7th, minor 7th, and major 7th
  /// arpeggios for more advanced harmonic study and jazz applications.
  static List<Arpeggio> getExtendedArpeggios(
    MusicalNote rootNote,
    ArpeggioOctaves octaves,
  ) {
    return [
      ...getCommonArpeggios(rootNote, octaves),
      getArpeggio(rootNote, ArpeggioType.dominant7, octaves),
      getArpeggio(rootNote, ArpeggioType.minor7, octaves),
      getArpeggio(rootNote, ArpeggioType.major7, octaves),
    ];
  }

  /// Convenience method that returns C major arpeggios in both octave ranges.
  ///
  /// This is commonly used as a starting point for arpeggio practice and
  /// provides a simple reference implementation.
  static List<Arpeggio> getCMajorArpeggios() {
    return [
      getArpeggio(MusicalNote.c, ArpeggioType.major, ArpeggioOctaves.one),
      getArpeggio(MusicalNote.c, ArpeggioType.major, ArpeggioOctaves.two),
    ];
  }
}
