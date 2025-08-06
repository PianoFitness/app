import "package:piano_fitness/utils/note_utils.dart";

/// The different types of musical scales supported by the Piano Fitness app.
/// 
/// Each scale type represents a different pattern of intervals that creates
/// a unique musical character and sound.
enum ScaleType {
  /// The major scale (Ionian mode) - bright, happy sound
  major,
  /// The natural minor scale - darker, more melancholic sound  
  minor,
  /// The Dorian mode - minor scale with raised 6th degree
  dorian,
  /// The Phrygian mode - minor scale with lowered 2nd degree
  phrygian,
  /// The Lydian mode - major scale with raised 4th degree
  lydian,
  /// The Mixolydian mode - major scale with lowered 7th degree
  mixolydian,
  /// The Aeolian mode - same as natural minor scale
  aeolian,
  /// The Locrian mode - diminished scale with lowered 2nd and 5th degrees
  locrian,
}

/// The twelve chromatic musical keys supported by the Piano Fitness app.
/// 
/// Each key represents a different starting pitch for scales and exercises.
/// Keys are named using the sharp (#) notation for black keys.
enum Key {
  /// C natural
  c,
  /// C sharp / D flat
  cSharp,
  /// D natural
  d,
  /// D sharp / E flat
  dSharp,
  /// E natural
  e,
  /// F natural
  f,
  /// F sharp / G flat
  fSharp,
  /// G natural
  g,
  /// G sharp / A flat
  gSharp,
  /// A natural
  a,
  /// A sharp / B flat
  aSharp,
  /// B natural
  b
}

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
    switch (key) {
      case Key.c:
        return "C";
      case Key.cSharp:
        return "C#";
      case Key.d:
        return "D";
      case Key.dSharp:
        return "D#";
      case Key.e:
        return "E";
      case Key.f:
        return "F";
      case Key.fSharp:
        return "F#";
      case Key.g:
        return "G";
      case Key.gSharp:
        return "G#";
      case Key.a:
        return "A";
      case Key.aSharp:
        return "A#";
      case Key.b:
        return "B";
    }
  }
}
