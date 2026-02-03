import "dart:async";
import "package:flutter/foundation.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/virtual_piano_utils.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";

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
  void _handleMidiData(Uint8List data) {
    _midiRepository.processMidiData(data, _midiState);
  }

  /// Plays a virtual note through MIDI output.
  Future<void> playVirtualNote(int note) async {
    await VirtualPianoUtils.playVirtualNote(
      note,
      _midiState,
      (_) {}, // No specific callback needed for play page
    );
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
