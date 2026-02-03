import "dart:async";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/virtual_piano_utils.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";

/// ViewModel for managing play page state and MIDI operations.
///
/// This class handles all business logic for the main play interface,
/// using the global MIDI state for note tracking and visual feedback
/// while coordinating with the MIDI repository for device operations.
class PlayPageViewModel extends ChangeNotifier {
  /// Creates a new PlayPageViewModel with dependency injection.
  PlayPageViewModel({
    required IMidiRepository midiRepository,
    required MidiState midiState,
    int initialChannel = 0,
  }) : _midiRepository = midiRepository,
       _midiState = midiState,
       _midiChannel = initialChannel {
    _midiState.setSelectedChannel(_midiChannel);
    // Forward global MIDI state changes to ViewModel listeners
    _midiState.addListener(_forwardMidiStateChanges);
    _initializeMidiConnection();
  }

  final IMidiRepository _midiRepository;
  final MidiState _midiState;
  final int _midiChannel;

  static final Logger _log = Logger("PlayPageViewModel");

  /// Forwards MIDI state changes to ViewModel listeners.
  void _forwardMidiStateChanges() {
    notifyListeners();
  }

  /// Global MIDI state shared across the application.
  MidiState get midiState => _midiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  /// Initializes the MIDI connection and sets up data handling.
  void _initializeMidiConnection() {
    // Register this ViewModel's MIDI data handler
    _midiRepository.registerDataHandler(_handleMidiData);
  }

  /// Handles incoming MIDI data and updates global state.
  ///
  /// Wraps MIDI parsing and event handling in error recovery to prevent
  /// stale state from parsing/runtime errors.
  void _handleMidiData(Uint8List data) {
    try {
      // Use domain service for MIDI parsing and update application state
      MidiService.handleMidiData(data, (MidiEvent event) {
        try {
          switch (event.type) {
            case MidiEventType.noteOn:
              _midiState.noteOn(event.data1, event.data2, event.channel);
              break;
            case MidiEventType.noteOff:
              _midiState.noteOff(event.data1, event.channel);
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

  /// Plays a virtual note through MIDI output.
  Future<void> playVirtualNote(int note) async {
    await VirtualPianoUtils.playVirtualNote(
      note,
      _midiState,
      (_) {}, // No specific callback needed for play page
    );
  }

  /// Returns the fixed 49-key range (C2 to C6) for consistent layout.
  NoteRange getFixed49KeyRange() {
    return PianoRangeUtils.standard49KeyRange;
  }

  @override
  void dispose() {
    // Remove listener before disposing
    _midiState.removeListener(_forwardMidiStateChanges);
    // Unregister our data handler
    _midiRepository.unregisterDataHandler(_handleMidiData);
    super.dispose();
  }
}
