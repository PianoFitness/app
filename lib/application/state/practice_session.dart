import "package:flutter/foundation.dart";
import "package:piano_fitness/application/state/exercise_strategy_factory.dart";
import "package:piano_fitness/application/state/practice_runner.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;

/// Manages the state and logic for piano practice sessions.
///
/// This class coordinates practice exercises by delegating execution
/// to a [PracticeRunner] and building strategies via [ExerciseStrategyFactory].
class PracticeSession {
  PracticeSession({
    required this.onExerciseCompleted,
    required this.onHighlightedNotesChanged,
  });

  final void Function(
    double? accuracyPercentage,
    int? correctNoteCount,
    int? errorCount,
  )
  onExerciseCompleted;

  final void Function(List<int>) onHighlightedNotesChanged;

  ExerciseConfiguration _config = const ExerciseConfiguration(
    practiceMode: PracticeMode.scales,
    handSelection: HandSelection.both,
    key: music.Key.c,
    scaleType: music.ScaleType.major,
  );

  bool _autoProgressKeys = false;
  PracticeRunner? _runner;

  /// The current exercise configuration.
  ExerciseConfiguration get config => _config;

  // Configuration getters
  PracticeMode get practiceMode => _config.practiceMode;
  music.Key? get selectedKey => _config.key;
  music.ScaleType? get selectedScaleType => _config.scaleType;
  MusicalNote? get selectedRootNote => _config.musicalNote;
  ArpeggioType? get selectedArpeggioType => _config.arpeggioType;
  ArpeggioOctaves get selectedArpeggioOctaves => _config.arpeggioOctaves;
  ChordProgression? get selectedChordProgression {
    final chordProgressionId = _config.chordProgressionId;
    return chordProgressionId != null
        ? ChordProgressionLibrary.getProgressionByName(chordProgressionId)
        : null;
  }

  ChordType? get selectedChordType => _config.chordType;
  bool get includeInversions => _config.includeInversions;
  bool get includeSeventhChords => _config.includeSeventhChords;
  bool get autoProgressKeys => _autoProgressKeys;
  HandSelection get selectedHandSelection => _config.handSelection;

  // Execution getters (delegate to runner)
  PracticeExercise? get currentExercise => _runner?.exercise;
  int get currentStepIndex => _runner?.currentStepIndex ?? 0;
  PracticeStep? get currentStep => _runner?.currentStep;
  bool get practiceActive => _runner?.practiceActive ?? false;
  Set<int> get correctHeldNotes => _runner?.correctHeldNotes ?? {};
  Set<int> get wrongHeldNotes => _runner?.wrongHeldNotes ?? {};

  List<MidiNote> getNotesForRangeCalculation() {
    if (_runner?.exercise == null) return [];
    return _runner!.exercise.getAllNotes().toList();
  }

  void updateConfiguration(ExerciseConfiguration newConfig) {
    newConfig.validate();
    _config = newConfig;
    _initializeSequence();
  }

  void setAutoKeyProgression(bool enable) {
    _autoProgressKeys = enable;
  }

  void _initializeSequence() {
    // Build the exercise from the current config
    final strategy = ExerciseStrategyFactory.create(_config);
    final exercise = strategy.initializeExercise();

    // Create a new runner with this exercise
    _runner = PracticeRunner(
      exercise: exercise,
      onExerciseCompleted: _handleExerciseCompleted,
      onHighlightedNotesChanged: onHighlightedNotesChanged,
    );

    // Initial highlight
    _runner!.resetPractice();
  }

  void _handleExerciseCompleted(
    double? accuracyPercentage,
    int? correctNoteCount,
    int? errorCount,
  ) {
    onExerciseCompleted(accuracyPercentage, correctNoteCount, errorCount);

    if (_autoProgressKeys) {
      _config = _config.nextInCircleOfFifths();
      _initializeSequence();
    } else {
      _runner?.resetPractice();
    }
  }

  void startPractice() => _runner?.startPractice();
  void resetPractice() => _runner?.resetPractice();
  void handleNotePressed(int midiNote) => _runner?.handleNotePressed(midiNote);
  void handleNoteReleased(int midiNote) =>
      _runner?.handleNoteReleased(midiNote);

  @visibleForTesting
  // ignore: invalid_use_of_visible_for_testing_member
  void triggerCompletionForTesting() => _runner?.triggerCompletionForTesting();
}
