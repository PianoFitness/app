import "dart:async";
import "package:flutter/foundation.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_connection_service.dart";
import "package:piano_fitness/shared/utils/virtual_piano_utils.dart";

/// ViewModel for managing play page state and MIDI operations.
///
/// This class handles all business logic for the main play interface,
/// focusing on UI coordination while delegating MIDI operations to shared services.
class PlayPageViewModel extends ChangeNotifier {
  /// Creates a new PlayPageViewModel with optional initial channel.
  PlayPageViewModel({int initialChannel = 0}) : _midiChannel = initialChannel {
    _initializeMidiConnection();
  }

  final MidiConnectionService _midiConnectionService = MidiConnectionService();
  final int _midiChannel;
  MidiState? _midiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  /// Sets the MIDI state reference for updating UI state.
  void setMidiState(MidiState midiState) {
    _midiState = midiState;
    _midiState?.setSelectedChannel(_midiChannel);
  }

  /// Initializes the MIDI connection and sets up data handling.
  void _initializeMidiConnection() {
    // Register this ViewModel's MIDI data handler
    _midiConnectionService.registerDataHandler(_handleMidiData);

    // Start the MIDI connection if not already connected
    _midiConnectionService.connect();
  }

  /// Handles incoming MIDI data and updates state.
  void _handleMidiData(Uint8List data) {
    if (_midiState == null) return;

    MidiConnectionService.handleStandardMidiData(data, _midiState!);
  }

  /// Plays a virtual note through MIDI output.
  Future<void> playVirtualNote(int note) async {
    if (_midiState == null) return;

    await VirtualPianoUtils.playVirtualNote(
      note,
      _midiState!,
      (_) {}, // No specific callback needed for play page
    );
  }

  @override
  void dispose() {
    // Unregister our data handler
    _midiConnectionService.unregisterDataHandler(_handleMidiData);
    super.dispose();
  }
}
