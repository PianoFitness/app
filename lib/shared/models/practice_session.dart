import "package:flutter/foundation.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/constants/musical_constants.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_exercise.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/practice_strategies/practice_strategies.dart";
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

  // Hand selection state
  HandSelection _selectedHandSelection = HandSelection.both;

  // Current exercise state using unified model
  PracticeExercise? _currentExercise;
  int _currentStepIndex = 0;
  bool _practiceActive = false;

  final Set<int> _currentlyHeldNotes = {};

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

  /// The currently selected hand for practice exercises.
  HandSelection get selectedHandSelection => _selectedHandSelection;

  /// The current exercise being practiced.
  PracticeExercise? get currentExercise => _currentExercise;

  /// The index of the current step in the exercise.
  int get currentStepIndex => _currentStepIndex;

  /// Whether a practice session is currently active.
  bool get practiceActive => _practiceActive;

  /// Legacy getter for current sequence (flattened from exercise steps).
  /// @Deprecated('Use currentExercise instead')
  List<int> get currentSequence {
    if (_currentExercise == null) return [];
    return _currentExercise!.steps.expand((step) => step.notes).toList();
  }

  /// Legacy getter for current note index.
  /// @Deprecated('Use currentStepIndex instead')
  int get currentNoteIndex {
    // For backward compatibility, calculate flat index from step index
    if (_currentExercise == null) return 0;
    int flatIndex = 0;
    for (
      int i = 0;
      i < _currentStepIndex && i < _currentExercise!.steps.length;
      i++
    ) {
      flatIndex += _currentExercise!.steps[i].notes.length;
    }
    return flatIndex;
  }

  /// Legacy getter for chord progression (extracted from exercise).
  /// @Deprecated('Use currentExercise instead')
  List<ChordInfo> get currentChordProgression =>
      _extractChordProgressionFromExercise();

  /// Legacy getter for chord index.
  /// @Deprecated('Use currentStepIndex instead')
  int get currentChordIndex => _currentStepIndex;

  /// Returns all MIDI notes that will be visible during this exercise.
  ///
  /// This method accounts for hand selection and returns all notes that
  /// should be considered when calculating the piano keyboard range.
  /// This is the single source of truth for range calculation.
  List<int> getNotesForRangeCalculation() {
    if (_currentExercise == null) {
      return [];
    }

    return _currentExercise!.getAllNotes().toList();
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
    _initializeSequence();
  }

  /// Creates the appropriate strategy based on the current practice mode.
  PracticeStrategy _createStrategy() {
    switch (_practiceMode) {
      case PracticeMode.scales:
        return ScalesStrategy(
          key: _selectedKey,
          scaleType: _selectedScaleType,
          handSelection: _selectedHandSelection,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.arpeggios:
        return ArpeggiosStrategy(
          rootNote: _selectedRootNote,
          arpeggioType: _selectedArpeggioType,
          arpeggioOctaves: _selectedArpeggioOctaves,
          handSelection: _selectedHandSelection,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.chordsByKey:
        return ChordsByKeyStrategy(
          key: _selectedKey,
          scaleType: _selectedScaleType,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.chordsByType:
        return ChordsByTypeStrategy(
          chordType: _selectedChordType,
          includeInversions: _includeInversions,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.chordProgressions:
        return ChordProgressionsStrategy(
          key: _selectedKey,
          chordProgression: _selectedChordProgression,
          startOctave: defaultStartOctave,
        );
    }
  }

  void _initializeSequence() {
    final strategy = _createStrategy();
    _currentExercise = strategy.initializeExercise();
    _currentStepIndex = 0;
    _currentlyHeldNotes.clear();

    // Update chord-specific state for chordsByType mode
    if (_practiceMode == PracticeMode.chordsByType &&
        strategy is ChordsByTypeStrategy) {
      _selectedChordByType = strategy.exercise;
    }

    // Update chord progression for chordProgressions mode
    if (_practiceMode == PracticeMode.chordProgressions &&
        strategy is ChordProgressionsStrategy) {
      _selectedChordProgression = strategy.chordProgression;
    }

    _updateHighlightedNotes();
  }

  /// Extracts chord progression from current exercise for chord-based modes.
  /// Returns empty list for non-chord exercises.
  List<ChordInfo> _extractChordProgressionFromExercise() {
    if (_currentExercise == null) return [];

    final exercise = _currentExercise!;
    final exerciseType = exercise.metadata?["exerciseType"] as String?;

    // Only extract chord progression for chord-based exercises
    if (exerciseType == null ||
        ![
          "chordsByKey",
          "chordsByType",
          "chordProgressions",
        ].contains(exerciseType)) {
      return [];
    }

    // Rebuild ChordInfo objects from step metadata
    final chords = <ChordInfo>[];
    for (final step in exercise.steps) {
      if (step.type == StepType.simultaneous && step.metadata != null) {
        final metadata = step.metadata!;
        final rootNoteName = metadata["rootNote"] as String?;
        final chordTypeName = metadata["chordType"] as String?;
        final inversionName = metadata["inversion"] as String?;

        if (rootNoteName != null &&
            chordTypeName != null &&
            inversionName != null) {
          final rootNote = MusicalNote.values.byName(rootNoteName);
          final chordType = ChordType.values.byName(chordTypeName);
          final inversion = ChordInversion.values.byName(inversionName);

          chords.add(ChordDefinitions.getChord(rootNote, chordType, inversion));
        }
      }
    }
    return chords;
  }

  void _updateHighlightedNotes() {
    if (_currentExercise == null ||
        _currentStepIndex >= _currentExercise!.steps.length) {
      onHighlightedNotesChanged([]);
      return;
    }

    final currentStep = _currentExercise!.steps[_currentStepIndex];
    final highlightedPositions = <NotePosition>[];

    for (final midiNote in currentStep.notes) {
      final noteInfo = NoteUtils.midiNumberToNote(midiNote);
      final notePosition = NoteUtils.noteToNotePosition(
        noteInfo.note,
        noteInfo.octave,
      );
      highlightedPositions.add(notePosition);
    }

    onHighlightedNotesChanged(highlightedPositions);
  }

  /// Handles MIDI note press events during practice sessions.
  ///
  /// Processes incoming MIDI note data and advances the exercise if the
  /// correct note is played. Behavior varies by step type:
  /// - Sequential: Expects one note at a time
  /// - Paired: Expects both notes to be held simultaneously
  /// - Simultaneous: Expects all chord notes to be held together
  ///
  /// The [midiNote] parameter should be the MIDI note number (0-127).
  void handleNotePressed(int midiNote) {
    if (!_practiceActive ||
        _currentExercise == null ||
        _currentStepIndex >= _currentExercise!.steps.length) {
      return;
    }

    final currentStep = _currentExercise!.steps[_currentStepIndex];

    switch (currentStep.type) {
      case StepType.sequential:
        // Expect one note at a time
        if (currentStep.notes.length == 1 && midiNote == currentStep.notes[0]) {
          _advanceToNextStep();
        }
        break;

      case StepType.paired:
        // Expect both notes of the pair to be held simultaneously
        if (currentStep.notes.contains(midiNote)) {
          _currentlyHeldNotes.add(midiNote);

          // Check if all notes in the pair are now held
          if (currentStep.notes.every(
            (note) => _currentlyHeldNotes.contains(note),
          )) {
            _currentlyHeldNotes.clear();
            _advanceToNextStep();
          }
        }
        break;

      case StepType.simultaneous:
        // Track all held notes (including wrong ones) so set equality
        // in _checkChordCompletion enforces "no extras"
        _currentlyHeldNotes.add(midiNote);
        _checkChordCompletion();
        break;
    }
  }

  /// Advances to the next step in the exercise.
  void _advanceToNextStep() {
    _currentStepIndex++;

    if (_currentStepIndex >= _currentExercise!.steps.length) {
      _completeExercise();
    } else {
      _updateHighlightedNotes();
    }
  }

  /// Handles MIDI note release events during practice.
  ///
  /// Removes the released note from the set of currently held notes.
  /// This is used for paired and simultaneous step types.
  ///
  /// The [midiNote] parameter should be the MIDI note number (0-127).
  void handleNoteReleased(int midiNote) {
    if (_practiceActive) {
      _currentlyHeldNotes.remove(midiNote);
    }
  }

  void _checkChordCompletion() {
    if (_currentExercise == null ||
        _currentStepIndex >= _currentExercise!.steps.length) {
      return;
    }

    final currentStep = _currentExercise!.steps[_currentStepIndex];
    final expectedNotes = currentStep.notes.toSet();

    // Require exactly the expected notes to be held (no extras)
    if (setEquals(_currentlyHeldNotes, expectedNotes)) {
      _currentlyHeldNotes.clear();
      _advanceToNextStep();
    }
  }

  void _completeExercise() {
    _practiceActive = false;
    onExerciseCompleted();

    // Reset for immediate repetition - ready for next practice session
    _currentStepIndex = 0;
    _currentlyHeldNotes.clear();
    _updateHighlightedNotes();
  }

  /// Starts a new practice session with the current exercise configuration.
  ///
  /// Resets all progress indicators and begins highlighting the first note(s)
  /// in the sequence. The exercise will remain active until completed or reset.
  void startPractice() {
    _practiceActive = true;
    _currentStepIndex = 0;
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
    _currentStepIndex = 0;
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
