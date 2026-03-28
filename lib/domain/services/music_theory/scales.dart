import "package:piano_fitness/domain/models/music/scale_types.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

export "package:piano_fitness/domain/models/music/scale_types.dart";

/// Represents a musical scale with its key, type, intervals, and name.
///
/// A scale defines a sequence of musical notes based on a specific pattern
/// of intervals. This class provides methods to generate note sequences
/// and MIDI data for practice exercises.
class Scale {
  /// Creates a new Scale with the specified properties.
  ///
  /// The [intervals] list defines the semitone steps between consecutive
  /// notes in the scale pattern.
  const Scale({
    required this.key,
    required this.type,
    required this.intervals,
    required this.name,
  });

  /// The root key of the scale.
  final Key key;

  /// The type/mode of the scale (major, minor, etc.).
  final ScaleType type;

  /// The interval pattern as semitone steps between consecutive notes.
  final List<int> intervals;

  /// The human-readable name of the scale (e.g., "C Major").
  final String name;

  /// Returns the sequence of musical notes in this scale.
  ///
  /// Generates the scale by applying the interval pattern starting from
  /// the root key. Returns a list of [MusicalNote] enum values.
  List<MusicalNote> getNotes() {
    final startingNote = _keyToMusicalNote(key);
    final notes = <MusicalNote>[];

    var currentNote = startingNote.index;
    notes.add(startingNote);

    for (final interval in intervals) {
      currentNote = (currentNote + interval) % 12;
      notes.add(MusicalNote.values[currentNote]);
    }

    return notes;
  }

  /// Returns the MIDI note numbers for this scale starting at the specified octave.
  ///
  /// The [startOctave] parameter determines which octave to start the scale in.
  /// Returns a list of MIDI note numbers (0-127) representing the scale.
  List<int> getMidiNotes(int startOctave) {
    final scaleNotes = getNotes();
    final midiNotes = <int>[];

    var currentOctave = startOctave;
    MusicalNote? previousNote;

    for (final note in scaleNotes) {
      if (previousNote != null && note.index < previousNote.index) {
        currentOctave++;
      }

      midiNotes.add(NoteUtils.noteToMidiNumber(note, currentOctave));
      previousNote = note;
    }

    return midiNotes;
  }

  /// Returns a complete scale sequence going up and back down.
  ///
  /// This creates a practice sequence that ascends the scale and then
  /// descends, providing a complete exercise. The [startOctave] determines
  /// the starting octave for the sequence.
  List<int> getFullScaleSequence(int startOctave) {
    final ascendingNotes = getMidiNotes(startOctave);
    final descendingNotes = ascendingNotes.reversed.skip(1).toList();
    return [...ascendingNotes, ...descendingNotes];
  }

  /// Returns a scale sequence adapted for the specified hand selection.
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
        final rightHand = getFullScaleSequence(startOctave);
        final leftHand = getFullScaleSequence(startOctave - 1);
        // Interleave: [L1, R1, L2, R2, ...] to encode pairs
        final paired = <int>[];
        for (var i = 0; i < rightHand.length; i++) {
          paired.add(leftHand[i]);
          paired.add(rightHand[i]);
        }
        return paired;
      case HandSelection.right:
        // Right hand uses the original octave
        return getFullScaleSequence(startOctave);
      case HandSelection.left:
        if (startOctave < 1) {
          throw ArgumentError(
            "startOctave must be >= 1 for left hand (plays at startOctave - 1), got: $startOctave",
          );
        }
        // Left hand plays one octave lower
        return getFullScaleSequence(startOctave - 1);
    }
  }

  static MusicalNote _keyToMusicalNote(Key key) {
    switch (key) {
      case Key.c:
        return MusicalNote.c;
      case Key.cSharp:
        return MusicalNote.cSharp;
      case Key.d:
        return MusicalNote.d;
      case Key.dSharp:
        return MusicalNote.dSharp;
      case Key.e:
        return MusicalNote.e;
      case Key.f:
        return MusicalNote.f;
      case Key.fSharp:
        return MusicalNote.fSharp;
      case Key.g:
        return MusicalNote.g;
      case Key.gSharp:
        return MusicalNote.gSharp;
      case Key.a:
        return MusicalNote.a;
      case Key.aSharp:
        return MusicalNote.aSharp;
      case Key.b:
        return MusicalNote.b;
    }
  }
}

/// Provides static definitions and factory methods for creating scales.
///
/// This class contains the interval patterns for all supported scale types
/// and provides methods to create Scale objects with proper configurations.
class ScaleDefinitions {
  /// Maps scale types to their interval patterns in semitones.
  ///
  /// Each list represents the semitone steps between consecutive notes
  /// in the scale. For example, major scale: [2, 2, 1, 2, 2, 2, 1].
  static const Map<ScaleType, List<int>> _scaleIntervals = {
    ScaleType.major: [2, 2, 1, 2, 2, 2, 1],
    ScaleType.minor: [2, 1, 2, 2, 1, 2, 2],
    ScaleType.dorian: [2, 1, 2, 2, 2, 1, 2],
    ScaleType.phrygian: [1, 2, 2, 2, 1, 2, 2],
    ScaleType.lydian: [2, 2, 2, 1, 2, 2, 1],
    ScaleType.mixolydian: [2, 2, 1, 2, 2, 1, 2],
    ScaleType.aeolian: [2, 1, 2, 2, 1, 2, 2],
    ScaleType.locrian: [1, 2, 2, 1, 2, 2, 2],
  };

  static const Map<ScaleType, String> _scaleNames = {
    ScaleType.major: "Major (Ionian)",
    ScaleType.minor: "Natural Minor",
    ScaleType.dorian: "Dorian",
    ScaleType.phrygian: "Phrygian",
    ScaleType.lydian: "Lydian",
    ScaleType.mixolydian: "Mixolydian",
    ScaleType.aeolian: "Aeolian",
    ScaleType.locrian: "Locrian",
  };

  /// Creates a Scale object for the specified key and type.
  ///
  /// This is the main factory method for creating scales. It looks up
  /// the appropriate interval pattern and generates a proper scale name.
  static Scale getScale(Key key, ScaleType type) {
    final intervals = _scaleIntervals[type]!;
    final typeName = _scaleNames[type]!;
    final keyName = _getKeyName(key);

    return Scale(
      key: key,
      type: type,
      intervals: intervals,
      name: "$keyName $typeName",
    );
  }

  /// Convenience getter for the C Major scale.
  ///
  /// This is commonly used as a reference scale and starting point
  /// for piano education.
  static Scale get cMajor => getScale(Key.c, ScaleType.major);

  static String _getKeyName(Key key) {
    return key.displayName;
  }
}
