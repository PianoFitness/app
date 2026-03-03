import "package:flutter/foundation.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategies.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/domain/services/music_theory/circle_of_fifths.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

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

  // Unified configuration for practice exercises
  ExerciseConfiguration _config = const ExerciseConfiguration(
    practiceMode: PracticeMode.scales,
    handSelection: HandSelection.both,
    key: music.Key.c,
    scaleType: music.ScaleType.major,
  );

  // Auto key progression state (not yet in config model)
  bool _autoProgressKeys = false;

  // Current exercise state using unified model
  PracticeExercise? _currentExercise;
  int _currentStepIndex = 0;
  bool _practiceActive = false;

  final Set<int> _currentlyHeldNotes = {};

  /// The current exercise configuration.
  ExerciseConfiguration get config => _config;

  /// The currently selected practice mode (scales, chords by key, chords by type, arpeggios, or chord progressions).
  PracticeMode get practiceMode => _config.practiceMode;

  /// The currently selected musical key for scale and chord exercises.
  music.Key? get selectedKey => _config.key;

  /// The currently selected scale type for scale exercises.
  music.ScaleType? get selectedScaleType => _config.scaleType;

  /// The currently selected root note for arpeggio exercises.
  MusicalNote? get selectedRootNote => _config.musicalNote;

  /// The currently selected arpeggio type.
  ArpeggioType? get selectedArpeggioType => _config.arpeggioType;

  /// The currently selected octave range for arpeggio exercises.
  ArpeggioOctaves get selectedArpeggioOctaves => _config.arpeggioOctaves;

  /// The currently selected chord progression type for chord progression exercises.
  ChordProgression? get selectedChordProgression {
    final chordProgressionId = _config.chordProgressionId;
    return chordProgressionId != null
        ? ChordProgressionLibrary.getProgressionByName(chordProgressionId)
        : null;
  }

  /// The currently selected chord type for chord type exercises.
  ChordType? get selectedChordType => _config.chordType;

  /// Whether to include inversions in chord type exercises.
  bool get includeInversions => _config.includeInversions;

  /// Whether to include seventh chords in chord-by-key exercises.
  bool get includeSeventhChords => _config.includeSeventhChords;

  /// Whether to automatically progress through keys following the circle of fifths.
  ///
  /// When enabled, completing an exercise will automatically advance to the next
  /// key in the circle of fifths progression, allowing continuous practice through
  /// all twelve keys without manual key selection.
  bool get autoProgressKeys => _autoProgressKeys;

  /// The currently selected hand for practice exercises.
  HandSelection get selectedHandSelection => _config.handSelection;

  /// The current exercise being practiced.
  PracticeExercise? get currentExercise => _currentExercise;

  /// The index of the current step in the exercise.
  int get currentStepIndex => _currentStepIndex;

  /// Whether a practice session is currently active.
  bool get practiceActive => _practiceActive;

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

  /// Updates the exercise configuration and reinitializes the exercise sequence.
  ///
  /// Validates the configuration via [ExerciseConfiguration.validate],
  /// then stops any active practice session and generates a new exercise
  /// sequence based on the new configuration.
  ///
  /// Throws [ArgumentError] if the configuration is invalid (missing required fields).
  void updateConfiguration(ExerciseConfiguration newConfig) {
    newConfig.validate();
    _applyConfigChange(() => _config = newConfig);
  }

  // Legacy setter methods for backward compatibility (delegate to updateConfiguration)

  /// Sets the practice mode and reinitializes the exercise sequence.
  ///
  /// Automatically stops any active practice session and generates
  /// a new exercise sequence based on the selected mode. Sets sensible
  /// defaults for required fields if they're not already set.
  void setPracticeMode(PracticeMode mode) {
    _applyConfigChange(() {
      var newConfig = _config.copyWith(practiceMode: mode);

      // Set sensible defaults for required fields based on the new mode
      switch (mode) {
        case PracticeMode.scales:
          if (newConfig.key == null) {
            newConfig = newConfig.copyWith(key: Field.set(music.Key.c));
          }
          if (newConfig.scaleType == null) {
            newConfig = newConfig.copyWith(
              scaleType: Field.set(music.ScaleType.major),
            );
          }
          break;
        case PracticeMode.chordsByKey:
          if (newConfig.key == null) {
            newConfig = newConfig.copyWith(key: Field.set(music.Key.c));
          }
          if (newConfig.scaleType == null) {
            newConfig = newConfig.copyWith(
              scaleType: Field.set(music.ScaleType.major),
            );
          }
          break;
        case PracticeMode.chordsByType:
          if (newConfig.chordType == null) {
            newConfig = newConfig.copyWith(
              chordType: Field.set(ChordType.major),
            );
          }
          break;
        case PracticeMode.arpeggios:
          if (newConfig.musicalNote == null) {
            newConfig = newConfig.copyWith(
              musicalNote: Field.set(MusicalNote.c),
            );
          }
          if (newConfig.arpeggioType == null) {
            newConfig = newConfig.copyWith(
              arpeggioType: Field.set(ArpeggioType.major),
            );
          }
          break;
        case PracticeMode.chordProgressions:
          if (newConfig.key == null) {
            newConfig = newConfig.copyWith(key: Field.set(music.Key.c));
          }
          if (newConfig.chordProgressionId == null) {
            newConfig = newConfig.copyWith(
              chordProgressionId: Field.set("I - V"),
            );
          }
          break;
      }

      _config = newConfig;
    });
  }

  /// Sets the musical key for scale and chord exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the exercise sequence in the new key.
  void setSelectedKey(music.Key key) {
    _applyConfigChange(() => _config = _config.copyWith(key: Field.set(key)));
  }

  /// Sets the scale type for scale exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the scale sequence with the new type (major, minor, modal, etc.).
  void setSelectedScaleType(music.ScaleType type) {
    _applyConfigChange(
      () => _config = _config.copyWith(scaleType: Field.set(type)),
    );
  }

  /// Sets the root note for arpeggio exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence starting from the new root note.
  void setSelectedRootNote(MusicalNote rootNote) {
    _applyConfigChange(
      () => _config = _config.copyWith(musicalNote: Field.set(rootNote)),
    );
  }

  /// Sets the arpeggio type (major, minor, diminished, etc.).
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence with the new chord quality.
  void setSelectedArpeggioType(ArpeggioType type) {
    _applyConfigChange(
      () => _config = _config.copyWith(arpeggioType: Field.set(type)),
    );
  }

  /// Sets the octave range for arpeggio exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the arpeggio sequence to span the specified number of octaves.
  void setSelectedArpeggioOctaves(ArpeggioOctaves octaves) {
    _applyConfigChange(
      () => _config = _config.copyWith(arpeggioOctaves: octaves),
    );
  }

  /// Sets the chord progression type for chord progression exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord progression sequence with the new progression type.
  void setSelectedChordProgression(ChordProgression progression) {
    _applyConfigChange(
      () => _config = _config.copyWith(
        chordProgressionId: Field.set(progression.name),
      ),
    );
  }

  /// Sets the chord type for chord type exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord type sequence with the new type.
  void setSelectedChordType(ChordType type) {
    _applyConfigChange(
      () => _config = _config.copyWith(chordType: Field.set(type)),
    );
  }

  /// Sets whether to include inversions in chord type exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord sequence with the new inversion setting.
  void setIncludeInversions(bool includeInversions) {
    _applyConfigChange(
      () => _config = _config.copyWith(includeInversions: includeInversions),
    );
  }

  /// Sets whether to include seventh chords in chord-by-key exercises.
  ///
  /// When enabled, chord-by-key exercises will use seventh chords (4 notes)
  /// instead of triads (3 notes). This allows practicing diatonic seventh
  /// chord progressions (e.g., Imaj7, ii7, V7 in major keys).
  ///
  /// Automatically stops any active practice session and regenerates
  /// the chord sequence with the new setting.
  void setIncludeSeventhChords(bool includeSeventhChords) {
    _applyConfigChange(
      () => _config = _config.copyWith(
        includeSeventhChords: includeSeventhChords,
      ),
    );
  }

  /// Sets the hand selection for practice exercises.
  ///
  /// Automatically stops any active practice session and regenerates
  /// the exercise sequence for the selected hand(s).
  void setSelectedHandSelection(HandSelection handSelection) {
    _applyConfigChange(
      () => _config = _config.copyWith(handSelection: handSelection),
    );
  }

  /// Enables or disables automatic key progression through the circle of fifths.
  ///
  /// When enabled, completing an exercise will automatically advance to the next
  /// key in the circle of fifths. The progression starts from the currently selected
  /// key and continues cycling through all twelve keys.
  ///
  /// This setting does not regenerate the current exercise, only affects behavior
  /// upon exercise completion.
  void setAutoKeyProgression(bool enable) {
    _autoProgressKeys = enable;
  }

  /// Applies a config mutation, then resets practice state and rebuilds the sequence.
  void _applyConfigChange(void Function() update) {
    _practiceActive = false;
    update();
    _initializeSequence();
  }

  /// Creates the appropriate strategy based on the current practice mode.
  PracticeStrategy _createStrategy() {
    switch (_config.practiceMode) {
      case PracticeMode.scales:
        return ScalesStrategy(
          key: _config.key!,
          scaleType: _config.scaleType!,
          handSelection: _config.handSelection,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.arpeggios:
        return ArpeggiosStrategy(
          rootNote: _config.musicalNote!,
          arpeggioType: _config.arpeggioType!,
          arpeggioOctaves: _config.arpeggioOctaves,
          handSelection: _config.handSelection,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.chordsByKey:
        return ChordsByKeyStrategy(
          key: _config.key!,
          scaleType: _config.scaleType!,
          handSelection: _config.handSelection,
          startOctave: defaultStartOctave,
          includeSeventhChords: _config.includeSeventhChords,
        );
      case PracticeMode.chordsByType:
        return ChordsByTypeStrategy(
          chordType: _config.chordType!,
          includeInversions: _config.includeInversions,
          handSelection: _config.handSelection,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.chordProgressions:
        // Default to I-V progression if none selected
        final progression =
            selectedChordProgression ??
            ChordProgressionLibrary.getProgressionByName("I - V")!;

        return ChordProgressionsStrategy(
          key: _config.key!,
          chordProgression: progression,
          handSelection: _config.handSelection,
          startOctave: defaultStartOctave,
        );
    }
  }

  void _initializeSequence() {
    // Apply default progression if none selected (for chordProgressions mode)
    if (_config.practiceMode == PracticeMode.chordProgressions &&
        _config.chordProgressionId == null) {
      _config = _config.copyWith(chordProgressionId: const Field.set("I - V"));
    }

    final strategy = _createStrategy();
    _currentExercise = strategy.initializeExercise();
    _currentStepIndex = 0;
    _currentlyHeldNotes.clear();

    _updateHighlightedNotes();
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
  /// Automatically starts the practice session on the first note if not already active.
  /// Processes incoming MIDI note data and advances the exercise if the
  /// correct note is played. Behavior varies by step type:
  /// - Sequential: Expects one note at a time
  /// - Paired: Expects both notes to be held simultaneously
  /// - Simultaneous: Expects all chord notes to be held together
  ///
  /// The [midiNote] parameter should be the MIDI note number (0-127).
  void handleNotePressed(int midiNote) {
    // Auto-start practice on first MIDI note if not already active
    if (!_practiceActive) {
      startPractice();
    }

    if (_currentExercise == null ||
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

    // If auto-progression is enabled, advance to the next key in the circle of fifths
    if (_autoProgressKeys) {
      _progressToNextKey();
    }

    // Reset for immediate repetition - ready for next practice session
    _currentStepIndex = 0;
    _currentlyHeldNotes.clear();
    _updateHighlightedNotes();
  }

  /// Progresses to the next key in the circle of fifths.
  ///
  /// This method is called automatically when auto-progression is enabled and
  /// an exercise is completed. It advances the selected key to the next position
  /// in the circle of fifths and regenerates the exercise with the new key.
  ///
  /// For arpeggio mode, this also updates the root note to match the new key
  /// using the keyToMusicalNote conversion utility.
  void _progressToNextKey() {
    final currentKey = _config.key!;
    final nextKey = CircleOfFifths.getNextKey(currentKey);

    // For arpeggios, also update the root note to match the key
    if (_config.practiceMode == PracticeMode.arpeggios) {
      _config = _config.copyWith(
        key: Field.set(nextKey),
        musicalNote: Field.set(NoteUtils.keyToMusicalNote(nextKey)),
      );
    } else {
      _config = _config.copyWith(key: Field.set(nextKey));
    }

    _initializeSequence();
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
