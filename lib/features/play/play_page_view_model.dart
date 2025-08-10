import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_service.dart";
import "package:piano_fitness/shared/utils/virtual_piano_utils.dart";

/// ViewModel for managing play page state and MIDI operations.
///
/// This class handles all business logic for the main play interface,
/// including MIDI data processing, virtual piano playback, and note conversion.
class PlayPageViewModel extends ChangeNotifier {
  /// Creates a new PlayPageViewModel with optional initial channel.
  PlayPageViewModel({int initialChannel = 0}) : _midiChannel = initialChannel {
    _setupMidiListener();
  }

  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  final int _midiChannel;
  MidiState? _midiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  /// MIDI command instance for low-level operations.
  MidiCommand get midiCommand => _midiCommand;

  /// Sets the MIDI state reference for updating UI state.
  void setMidiState(MidiState midiState) {
    _midiState = midiState;
    _midiState?.setSelectedChannel(_midiChannel);
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

  /// Handles incoming MIDI data and updates state.
  void handleMidiData(Uint8List data) {
    if (_midiState == null) return;

    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          _midiState?.noteOn(event.data1, event.data2, event.channel);
          break;
        case MidiEventType.noteOff:
          _midiState?.noteOff(event.data1, event.channel);
          break;
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          _midiState?.setLastNote(event.displayMessage);
          break;
      }
    });
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
    _midiDataSubscription?.cancel();
    super.dispose();
  }
}
