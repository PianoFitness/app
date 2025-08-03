import 'note_utils.dart';

enum ScaleType {
  major,
  minor,
  dorian,
  phrygian,
  lydian,
  mixolydian,
  aeolian,
  locrian,
}

enum Key { c, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b }

class Scale {
  final Key key;
  final ScaleType type;
  final List<int> intervals;
  final String name;

  const Scale({
    required this.key,
    required this.type,
    required this.intervals,
    required this.name,
  });

  List<MusicalNote> getNotes() {
    final startingNote = _keyToMusicalNote(key);
    final notes = <MusicalNote>[];

    int currentNote = startingNote.index;
    notes.add(startingNote);

    for (final interval in intervals) {
      currentNote = (currentNote + interval) % 12;
      notes.add(MusicalNote.values[currentNote]);
    }

    return notes;
  }

  List<int> getMidiNotes(int startOctave) {
    final scaleNotes = getNotes();
    final midiNotes = <int>[];

    int currentOctave = startOctave;
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

class ScaleDefinitions {
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
    ScaleType.major: 'Major (Ionian)',
    ScaleType.minor: 'Natural Minor',
    ScaleType.dorian: 'Dorian',
    ScaleType.phrygian: 'Phrygian',
    ScaleType.lydian: 'Lydian',
    ScaleType.mixolydian: 'Mixolydian',
    ScaleType.aeolian: 'Aeolian',
    ScaleType.locrian: 'Locrian',
  };

  static Scale getScale(Key key, ScaleType type) {
    final intervals = _scaleIntervals[type]!;
    final typeName = _scaleNames[type]!;
    final keyName = _getKeyName(key);

    return Scale(
      key: key,
      type: type,
      intervals: intervals,
      name: '$keyName $typeName',
    );
  }

  static Scale get cMajor => getScale(Key.c, ScaleType.major);

  static String _getKeyName(Key key) {
    switch (key) {
      case Key.c:
        return 'C';
      case Key.cSharp:
        return 'C#';
      case Key.d:
        return 'D';
      case Key.dSharp:
        return 'D#';
      case Key.e:
        return 'E';
      case Key.f:
        return 'F';
      case Key.fSharp:
        return 'F#';
      case Key.g:
        return 'G';
      case Key.gSharp:
        return 'G#';
      case Key.a:
        return 'A';
      case Key.aSharp:
        return 'A#';
      case Key.b:
        return 'B';
    }
  }
}
