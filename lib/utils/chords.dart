import 'note_utils.dart';
import 'scales.dart';

enum ChordType { major, minor, diminished, augmented }

enum ChordInversion { root, first, second }

class ChordInfo {
  final List<MusicalNote> notes;
  final ChordType type;
  final ChordInversion inversion;
  final String name;
  final MusicalNote rootNote;

  const ChordInfo({
    required this.notes,
    required this.type,
    required this.inversion,
    required this.name,
    required this.rootNote,
  });

  List<int> getMidiNotes(int octave) {
    final midiNotes = <int>[];

    for (int i = 0; i < notes.length; i++) {
      int noteOctave = octave;
      int baseMidiNote = NoteUtils.noteToMidiNumber(notes[i], noteOctave);

      // For inversions, allow notes to go higher to maintain proper voicing
      // and avoid artificial octave limitations that cause confusing jumps
      if (midiNotes.isNotEmpty && baseMidiNote <= midiNotes.last) {
        // Keep moving up octaves until we find a proper position
        while (baseMidiNote <= midiNotes.last && baseMidiNote < 127) {
          noteOctave++;
          baseMidiNote = NoteUtils.noteToMidiNumber(notes[i], noteOctave);
        }
      }

      // Ensure we don't exceed MIDI range
      if (baseMidiNote <= 127) {
        midiNotes.add(baseMidiNote);
      }
    }

    return midiNotes;
  }
}

class ChordDefinitions {
  static const Map<ChordType, List<int>> _chordIntervals = {
    ChordType.major: [0, 4, 7],
    ChordType.minor: [0, 3, 7],
    ChordType.diminished: [0, 3, 6],
    ChordType.augmented: [0, 4, 8],
  };

  static const Map<ChordType, String> _chordTypeNames = {
    ChordType.major: '',
    ChordType.minor: 'm',
    ChordType.diminished: '°',
    ChordType.augmented: '+',
  };

  static const Map<ChordInversion, String> _inversionNames = {
    ChordInversion.root: '',
    ChordInversion.first: '1st inv',
    ChordInversion.second: '2nd inv',
  };

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
    final rootName = NoteUtils.noteDisplayName(rootNote, 0).replaceAll('0', '');
    final typeName = _chordTypeNames[type]!;
    final inversionName = _inversionNames[inversion]!;

    if (inversionName.isEmpty) {
      return '$rootName$typeName';
    } else {
      return '$rootName$typeName ($inversionName)';
    }
  }

  static List<ChordType> getChordsInKey(Key key, ScaleType scaleType) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chords = <ChordType>[];

    for (int i = 0; i < 7; i++) {
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

  static int _getIntervalBetweenNotes(MusicalNote note1, MusicalNote note2) {
    int interval = note2.index - note1.index;
    if (interval < 0) interval += 12;
    return interval;
  }

  static List<ChordInfo> getKeyTriadProgression(Key key, ScaleType scaleType) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chordTypes = getChordsInKey(key, scaleType);
    final progression = <ChordInfo>[];

    for (int i = 0; i < 7; i++) {
      final rootNote = scaleNotes[i];
      final chordType = chordTypes[i];

      progression.add(getChord(rootNote, chordType, ChordInversion.root));
      progression.add(getChord(rootNote, chordType, ChordInversion.first));
      progression.add(getChord(rootNote, chordType, ChordInversion.second));
    }

    return progression;
  }

  /// Returns a smoother chord progression sequence for learning inversions.
  /// Sequence: root, 1st inversion, 2nd inversion, 1st inversion, next chord...
  /// This creates a more natural hand movement pattern for students.
  static List<ChordInfo> getSmoothKeyTriadProgression(
    Key key,
    ScaleType scaleType,
  ) {
    final scale = ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final chordTypes = getChordsInKey(key, scaleType);
    final progression = <ChordInfo>[];

    for (int i = 0; i < 7; i++) {
      final rootNote = scaleNotes[i];
      final chordType = chordTypes[i];

      // Smooth sequence: root -> 1st -> 2nd -> 1st -> (next chord)
      progression.add(getChord(rootNote, chordType, ChordInversion.root));
      progression.add(getChord(rootNote, chordType, ChordInversion.first));
      progression.add(getChord(rootNote, chordType, ChordInversion.second));
      progression.add(getChord(rootNote, chordType, ChordInversion.first));
    }

    return progression;
  }

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
  static List<int> getSmoothChordProgressionMidiSequence(
    Key key,
    ScaleType scaleType,
    int startOctave,
  ) {
    final progression = getSmoothKeyTriadProgression(key, scaleType);
    final midiSequence = <int>[];
    int currentOctave = startOctave;
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
