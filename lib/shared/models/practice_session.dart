import "package:piano_fitness/shared/models/chord_type.dart" show ChordType;
import "package:flutter/foundation.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/constants/musical_constants.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;
import "package:piano_fitness/shared/utils/arpeggios.dart"
    show ArpeggioType, ArpeggioOctaves;
import "package:piano_fitness/shared/models/music_key.dart" show MusicKey;
import "package:piano_fitness/shared/models/scale_type.dart" show ScaleType;
import "package:piano_fitness/shared/models/chord_progression_type.dart"
    show ChordProgression;
import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/strategy_factory.dart";
import "package:piano_fitness/shared/models/configurations/scale_configuration.dart";
import "package:piano_fitness/shared/models/configurations/arpeggio_configuration.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_key_configuration.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_type_configuration.dart";
import "package:piano_fitness/shared/models/configurations/chord_progression_configuration.dart";
import "package:piano_fitness/shared/utils/chords.dart" show ChordInfo;

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

  /// The current chord progression as a list of ChordInfo for UI display.
  List<ChordInfo> get currentChordProgression {
    if (_practiceMode == PracticeMode.chordProgressions &&
        _selectedChordProgression != null) {
      // ChordProgression from chord_progression_type.dart implements generateChords(Key)
      return (_selectedChordProgression as dynamic).generateChords(_selectedKey)
          as List<ChordInfo>;
    }
    return [];
  }

  static const int defaultStartOctave = MusicalConstants.baseOctave;

  /// Helper getter to check if current practice mode is any chord-based mode.

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

  // Hand selection state
  HandSelection _selectedHandSelection = HandSelection.both;

  int _currentNoteIndex = 0;
  bool _practiceActive = false;
  final Set<int> _currentlyHeldNotes = {};
  late PracticeStrategy _strategy;
  final StrategyFactory _strategyFactory = StrategyFactory();

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

  /// The currently selected hand for practice exercises.
  HandSelection get selectedHandSelection => _selectedHandSelection;

  /// The current sequence of MIDI note numbers for the active exercise.
  List<int> get currentSequence => _strategy.generateSequence();

  /// The index of the next note to be played in the current sequence.
  int get currentNoteIndex => _currentNoteIndex;

  /// Whether a practice session is currently active.
  bool get practiceActive => _practiceActive;

  /// The current chord progression for chord practice mode.
  // Chord progression is now handled by the strategy if needed.
  int get currentChordIndex => _currentNoteIndex; // For compatibility

  /// Returns all MIDI notes that will be visible during this exercise.
  ///
  /// This method accounts for hand selection and returns all notes that
  /// should be considered when calculating the piano keyboard range.
  /// This is the single source of truth for range calculation.
  List<int> getNotesForRangeCalculation() {
    return _strategy.generateSequence();
  }

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

  /// Sets the hand selection for practice exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the exercise sequence for the selected hand(s).
  void setSelectedHandSelection(HandSelection handSelection) {
    _applyConfigChange(() => _selectedHandSelection = handSelection);
  }

  /// Applies a config mutation, then resets practice state and rebuilds the sequence.
  void _applyConfigChange(void Function() update) {
    _practiceActive = false;
    update();
    _initializeStrategy();
  }

  void _initializeStrategy() {
    // Build the correct configuration for the current mode
    PracticeConfiguration config;
    // Convert music.Key to MusicKey and music.ScaleType to ScaleType
    MusicKey toMusicKey(music.Key k) {
      // Map by index, assuming enums are in the same order
      return MusicKey.values[k.index];
    }

    ScaleType toScaleType(music.ScaleType t) {
      // Guard against out-of-range index
      if (t.index < ScaleType.values.length) {
        return ScaleType.values[t.index];
      } else {
        // Fallback to major if out of range (should not happen in normal use)
        return ScaleType.major;
      }
    }

    // Convert from utils ChordType to model ChordType (by name)
    switch (_practiceMode) {
      case PracticeMode.scales:
        config = ScaleConfiguration(
          selectedKey: toMusicKey(_selectedKey),
          selectedScaleType: toScaleType(_selectedScaleType),
          handSelection: _selectedHandSelection,
        );
        break;
      case PracticeMode.arpeggios:
        config = ArpeggioConfiguration(
          selectedRootNote: _selectedRootNote,
          selectedArpeggioType: _selectedArpeggioType,
          selectedArpeggioOctaves: _selectedArpeggioOctaves,
          handSelection: _selectedHandSelection,
        );
        break;
      case PracticeMode.chordsByKey:
        config = ChordsByKeyConfiguration(
          selectedKey: toMusicKey(_selectedKey),
          selectedScaleType: toScaleType(_selectedScaleType),
          handSelection: _selectedHandSelection,
        );
        break;
      case PracticeMode.chordsByType:
        config = ChordsByTypeConfiguration(
          selectedChordType: _selectedChordType,
          includeInversions: _includeInversions,
          handSelection: _selectedHandSelection,
        );
        break;
      case PracticeMode.chordProgressions:
        config = ChordProgressionConfiguration(
          selectedChordProgression: _selectedChordProgression,
          selectedKey: toMusicKey(_selectedKey),
          handSelection: _selectedHandSelection,
        );
        break;
    }
    _strategy = _strategyFactory.createStrategy(config);
    _currentNoteIndex = 0;
    _currentlyHeldNotes.clear();
    _updateHighlightedNotes();
  }

  void _updateHighlightedNotes() {
    final sequence = _strategy.generateSequence();
    if (sequence.isEmpty || _currentNoteIndex >= sequence.length) {
      onHighlightedNotesChanged([]);
      return;
    }
    final highlightedMidiNotes = _strategy.getHighlightedNotes(
      _currentNoteIndex,
    );
    final highlightedPositions = highlightedMidiNotes
        .map((midi) => NoteUtils.midiNumberToNotePosition(midi)!)
        .toList();
    onHighlightedNotesChanged(highlightedPositions);
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
    if (!_practiceActive || _strategy.generateSequence().isEmpty) return;
    if (_strategy.handleNotePressed(midiNote, _currentNoteIndex)) {
      _currentNoteIndex++;
      if (_currentNoteIndex >= _strategy.generateSequence().length) {
        _completeExercise();
      } else {
        _updateHighlightedNotes();
      }
    }
  }

  /// Handles MIDI note release events during practice.
  ///
  /// Removes the released note from the set of currently held notes.
  /// This is used in:
  /// - Chord modes: to track simultaneous chord notes
  /// - Both hands mode for scales/arpeggios: to track both hand notes
  ///
  /// The [midiNote] parameter should be the MIDI note number (0-127).
  void handleNoteReleased(int midiNote) {
    if (_practiceActive) {
      _strategy.handleNoteReleased(midiNote, _currentNoteIndex);
    }
  }

  // Chord completion is now handled by the strategy if needed.

  void _completeExercise() {
    _practiceActive = false;
    onExerciseCompleted();
    _currentNoteIndex = 0;
    _currentlyHeldNotes.clear();
    _updateHighlightedNotes();
  }

  /// Generates a MIDI note sequence from a list of ChordInfo objects.
  ///
  /// Returns a flattened list of MIDI note numbers representing all the notes
  /// in the chord progression, starting from the specified octave.
  // _generateChordProgressionMidiSequence is now obsolete.

  /// Starts a new practice session with the current exercise configuration.
  ///
  /// Resets all progress indicators and begins highlighting the first note(s)
  /// in the sequence. The exercise will remain active until completed or reset.
  void startPractice() {
    _practiceActive = true;
    _currentNoteIndex = 0;
    _currentlyHeldNotes.clear();
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
    _currentlyHeldNotes.clear();
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
