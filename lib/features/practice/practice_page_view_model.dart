import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/practice_session.dart";
import "package:piano_fitness/shared/services/midi_service.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/piano_range_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;
import "package:piano_fitness/shared/utils/virtual_piano_utils.dart";

/// ViewModel for managing practice page state and operations.
///
/// This class handles all business logic for the practice interface,
/// managing its own local MIDI state for practice-specific note tracking
/// and piano range calculations.
class PracticePageViewModel extends ChangeNotifier {
  /// Creates a new PracticePageViewModel with optional initial configuration.
  PracticePageViewModel({int initialChannel = 0})
    : _midiChannel = initialChannel {
    _localMidiState = MidiState();
    _localMidiState.setSelectedChannel(_midiChannel);
    _setupMidiListener();
  }

  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();
  final int _midiChannel;
  late final MidiState _localMidiState;

  PracticeSession? _practiceSession;
  List<NotePosition> _highlightedNotes = [];

  /// Local MIDI state for this practice page instance.
  MidiState get localMidiState => _localMidiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  /// MIDI command instance for low-level operations.
  MidiCommand get midiCommand => _midiCommand;

  /// Practice session instance for exercise management.
  PracticeSession? get practiceSession => _practiceSession;

  /// Currently highlighted notes for piano display.
  List<NotePosition> get highlightedNotes => _highlightedNotes;

  /// Sets the MIDI state reference for updating UI state.
  ///
  /// Note: The Practice page now uses its own local MIDI state, so this method
  /// is maintained for compatibility but no longer needed.
  @Deprecated(
    "Practice page now uses local MIDI state. Use localMidiState instead.",
  )
  void setMidiState(MidiState midiState) {
    // No-op: We use local state now
  }

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

  /// Sets up MIDI listener for incoming data.
  void _setupMidiListener() {
    final midiDataStream = _midiCommand.onMidiDataReceived;
    if (midiDataStream != null) {
      _midiDataSubscription = midiDataStream.listen(
        (packet) {
          if (kDebugMode) {
            print("Received MIDI data: ${packet.data}");
          }
          try {
            handleMidiData(packet.data);
          } on Exception catch (e) {
            if (kDebugMode) print("MIDI data handler error: $e");
          }
        },
        onError: (Object error) {
          if (kDebugMode) print("MIDI data stream error: $error");
        },
      );
    } else {
      if (kDebugMode) {
        print("Warning: MIDI data stream is not available");
      }
    }
  }

  /// Handles incoming MIDI data and updates local state.
  void handleMidiData(Uint8List data) {
    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          _localMidiState.noteOn(event.data1, event.data2, event.channel);
          if (_practiceSession != null) {
            _practiceSession?.handleNotePressed(event.data1);
          }
          break;
        case MidiEventType.noteOff:
          _localMidiState.noteOff(event.data1, event.channel);
          if (_practiceSession != null) {
            _practiceSession?.handleNoteReleased(event.data1);
          }
          break;
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          _localMidiState.setLastNote(event.displayMessage);
          break;
      }
    });
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

  /// Plays a virtual note through MIDI output and triggers practice session.
  Future<void> playVirtualNote(int note, {bool mounted = true}) async {
    if (_practiceSession == null) return;

    await VirtualPianoUtils.playVirtualNote(
      note,
      _localMidiState,
      _practiceSession!.handleNotePressed,
      mounted: mounted,
    );
  }

  /// Calculates the appropriate highlighted notes for piano display.
  List<NotePosition> getDisplayHighlightedNotes() {
    return _highlightedNotes.isNotEmpty
        ? _highlightedNotes
        : _localMidiState.highlightedNotePositions;
  }

  /// Calculates the 49-key range centered around the current practice exercise.
  NoteRange calculatePracticeRange() {
    return PianoRangeUtils.calculateFixed49KeyRange(
      _practiceSession?.currentSequence ?? [],
    );
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    VirtualPianoUtils.dispose();
    // Dispose local MIDI state
    _localMidiState.dispose();
    super.dispose();
  }
}
