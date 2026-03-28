import "dart:async";

import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano/piano.dart";
import "package:uuid/uuid.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/state/practice_session.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/models/midi/midi_event.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/application/utils/piano_note_bridge.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/application/utils/virtual_piano_utils.dart";

/// ViewModel for managing practice page state and operations.
///
/// This class handles all business logic for the practice interface.
class PracticePageViewModel extends ChangeNotifier {
  /// Creates a new PracticePageViewModel with injected dependencies.
  PracticePageViewModel({
    required MidiCoordinator midiCoordinator,
    required IMidiRepository midiRepository,
    required MidiState midiState,
    required IUserProfileRepository userProfileRepository,
    required IExerciseHistoryRepository exerciseHistoryRepository,
    int initialChannel = 0,
  }) : _midiRepository = midiRepository,
       _midiState = midiState,
       _userProfileRepository = userProfileRepository,
       _exerciseHistoryRepository = exerciseHistoryRepository,
       _midiChannel = initialChannel {
    _midiState.setSelectedChannel(_midiChannel);
    _midiState.addListener(notifyListeners);
    _subscription = midiCoordinator.subscribe(midiState, _handleMidiEvent);
  }

  static final _log = Logger("PracticePageViewModel");
  static const _uuid = Uuid();

  final IMidiRepository _midiRepository;
  final MidiState _midiState;
  final IUserProfileRepository _userProfileRepository;
  final IExerciseHistoryRepository _exerciseHistoryRepository;
  final int _midiChannel;
  late final MidiSubscription _subscription;

  PracticeSession? _practiceSession;
  List<NotePosition> _highlightedNotes = [];

  /// Global MIDI state shared across the app.
  MidiState get midiState => _midiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  /// Practice session instance for exercise management.
  PracticeSession? get practiceSession => _practiceSession;

  /// Currently highlighted notes for piano display.
  List<NotePosition> get highlightedNotes => _highlightedNotes;

  /// Current exercise configuration from the practice session.
  ///
  /// Returns null if the practice session is not initialized.
  /// Returns the unified configuration used for the current exercise.
  ExerciseConfiguration? get currentConfiguration => _practiceSession?.config;

  /// Initializes the practice session with required callbacks.
  void initializePracticeSession({
    required VoidCallback onExerciseCompleted,
    required void Function(List<NotePosition>) onHighlightedNotesChanged,
    PracticeMode initialMode = PracticeMode.scales,
    ChordProgression? initialChordProgression,
  }) {
    _practiceSession = PracticeSession(
      onExerciseCompleted: () {
        // Snapshot configuration synchronously before crossing the async
        // boundary so _recordExerciseHistory reads consistent state.
        final config = _practiceSession?.config;
        unawaited(_recordExerciseHistory(config));
        onExerciseCompleted();
      },
      onHighlightedNotesChanged: (List<NotePosition> notes) {
        _highlightedNotes = notes;
        onHighlightedNotesChanged(notes);
        notifyListeners();
      },
    );
    _practiceSession!.setPracticeMode(initialMode);

    // Set initial chord progression if provided
    if (initialChordProgression != null) {
      _practiceSession!.setSelectedChordProgression(initialChordProgression);
    }
  }

  /// Records the just-completed exercise to the history log.
  ///
  /// [config] must be snapshotted synchronously by the caller before any
  /// async boundary, to avoid reading stale session state.
  ///
  /// Silently skips (with a warning) when no active profile is set or when
  /// [config] is null, so that the exercise completion UI is never blocked.
  Future<void> _recordExerciseHistory(ExerciseConfiguration? config) async {
    try {
      if (config == null) {
        _log.warning("Skipping exercise history save: no active configuration");
        return;
      }

      final profileId = await _userProfileRepository.getActiveProfileId();
      if (profileId == null) {
        _log.warning(
          "Skipping exercise history save: no active profile selected",
        );
        return;
      }

      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: _uuid.v4(),
        profileId: profileId,
        completedAt: DateTime.now(),
        config: config,
      );

      await _exerciseHistoryRepository.saveEntry(entry);
      _log.fine("Saved exercise history entry: ${entry.id}");
    } catch (e, stackTrace) {
      // Log but do not rethrow: history save failures must not disrupt the
      // user's practice flow.
      _log.severe("Failed to save exercise history", e, stackTrace);
    }
  }

  void _handleMidiEvent(MidiEvent event) {
    if (kDebugMode) {
      _log.fine("Received MIDI event: ${event.displayMessage}");
    }
    switch (event.type) {
      case MidiEventType.noteOn:
        _midiState.noteOn(event.data1, event.data2, event.channel);
        _practiceSession?.handleNotePressed(event.data1);
        break;
      case MidiEventType.noteOff:
        _midiState.noteOff(event.data1, event.channel);
        _practiceSession?.handleNoteReleased(event.data1);
        break;
      case MidiEventType.controlChange:
      case MidiEventType.programChange:
      case MidiEventType.pitchBend:
      case MidiEventType.other:
        _midiState.setLastNote(event.displayMessage);
        break;
    }
  }

  /// Starts the current practice session.
  void startPractice() {
    _practiceSession?.startPractice();
    notifyListeners();
  }

  /// Resets the current practice session.
  void resetPractice() {
    _practiceSession?.resetPractice();
    notifyListeners();
  }

  /// Updates the exercise configuration and reinitializes the exercise sequence.
  ///
  /// Validates the configuration via [ExerciseConfiguration.validate],
  /// then stops any active practice session and generates a new exercise
  /// sequence based on the new configuration.
  ///
  /// Throws [ArgumentError] if the configuration is invalid (missing required fields).
  void updateConfiguration(ExerciseConfiguration newConfig) {
    _practiceSession?.updateConfiguration(newConfig);
    notifyListeners();
  }

  // Legacy setter methods for backward compatibility (delegate to PracticeSession)

  /// Changes the practice mode and updates the session.
  void setPracticeMode(PracticeMode mode) {
    _practiceSession?.setPracticeMode(mode);
    notifyListeners();
  }

  /// Changes the selected key and updates the session.
  void setSelectedKey(music.Key key) {
    _practiceSession?.setSelectedKey(key);
    notifyListeners();
  }

  /// Changes the selected scale type and updates the session.
  void setSelectedScaleType(music.ScaleType type) {
    _practiceSession?.setSelectedScaleType(type);
    notifyListeners();
  }

  /// Changes the selected root note and updates the session.
  void setSelectedRootNote(MusicalNote rootNote) {
    _practiceSession?.setSelectedRootNote(rootNote);
    notifyListeners();
  }

  /// Changes the selected arpeggio type and updates the session.
  void setSelectedArpeggioType(ArpeggioType type) {
    _practiceSession?.setSelectedArpeggioType(type);
    notifyListeners();
  }

  /// Changes the selected arpeggio octaves and updates the session.
  void setSelectedArpeggioOctaves(ArpeggioOctaves octaves) {
    _practiceSession?.setSelectedArpeggioOctaves(octaves);
    notifyListeners();
  }

  /// Changes the selected chord progression type and updates the session.
  void setSelectedChordProgression(ChordProgression progression) {
    _practiceSession?.setSelectedChordProgression(progression);
    notifyListeners();
  }

  /// Changes the selected chord type and updates the session.
  void setSelectedChordType(ChordType type) {
    _practiceSession?.setSelectedChordType(type);
    notifyListeners();
  }

  /// Changes the include inversions setting and updates the session.
  void setIncludeInversions(bool includeInversions) {
    _practiceSession?.setIncludeInversions(includeInversions);
    notifyListeners();
  }

  /// Changes the include seventh chords setting and updates the session.
  void setIncludeSeventhChords(bool includeSeventhChords) {
    _practiceSession?.setIncludeSeventhChords(includeSeventhChords);
    notifyListeners();
  }

  /// Changes the selected hand and updates the session.
  void setSelectedHandSelection(HandSelection handSelection) {
    _practiceSession?.setSelectedHandSelection(handSelection);
    notifyListeners();
  }

  /// Enables or disables automatic key progression through the circle of fifths.
  ///
  /// When enabled, completing an exercise will automatically advance to the next
  /// key in the circle of fifths. The progression starts from the currently selected
  /// key and continues cycling through all twelve keys.
  void setAutoKeyProgression(bool enable) {
    _practiceSession?.setAutoKeyProgression(enable);
    notifyListeners();
  }

  /// Plays a virtual note through MIDI output and triggers practice session.
  ///
  /// The practice session handles its own auto-start logic when notes are pressed.
  /// Validates that [note] is within the valid MIDI range (0-127) before forwarding.
  Future<void> playVirtualNote(int note, {bool mounted = true}) async {
    await VirtualPianoUtils.playVirtualNote(
      note,
      _midiRepository,
      _midiState,
      (note) => _practiceSession?.handleNotePressed(note),
      mounted: mounted,
    );
  }

  /// Calculates the appropriate highlighted notes for piano display.
  List<NotePosition> getDisplayHighlightedNotes() {
    return _highlightedNotes.isNotEmpty
        ? _highlightedNotes
        : _midiState.highlightedNotePositions;
  }

  /// MIDI notes for piano range calculation, used by the view to compute display range.
  List<int> get notesForRangeCalculation =>
      _practiceSession?.getNotesForRangeCalculation() ?? [];

  /// Plays a virtual note from a NotePosition.
  Future<void> playVirtualNoteFromPosition(
    NotePosition position, {
    bool mounted = true,
  }) async {
    final midiNote = PianoNoteBridge.convertNotePositionToMidi(position);
    await playVirtualNote(midiNote, mounted: mounted);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _midiState.removeListener(notifyListeners);
    unawaited(VirtualPianoUtils.dispose(_midiRepository));
    super.dispose();
  }
}
