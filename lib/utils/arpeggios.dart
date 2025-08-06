import 'note_utils.dart';

enum ArpeggioType {
  major,
  minor,
  diminished,
  augmented,
  dominant7,
  minor7,
  major7,
}

enum ArpeggioOctaves {
  one,
  two,
}

class Arpeggio {
  final MusicalNote rootNote;
  final ArpeggioType type;
  final ArpeggioOctaves octaves;
  final List<int> intervals;
  final String name;

  const Arpeggio({
    required this.rootNote,
    required this.type,
    required this.octaves,
    required this.intervals,
    required this.name,
  });

  List<MusicalNote> getNotes() {
    final notes = <MusicalNote>[];
    
    for (final interval in intervals) {
      final noteIndex = (rootNote.index + interval) % 12;
      notes.add(MusicalNote.values[noteIndex]);
    }
    
    return notes;
  }

  List<int> getMidiNotes(int startOctave) {
    final arpeggioNotes = getNotes();
    final midiNotes = <int>[];
    
    int currentOctave = startOctave;
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
      for (int i = 1; i < baseNotes.length; i++) {
        final originalMidi = baseNotes[i];
        // Add 12 semitones to get the same note one octave higher
        secondOctaveNotes.add(originalMidi + 12);
      }
      
      final allAscendingNotes = [...baseNotes, ...secondOctaveNotes];
      final descendingNotes = allAscendingNotes.reversed.skip(1).toList();
      return [...allAscendingNotes, ...descendingNotes];
    }
  }
}

class ArpeggioDefinitions {
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
    ArpeggioType.major: 'Major',
    ArpeggioType.minor: 'Minor',
    ArpeggioType.diminished: 'Diminished',
    ArpeggioType.augmented: 'Augmented',
    ArpeggioType.dominant7: 'Dominant 7th',
    ArpeggioType.minor7: 'Minor 7th',
    ArpeggioType.major7: 'Major 7th',
  };

  static Arpeggio getArpeggio(
    MusicalNote rootNote,
    ArpeggioType type,
    ArpeggioOctaves octaves,
  ) {
    final intervals = _arpeggioIntervals[type]!;
    final typeName = _arpeggioTypeNames[type]!;
    final rootName = NoteUtils.noteDisplayName(rootNote, 0).replaceAll('0', '');
    final octaveName = octaves == ArpeggioOctaves.one ? '1 Octave' : '2 Octaves';
    
    return Arpeggio(
      rootNote: rootNote,
      type: type,
      octaves: octaves,
      intervals: intervals,
      name: '$rootName $typeName ($octaveName)',
    );
  }

  // Common arpeggios for a given root note
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

  // Extended arpeggios including 7th chords
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

  // For initial implementation - just C major in both octave options
  static List<Arpeggio> getCMajorArpeggios() {
    return [
      getArpeggio(MusicalNote.c, ArpeggioType.major, ArpeggioOctaves.one),
      getArpeggio(MusicalNote.c, ArpeggioType.major, ArpeggioOctaves.two),
    ];
  }
}