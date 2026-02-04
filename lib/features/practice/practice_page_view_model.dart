import "dart:async";

import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/domain/constants/midi_protocol_constants.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/state/practice_session.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;
import "package:piano_fitness/application/utils/virtual_piano_utils.dart";

/// ViewModel for managing practice page state and operations.
///
/// This class handles all business logic for the practice interface.
class PracticePageViewModel extends ChangeNotifier {
  /// Creates a new PracticePageViewModel with injected dependencies.
  PracticePageViewModel({
    required IMidiRepository midiRepository,
    required MidiState midiState,
    int initialChannel = 0,
  }) : _midiRepository = midiRepository,
       _midiState = midiState,
       _midiChannel = initialChannel {
    _midiState.setSelectedChannel(_midiChannel);
    _midiState.addListener(notifyListeners);
    _setupMidiHandlers();
  }

  static final _log = Logger("PracticePageViewModel");

  final IMidiRepository _midiRepository;
  final MidiState _midiState;
  final int _midiChannel;
  late final void Function(Uint8List) _dataHandler;

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

  /// Initializes the practice session with required callbacks.
  void initializePracticeSession({
    required VoidCallback onExerciseCompleted,
    required void Function(List<NotePosition>) onHighlightedNotesChanged,
    PracticeMode initialMode = PracticeMode.scales,
    ChordProgression? initialChordProgression,
  }) {
    _practiceSession = PracticeSession(
      onExerciseCompleted: onExerciseCompleted,
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

  /// Sets up MIDI handlers through repository.
  void _setupMidiHandlers() {
    _dataHandler = (Uint8List data) {
      if (kDebugMode) {
        _log.fine("Received MIDI data: $data");
      }
      try {
        handleMidiData(data);
      } on Exception catch (e) {
        _log.warning("MIDI data handler error: $e");
      }
    };

    _midiRepository.registerDataHandler(_dataHandler);
  }

  /// Handles incoming MIDI data and updates state with practice session integration.
  ///
  /// Uses the domain service for MIDI parsing and coordinates with both
  /// MidiState (application layer) and PracticeSession for exercise tracking.
  /// The PracticeSession handles its own auto-start logic when notes are pressed.
  ///
  /// This method is public for testing purposes.
  @visibleForTesting
  void handleMidiData(Uint8List data) {
    try {
      // Use domain service for MIDI parsing
      MidiService.handleMidiData(data, (MidiEvent event) {
        try {
          switch (event.type) {
            case MidiEventType.noteOn:
              // Update application state
              _midiState.noteOn(event.data1, event.data2, event.channel);
              // Coordinate with practice session for exercise tracking
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
        } catch (e, stackTrace) {
          _log.warning("Error handling MIDI event: $e", e, stackTrace);
          _midiState.setLastNote("Error processing MIDI event");
        }
      });
    } catch (e, stackTrace) {
      _log.severe("Error parsing MIDI data: $e", e, stackTrace);
      _midiState.setLastNote("Error parsing MIDI data");
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
    // Validate MIDI note range using domain constants
    if (note < MidiProtocol.noteMin || note > MidiProtocol.noteMax) {
      _log.warning(
        "Invalid MIDI note: $note (must be between "
        "${MidiProtocol.noteMin} and ${MidiProtocol.noteMax})",
      );
      _midiState.setLastNote("Invalid MIDI note: $note");
      return;
    }

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

  /// Calculates the 49-key range centered around the current practice exercise.
  ///
  /// Delegates to PracticeSession to get all notes that will be visible,
  /// which automatically accounts for hand selection.
  NoteRange calculatePracticeRange() {
    final session = _practiceSession;
    if (session == null) {
      return PianoRangeUtils.calculateFixed49KeyRange([]);
    }

    // Get all notes from the single source of truth
    final allNotes = session.getNotesForRangeCalculation();
    return PianoRangeUtils.calculateFixed49KeyRange(allNotes);
  }

  @override
  void dispose() {
    _midiRepository.unregisterDataHandler(_dataHandler);
    _midiState.removeListener(notifyListeners);
    unawaited(VirtualPianoUtils.dispose(_midiRepository));
    super.dispose();
  }
}
