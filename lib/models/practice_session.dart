import 'package:flutter/foundation.dart';
import 'package:piano/piano.dart';
import '../utils/arpeggios.dart';
import '../utils/chords.dart';
import '../utils/note_utils.dart';
import '../utils/scales.dart' as music;
import '../widgets/practice_settings_panel.dart';

class PracticeSession {
  final VoidCallback onExerciseCompleted;
  final Function(List<NotePosition>) onHighlightedNotesChanged;
  
  PracticeMode _practiceMode = PracticeMode.scales;
  music.Key _selectedKey = music.Key.c;
  music.ScaleType _selectedScaleType = music.ScaleType.major;
  
  // Arpeggio-specific state
  MusicalNote _selectedRootNote = MusicalNote.c;
  ArpeggioType _selectedArpeggioType = ArpeggioType.major;
  ArpeggioOctaves _selectedArpeggioOctaves = ArpeggioOctaves.one;
  
  List<int> _currentSequence = [];
  int _currentNoteIndex = 0;
  bool _practiceActive = false;
  
  List<ChordInfo> _currentChordProgression = [];
  int _currentChordIndex = 0;
  final Set<int> _currentlyHeldChordNotes = {};

  PracticeSession({
    required this.onExerciseCompleted,
    required this.onHighlightedNotesChanged,
  });

  PracticeMode get practiceMode => _practiceMode;
  music.Key get selectedKey => _selectedKey;
  music.ScaleType get selectedScaleType => _selectedScaleType;
  MusicalNote get selectedRootNote => _selectedRootNote;
  ArpeggioType get selectedArpeggioType => _selectedArpeggioType;
  ArpeggioOctaves get selectedArpeggioOctaves => _selectedArpeggioOctaves;
  List<int> get currentSequence => _currentSequence;
  int get currentNoteIndex => _currentNoteIndex;
  bool get practiceActive => _practiceActive;
  List<ChordInfo> get currentChordProgression => _currentChordProgression;
  int get currentChordIndex => _currentChordIndex;

  void setPracticeMode(PracticeMode mode) {
    _practiceMode = mode;
    _practiceActive = false;
    _initializeSequence();
  }

  void setSelectedKey(music.Key key) {
    _selectedKey = key;
    _practiceActive = false;
    _initializeSequence();
  }

  void setSelectedScaleType(music.ScaleType type) {
    _selectedScaleType = type;
    _practiceActive = false;
    _initializeSequence();
  }

  void setSelectedRootNote(MusicalNote rootNote) {
    _selectedRootNote = rootNote;
    _practiceActive = false;
    _initializeSequence();
  }

  void setSelectedArpeggioType(ArpeggioType type) {
    _selectedArpeggioType = type;
    _practiceActive = false;
    _initializeSequence();
  }

  void setSelectedArpeggioOctaves(ArpeggioOctaves octaves) {
    _selectedArpeggioOctaves = octaves;
    _practiceActive = false;
    _initializeSequence();
  }

  void _initializeSequence() {
    if (_practiceMode == PracticeMode.scales) {
      final scale = music.ScaleDefinitions.getScale(
        _selectedKey,
        _selectedScaleType,
      );
      _currentSequence = scale.getFullScaleSequence(4);
      _currentNoteIndex = 0;
      _updateHighlightedNotes();
    } else if (_practiceMode == PracticeMode.chords) {
      _currentChordProgression = ChordDefinitions.getSmoothKeyTriadProgression(
        _selectedKey,
        _selectedScaleType,
      );
      _currentSequence = ChordDefinitions.getSmoothChordProgressionMidiSequence(
        _selectedKey,
        _selectedScaleType,
        4,
      );
      _currentNoteIndex = 0;
      _currentChordIndex = 0;
      _currentlyHeldChordNotes.clear();
      _updateHighlightedNotes();
    } else if (_practiceMode == PracticeMode.arpeggios) {
      final arpeggio = ArpeggioDefinitions.getArpeggio(
        _selectedRootNote,
        _selectedArpeggioType,
        _selectedArpeggioOctaves,
      );
      _currentSequence = arpeggio.getFullArpeggioSequence(4);
      _currentNoteIndex = 0;
      _updateHighlightedNotes();
    }
  }

  void _updateHighlightedNotes() {
    if (_currentSequence.isEmpty ||
        _currentNoteIndex >= _currentSequence.length) {
      onHighlightedNotesChanged([]);
      return;
    }

    if (_practiceMode == PracticeMode.scales || _practiceMode == PracticeMode.arpeggios) {
      final currentMidiNote = _currentSequence[_currentNoteIndex];
      final noteInfo = NoteUtils.midiNumberToNote(currentMidiNote);
      final notePosition = NoteUtils.noteToNotePosition(
        noteInfo.note,
        noteInfo.octave,
      );
      onHighlightedNotesChanged([notePosition]);
    } else if (_practiceMode == PracticeMode.chords) {
      if (_currentChordIndex < _currentChordProgression.length) {
        final currentChord = _currentChordProgression[_currentChordIndex];
        final chordMidiNotes = currentChord.getMidiNotes(4);
        final highlightedPositions = <NotePosition>[];

        if (kDebugMode) {
          print(
            'Highlighting chord ${_currentChordIndex + 1}: ${currentChord.name} with MIDI notes: $chordMidiNotes',
          );
        }

        for (final midiNote in chordMidiNotes) {
          final noteInfo = NoteUtils.midiNumberToNote(midiNote);
          final notePosition = NoteUtils.noteToNotePosition(
            noteInfo.note,
            noteInfo.octave,
          );
          highlightedPositions.add(notePosition);
        }

        onHighlightedNotesChanged(highlightedPositions);
      }
    }
  }

  void handleNotePressed(int midiNote) {
    if (!_practiceActive || _currentSequence.isEmpty) return;

    if (_practiceMode == PracticeMode.scales || _practiceMode == PracticeMode.arpeggios) {
      final expectedNote = _currentSequence[_currentNoteIndex];

      if (midiNote == expectedNote) {
        _currentNoteIndex++;

        if (_currentNoteIndex >= _currentSequence.length) {
          _completeExercise();
        } else {
          _updateHighlightedNotes();
        }
      }
    } else if (_practiceMode == PracticeMode.chords) {
      if (_currentChordIndex < _currentChordProgression.length) {
        final currentChord = _currentChordProgression[_currentChordIndex];
        final expectedChordNotes = currentChord.getMidiNotes(4);

        if (expectedChordNotes.contains(midiNote)) {
          _currentlyHeldChordNotes.add(midiNote);
          _checkChordCompletion();
        }
      }
    }
  }

  void handleNoteReleased(int midiNote) {
    if (_practiceMode == PracticeMode.chords && _practiceActive) {
      _currentlyHeldChordNotes.remove(midiNote);
    }
  }

  void _checkChordCompletion() {
    if (_currentChordIndex < _currentChordProgression.length) {
      final currentChord = _currentChordProgression[_currentChordIndex];
      final expectedChordNotes = currentChord.getMidiNotes(4).toSet();

      if (expectedChordNotes.every(
        (note) => _currentlyHeldChordNotes.contains(note),
      )) {
        _currentChordIndex++;
        _currentlyHeldChordNotes.clear();

        if (_currentChordIndex >= _currentChordProgression.length) {
          _completeExercise();
        } else {
          _updateHighlightedNotes();
        }
      }
    }
  }

  void _completeExercise() {
    _practiceActive = false;
    onHighlightedNotesChanged([]);
    onExerciseCompleted();
  }

  void startPractice() {
    _practiceActive = true;
    _currentNoteIndex = 0;
    _currentChordIndex = 0;
    _currentlyHeldChordNotes.clear();
    _updateHighlightedNotes();
  }

  void resetPractice() {
    _practiceActive = false;
    _currentNoteIndex = 0;
    _currentChordIndex = 0;
    _currentlyHeldChordNotes.clear();
    _updateHighlightedNotes();
  }
}