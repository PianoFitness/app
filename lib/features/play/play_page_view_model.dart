import "dart:async";
import "package:flutter/foundation.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_connection_service.dart";
import "package:piano_fitness/shared/utils/virtual_piano_utils.dart";

/// ViewModel for managing play page state and MIDI operations.
///
/// This class handles all business logic for the main play interface,
/// managing its own local MIDI state for note tracking and visual feedback
/// while using shared services for device connections.
class PlayPageViewModel extends ChangeNotifier {
  /// Creates a new PlayPageViewModel with optional initial channel.
  PlayPageViewModel({int initialChannel = 0}) : _midiChannel = initialChannel {
    _localMidiState = MidiState();
    _localMidiState.setSelectedChannel(_midiChannel);
    _initializeMidiConnection();
  }

  final MidiConnectionService _midiConnectionService = MidiConnectionService();
  final int _midiChannel;
  late final MidiState _localMidiState;

  /// Local MIDI state for this play page instance.
  MidiState get localMidiState => _localMidiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  /// Sets the MIDI state reference for updating UI state.
  ///
  /// Note: The Play page now uses its own local MIDI state, so this method
  /// is maintained for compatibility but no longer needed.
  @Deprecated(
    "Play page now uses local MIDI state. Use localMidiState instead.",
  )
  void setMidiState(MidiState midiState) {
    // No-op: We use local state now
  }

  /// Initializes the MIDI connection and sets up data handling.
  void _initializeMidiConnection() {
    // Register this ViewModel's MIDI data handler and start connection
    _midiConnectionService
      ..registerDataHandler(_handleMidiData)
      ..connect();
  }

  /// Handles incoming MIDI data and updates local state.
  void _handleMidiData(Uint8List data) {
    MidiConnectionService.handleStandardMidiData(data, _localMidiState);
  }

  /// Plays a virtual note through MIDI output.
  Future<void> playVirtualNote(int note) async {
    await VirtualPianoUtils.playVirtualNote(
      note,
      _localMidiState,
      (_) {}, // No specific callback needed for play page
    );
  }

  @override
  void dispose() {
    // Unregister our data handler
    _midiConnectionService.unregisterDataHandler(_handleMidiData);
    // Dispose local MIDI state
    _localMidiState.dispose();
    super.dispose();
  }
}
