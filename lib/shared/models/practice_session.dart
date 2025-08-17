import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

/// Manages the state and logic for piano practice sessions.
///
/// This class coordinates practice exercises across different modes (scales, chords, arpeggios),
/// tracks progress through note sequences, and provides feedback through callbacks.
/// It handles MIDI input processing and highlights the correct notes to play.
class PracticeSession {
  /// Creates a new practice session with required callbacks for UI updates.
  ///
  /// The [onExerciseCompleted] callback is fired when a practice exercise
  /// is successfully completed. The [onHighlightedNotesChanged] callback
  /// is fired whenever the set of notes to highlight on the piano changes.
  PracticeSession({
    required this.onExerciseCompleted,
    required this.onHighlightedNotesChanged,
  });

  static final _log = Logger("PracticeSession");

  /// Callback fired when a practice exercise is completed successfully.
  final VoidCallback onExerciseCompleted;

  /// Callback fired when the highlighted notes on the piano should change.
  ///
  /// Receives a list of [NotePosition] objects representing the notes
  /// that should be highlighted on the piano keyboard.
  final void Function(List<NotePosition>) onHighlightedNotesChanged;

  PracticeMode _practiceMode = PracticeMode.scales;
  music.Key _selectedKey = music.Key.c;
  music.ScaleType _selectedScaleType = music.ScaleType.major;

  // Arpeggio-specific state
  MusicalNote _selectedRootNote = MusicalNote.c;
  ArpeggioType _selectedArpeggioType = ArpeggioType.major;
  ArpeggioOctaves _selectedArpeggioOctaves = ArpeggioOctaves.one;

  // Chord progression-specific state
  ChordProgression? _selectedChordProgression;

  List<int> _currentSequence = [];
  int _currentNoteIndex = 0;
  bool _practiceActive = false;

  List<ChordInfo> _currentChordProgression = [];
  int _currentChordIndex = 0;
  final Set<int> _currentlyHeldChordNotes = {};

  /// The currently selected practice mode (scales, chords, or arpeggios).
  PracticeMode get practiceMode => _practiceMode;

  /// The currently selected musical key for scale and chord exercises.
  music.Key get selectedKey => _selectedKey;

  /// The currently selected scale type for scale exercises.
  music.ScaleType get selectedScaleType => _selectedScaleType;

  /// The currently selected root note for arpeggio exercises.
  MusicalNote get selectedRootNote => _selectedRootNote;

  /// The currently selected arpeggio type.
  ArpeggioType get selectedArpeggioType => _selectedArpeggioType;

  /// The currently selected octave range for arpeggio exercises.
  ArpeggioOctaves get selectedArpeggioOctaves => _selectedArpeggioOctaves;

  /// The currently selected chord progression type for chord progression exercises.
  ChordProgression? get selectedChordProgression => _selectedChordProgression;

  /// The current sequence of MIDI note numbers for the active exercise.
  List<int> get currentSequence => _currentSequence;

  /// The index of the next note to be played in the current sequence.
  int get currentNoteIndex => _currentNoteIndex;

  /// Whether a practice session is currently active.
  bool get practiceActive => _practiceActive;

  /// The current chord progression for chord practice mode.
  List<ChordInfo> get currentChordProgression => _currentChordProgression;

  /// The index of the current chord in the chord progression.
  int get currentChordIndex => _currentChordIndex;

  /// Sets the practice mode and reinitializes the exercise sequence.
  ///
  /// Automatically stops any active practice session and generates
  /// a new exercise sequence based on the selected mode.
  void setPracticeMode(PracticeMode mode) {
    _practiceMode = mode;
    _practiceActive = false;
    _initializeSequence();
  }

  /// Sets the musical key for scale and chord exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the exercise sequence in the new key.
  void setSelectedKey(music.Key key) {
    _selectedKey = key;
    _practiceActive = false;
    _initializeSequence();
  }

  /// Sets the scale type for scale exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the scale sequence with the new type (major, minor, modal, etc.).
  void setSelectedScaleType(music.ScaleType type) {
    _selectedScaleType = type;
    _practiceActive = false;
    _initializeSequence();
  }

  /// Sets the root note for arpeggio exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence starting from the new root note.
  void setSelectedRootNote(MusicalNote rootNote) {
    _selectedRootNote = rootNote;
    _practiceActive = false;
    _initializeSequence();
  }

  /// Sets the arpeggio type (major, minor, diminished, etc.).
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence with the new chord quality.
  void setSelectedArpeggioType(ArpeggioType type) {
    _selectedArpeggioType = type;
    _practiceActive = false;
    _initializeSequence();
  }

  /// Sets the octave range for arpeggio exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence to span the specified number of octaves.
  void setSelectedArpeggioOctaves(ArpeggioOctaves octaves) {
    _selectedArpeggioOctaves = octaves;
    _practiceActive = false;
    _initializeSequence();
  }

  /// Sets the chord progression type for chord progression exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord progression sequence with the new progression type.
  void setSelectedChordProgression(ChordProgression progression) {
    _selectedChordProgression = progression;
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
    } else if (_practiceMode == PracticeMode.chordProgressions) {
      // For chord progressions, generate based on the selected progression
      if (_selectedChordProgression != null) {
        _currentChordProgression = _selectedChordProgression!.generateChords(
          _selectedKey,
        );
        _currentSequence = _generateChordProgressionMidiSequence(
          _currentChordProgression,
          4,
        );
      } else {
        // Default to I-V if no progression selected
        final defaultProgression = ChordProgressionLibrary.getProgressionByName(
          "I - V",
        );
        if (defaultProgression != null) {
          _selectedChordProgression = defaultProgression;
          _currentChordProgression = defaultProgression.generateChords(
            _selectedKey,
          );
          _currentSequence = _generateChordProgressionMidiSequence(
            _currentChordProgression,
            4,
          );
        }
      }
      _currentNoteIndex = 0;
      _currentChordIndex = 0;
      _currentlyHeldChordNotes.clear();
      _updateHighlightedNotes();
    }
  }

  void _updateHighlightedNotes() {
    if (_currentSequence.isEmpty ||
        _currentNoteIndex >= _currentSequence.length) {
      onHighlightedNotesChanged([]);
      return;
    }

    if (_practiceMode == PracticeMode.scales ||
        _practiceMode == PracticeMode.arpeggios) {
      final currentMidiNote = _currentSequence[_currentNoteIndex];
      final noteInfo = NoteUtils.midiNumberToNote(currentMidiNote);
      final notePosition = NoteUtils.noteToNotePosition(
        noteInfo.note,
        noteInfo.octave,
      );
      onHighlightedNotesChanged([notePosition]);
    } else if (_practiceMode == PracticeMode.chords ||
        _practiceMode == PracticeMode.chordProgressions) {
      if (_currentChordIndex < _currentChordProgression.length) {
        final currentChord = _currentChordProgression[_currentChordIndex];
        final chordMidiNotes = currentChord.getMidiNotes(4);
        final highlightedPositions = <NotePosition>[];

        _log.fine(
          "Highlighting chord ${_currentChordIndex + 1}: ${currentChord.name} with MIDI notes: $chordMidiNotes",
        );

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

  /// Handles MIDI note press events during practice sessions.
  ///
  /// Processes incoming MIDI note data and advances the exercise if the
  /// correct note is played. Behavior varies by practice mode:
  /// - Scales/Arpeggios: Expects sequential note playing
  /// - Chords/ChordProgressions: Expects simultaneous chord notes to be held
  ///
  /// The [midiNote] parameter should be the MIDI note number (0-127).
  void handleNotePressed(int midiNote) {
    if (!_practiceActive || _currentSequence.isEmpty) return;

    if (_practiceMode == PracticeMode.scales ||
        _practiceMode == PracticeMode.arpeggios) {
      final expectedNote = _currentSequence[_currentNoteIndex];

      if (midiNote == expectedNote) {
        _currentNoteIndex++;

        if (_currentNoteIndex >= _currentSequence.length) {
          _completeExercise();
        } else {
          _updateHighlightedNotes();
        }
      }
    } else if (_practiceMode == PracticeMode.chords ||
        _practiceMode == PracticeMode.chordProgressions) {
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

  /// Handles MIDI note release events during chord practice.
  ///
  /// Removes the released note from the set of currently held chord notes.
  /// This is primarily used in chord and chord progression modes to track
  /// which notes are being held simultaneously.
  ///
  /// The [midiNote] parameter should be the MIDI note number (0-127).
  void handleNoteReleased(int midiNote) {
    if ((_practiceMode == PracticeMode.chords ||
            _practiceMode == PracticeMode.chordProgressions) &&
        _practiceActive) {
      _currentlyHeldChordNotes.remove(midiNote);
    }
  }

  void _checkChordCompletion() {
    if (_currentChordIndex < _currentChordProgression.length) {
      final currentChord = _currentChordProgression[_currentChordIndex];
      final expectedChordNotes = currentChord.getMidiNotes(4).toSet();

      if (_currentlyHeldChordNotes.containsAll(expectedChordNotes)) {
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

  /// Generates a MIDI note sequence from a list of ChordInfo objects.
  ///
  /// Returns a flattened list of MIDI note numbers representing all the notes
  /// in the chord progression, starting from the specified octave.
  List<int> _generateChordProgressionMidiSequence(
    List<ChordInfo> chordProgression,
    int startOctave,
  ) {
    final midiSequence = <int>[];

    for (final chord in chordProgression) {
      final chordMidi = chord.getMidiNotes(startOctave);
      midiSequence.addAll(chordMidi);
    }

    return midiSequence;
  }

  /// Starts a new practice session with the current exercise configuration.
  ///
  /// Resets all progress indicators and begins highlighting the first note(s)
  /// in the sequence. The exercise will remain active until completed or reset.
  void startPractice() {
    _practiceActive = true;
    _currentNoteIndex = 0;
    _currentChordIndex = 0;
    _currentlyHeldChordNotes.clear();
    _updateHighlightedNotes();
  }

  /// Resets the current practice session to its initial state.
  ///
  /// Stops the active session and resets all progress indicators.
  /// The exercise configuration (mode, key, type) remains unchanged.
  void resetPractice() {
    _practiceActive = false;
    _currentNoteIndex = 0;
    _currentChordIndex = 0;
    _currentlyHeldChordNotes.clear();
    _updateHighlightedNotes();
  }

  /// Triggers exercise completion for testing purposes only.
  ///
  /// This method is intended for use in unit tests to simulate
  /// the completion of a practice exercise without having to
  /// play through the entire sequence.
  @visibleForTesting
  void triggerCompletionForTesting() {
    _completeExercise();
  }
}
