import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_midi_command/flutter_midi_command_messages.dart";
import "package:piano_fitness/shared/services/midi_connection_service.dart";
import "package:piano_fitness/shared/services/midi_service.dart";

/// ViewModel for managing device controller state and MIDI operations.
///
/// This class handles all business logic for controlling and monitoring a MIDI device,
/// including sending test messages, managing MIDI parameters, and processing received data.
class DeviceControllerViewModel extends ChangeNotifier {
  /// Creates a new DeviceControllerViewModel for the specified MIDI device.
  DeviceControllerViewModel({required MidiDevice device}) : _device = device {
    _setupMidiListener();
  }

  final MidiDevice _device;
  final MidiConnectionService _midiService = MidiConnectionService();
  Timer? _noteOffTimer;

  int _selectedChannel = 0;
  int _ccController = 1;
  int _ccValue = 0;
  int _programNumber = 0;
  double _pitchBend = 0;
  String _lastReceivedMessage = "No MIDI data received yet";

  /// The MIDI device being controlled.
  MidiDevice get device => _device;

  /// Currently selected MIDI channel (0-15).
  int get selectedChannel => _selectedChannel;

  /// Current CC controller number (0-127).
  int get ccController => _ccController;

  /// Current CC value (0-127).
  int get ccValue => _ccValue;

  /// Current program number (0-127).
  int get programNumber => _programNumber;

  /// Current pitch bend value (-1.0 to 1.0).
  double get pitchBend => _pitchBend;

  /// Last received MIDI message as human-readable string.
  String get lastReceivedMessage => _lastReceivedMessage;

  /// Sets the selected MIDI channel.
  void setSelectedChannel(int channel) {
    if (channel >= 0 && channel <= 15 && channel != _selectedChannel) {
      _selectedChannel = channel;
      notifyListeners();
    }
  }

  /// Increments the selected MIDI channel.
  void incrementChannel() {
    if (_selectedChannel < 15) {
      _selectedChannel++;
      notifyListeners();
    }
  }

  /// Decrements the selected MIDI channel.
  void decrementChannel() {
    if (_selectedChannel > 0) {
      _selectedChannel--;
      notifyListeners();
    }
  }

  /// Sets the CC controller number.
  void setCCController(int controller) {
    if (controller >= 0 && controller <= 127 && controller != _ccController) {
      _ccController = controller;
      notifyListeners();
    }
  }

  /// Sets the CC value and sends the control change message.
  void setCCValue(int value) {
    if (value >= 0 && value <= 127) {
      _ccValue = value;
      notifyListeners();
      sendControlChange();
    }
  }

  /// Sets the program number and sends the program change message.
  void setProgramNumber(int program) {
    if (program >= 0 && program <= 127) {
      _programNumber = program;
      notifyListeners();
      sendProgramChange();
    }
  }

  /// Sets the pitch bend value and sends the pitch bend message.
  void setPitchBend(double bend) {
    if (bend >= -1.0 && bend <= 1.0) {
      _pitchBend = bend;
      notifyListeners();
      sendPitchBend();
    }
  }

  /// Resets pitch bend to center position.
  void resetPitchBend() {
    _pitchBend = 0.0;
    notifyListeners();
    sendPitchBend();
  }

  /// Sends a control change message.
  void sendControlChange() {
    try {
      CCMessage(
        channel: _selectedChannel,
        controller: _ccController,
        value: _ccValue,
      ).send();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error sending CC: $e");
      }
    }
  }

  /// Sends a program change message.
  void sendProgramChange() {
    try {
      PCMessage(channel: _selectedChannel, program: _programNumber).send();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error sending PC: $e");
      }
    }
  }

  /// Sends a pitch bend message.
  void sendPitchBend() {
    try {
      PitchBendMessage(channel: _selectedChannel, bend: _pitchBend).send();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error sending pitch bend: $e");
      }
    }
  }

  /// Sends a note on message for the specified MIDI note.
  void sendNoteOn(int midiNote, {int velocity = 64}) {
    try {
      NoteOnMessage(
        channel: _selectedChannel,
        note: midiNote,
        velocity: velocity,
      ).send();

      _noteOffTimer?.cancel();
      _noteOffTimer = Timer(const Duration(milliseconds: 500), () {
        sendNoteOff(midiNote);
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error sending note: $e");
      }
    }
  }

  /// Sends a note off message for the specified MIDI note.
  void sendNoteOff(int midiNote) {
    try {
      NoteOffMessage(channel: _selectedChannel, note: midiNote).send();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error sending note off: $e");
      }
    }
  }

  void _setupMidiListener() {
    // Connect to the MIDI service and register our data handler
    _midiService
      ..connect()
      ..registerDataHandler(_handleMidiData);
  }

  void _handleMidiData(Uint8List data) {
    // Only process data from our specific device by checking device context
    // In a real implementation, you might want to filter by device ID
    _processMidiData(data);
  }

  void _processMidiData(Uint8List data) {
    MidiService.handleMidiData(data, (MidiEvent event) {
      _lastReceivedMessage = event.displayMessage;

      // Update specific controls based on channel and event type
      if (event.channel - 1 == _selectedChannel) {
        switch (event.type) {
          case MidiEventType.controlChange:
            if (event.data1 == _ccController) {
              _ccValue = event.data2;
            }
          case MidiEventType.programChange:
            _programNumber = event.data1;
          case MidiEventType.pitchBend:
            _pitchBend = MidiService.getPitchBendValue(
              event.data1,
              event.data2,
            );
          case MidiEventType.noteOn:
          case MidiEventType.noteOff:
          case MidiEventType.other:
            // These don't update local control values
            break;
        }
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _midiService.unregisterDataHandler(_handleMidiData);
    _noteOffTimer?.cancel();
    super.dispose();
  }
}
