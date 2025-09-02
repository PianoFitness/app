import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/constants/musical_constants.dart";
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
  static const int defaultStartOctave = MusicalConstants.baseOctave;

  static final _log = Logger("PracticeSession");

  /// Helper getter to check if current practice mode is any chord-based mode.
  bool get _isChordMode =>
      _practiceMode == PracticeMode.chordsByKey ||
      _practiceMode == PracticeMode.chordsByType ||
      _practiceMode == PracticeMode.chordProgressions;

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

  // Chord type-specific state
  ChordType _selectedChordType = ChordType.major;
  bool _includeInversions = true;
  ChordByType? _selectedChordByType;

  List<int> _currentSequence = [];
  int _currentNoteIndex = 0;
  bool _practiceActive = false;

  List<ChordInfo> _currentChordProgression = [];
  int _currentChordIndex = 0;
  final Set<int> _currentlyHeldChordNotes = {};

  /// The currently selected practice mode (scales, chords by key, chords by type, arpeggios, or chord progressions).
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

  /// The currently selected chord type for chord type exercises.
  ChordType get selectedChordType => _selectedChordType;

  /// Whether to include inversions in chord type exercises.
  bool get includeInversions => _includeInversions;

  /// The currently selected chord by type exercise.
  ChordByType? get selectedChordByType => _selectedChordByType;

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
    _applyConfigChange(() => _practiceMode = mode);
  }

  /// Sets the musical key for scale and chord exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the exercise sequence in the new key.
  void setSelectedKey(music.Key key) {
    _applyConfigChange(() => _selectedKey = key);
  }

  /// Sets the scale type for scale exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the scale sequence with the new type (major, minor, modal, etc.).
  void setSelectedScaleType(music.ScaleType type) {
    _applyConfigChange(() => _selectedScaleType = type);
  }

  /// Sets the root note for arpeggio exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence starting from the new root note.
  void setSelectedRootNote(MusicalNote rootNote) {
    _applyConfigChange(() => _selectedRootNote = rootNote);
  }

  /// Sets the arpeggio type (major, minor, diminished, etc.).
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence with the new chord quality.
  void setSelectedArpeggioType(ArpeggioType type) {
    _applyConfigChange(() => _selectedArpeggioType = type);
  }

  /// Sets the octave range for arpeggio exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence to span the specified number of octaves.
  void setSelectedArpeggioOctaves(ArpeggioOctaves octaves) {
    _applyConfigChange(() => _selectedArpeggioOctaves = octaves);
  }

  /// Sets the chord progression type for chord progression exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord progression sequence with the new progression type.
  void setSelectedChordProgression(ChordProgression progression) {
    _applyConfigChange(() => _selectedChordProgression = progression);
  }

  /// Sets the chord type for chord type exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord type sequence with the new type.
  void setSelectedChordType(ChordType type) {
    _applyConfigChange(() => _selectedChordType = type);
  }

  /// Sets whether to include inversions in chord type exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord sequence with the new inversion setting.
  void setIncludeInversions(bool includeInversions) {
    _applyConfigChange(() => _includeInversions = includeInversions);
  }

  /// Applies a config mutation, then resets practice state and rebuilds the sequence.
  void _applyConfigChange(void Function() update) {
    _practiceActive = false;
    update();
    _initializeSequence();
  }

  void _initializeSequence() {
    if (_practiceMode == PracticeMode.scales) {
      final scale = music.ScaleDefinitions.getScale(
        _selectedKey,
        _selectedScaleType,
      );
      _currentSequence = scale.getFullScaleSequence(defaultStartOctave);
      _currentNoteIndex = 0;
      _updateHighlightedNotes();
    } else if (_practiceMode == PracticeMode.chordsByKey) {
      _currentChordProgression = ChordDefinitions.getSmoothKeyTriadProgression(
        _selectedKey,
        _selectedScaleType,
      );
      _currentSequence = ChordDefinitions.getSmoothChordProgressionMidiSequence(
        _selectedKey,
        _selectedScaleType,
        defaultStartOctave,
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
      _currentSequence = arpeggio.getFullArpeggioSequence(defaultStartOctave);
      _currentNoteIndex = 0;
      _updateHighlightedNotes();
    } else if (_practiceMode == PracticeMode.chordsByType) {
      // Generate chord type exercise - always use all 12 keys for chord planing
      final exercise = ChordByTypeDefinitions.getChordTypeExercise(
        _selectedChordType,
        includeInversions: _includeInversions,
      );
      _selectedChordByType = exercise;
      _currentChordProgression = exercise.generateChordSequence();
      _currentSequence = exercise.getMidiSequenceFrom(
        _currentChordProgression,
        defaultStartOctave,
      );
      _currentNoteIndex = 0;
      _currentChordIndex = 0;
      _currentlyHeldChordNotes.clear();
      _updateHighlightedNotes();
    } else if (_practiceMode == PracticeMode.chordProgressions) {
      // For chord progressions, generate based on the selected progression
      if (_selectedChordProgression != null) {
        _currentChordProgression = _selectedChordProgression!.generateChords(
          _selectedKey,
        );
        _currentSequence = _generateChordProgressionMidiSequence(
          _currentChordProgression,
          defaultStartOctave,
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
            defaultStartOctave,
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
    } else if (_isChordMode) {
      if (_currentChordIndex < _currentChordProgression.length) {
        final currentChord = _currentChordProgression[_currentChordIndex];
        final chordMidiNotes = currentChord.getMidiNotes(defaultStartOctave);
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
    } else if (_isChordMode) {
      if (_currentChordIndex < _currentChordProgression.length) {
        final currentChord = _currentChordProgression[_currentChordIndex];
        final expectedChordNotes = currentChord.getMidiNotes(
          defaultStartOctave,
        );

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
    if (_isChordMode && _practiceActive) {
      _currentlyHeldChordNotes.remove(midiNote);
    }
  }

  void _checkChordCompletion() {
    if (_currentChordIndex < _currentChordProgression.length) {
      final currentChord = _currentChordProgression[_currentChordIndex];
      final expectedChordNotes = currentChord
          .getMidiNotes(defaultStartOctave)
          .toSet();

      // Require exactly the expected notes to be held (no extras)
      if (setEquals(_currentlyHeldChordNotes, expectedChordNotes)) {
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
    onExerciseCompleted();

    // Reset for immediate repetition - ready for next practice session
    _currentNoteIndex = 0;
    _currentChordIndex = 0;
    _currentlyHeldChordNotes.clear();
    _updateHighlightedNotes();
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
  /// Ready for immediate repetition when next note is played.
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
