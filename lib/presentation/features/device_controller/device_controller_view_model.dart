import "dart:async" show unawaited;

import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/constants/midi_protocol_constants.dart";
import "package:piano_fitness/domain/models/midi_channel.dart";
import "package:piano_fitness/domain/models/midi/midi_event.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// ViewModel for managing device controller state and MIDI operations.
///
/// This class handles all business logic for controlling and monitoring a MIDI device,
/// including sending test messages, managing MIDI parameters, and processing received data.
class DeviceControllerViewModel extends ChangeNotifier {
  /// Creates a new DeviceControllerViewModel with dependency injection.
  DeviceControllerViewModel({
    required MidiCoordinator midiCoordinator,
    required IMidiRepository midiRepository,
    required MidiState midiState,
    required MidiDevice device,
  }) : _midiRepository = midiRepository,
       _midiState = midiState,
       _device = device {
    _subscription = midiCoordinator.subscribe(midiState, _handleMidiEvent);
  }

  static final _log = Logger("DeviceControllerViewModel");

  final IMidiRepository _midiRepository;
  final MidiState _midiState;
  final MidiDevice _device;
  late final MidiSubscription _subscription;

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

  // ---------------------------------------------------------------------------
  // Slider bounds exposed for the view (item 4)
  // ---------------------------------------------------------------------------

  /// Maximum CC controller/value (0–127).
  static const int controllerMax = MidiProtocol.controllerMax;

  /// Maximum program number (0–127).
  static const int programMax = MidiProtocol.programMax;

  /// Minimum normalized pitch bend value (-1.0).
  static const double pitchBendMin = MidiProtocol.pitchBendNormalizedMin;

  // ---------------------------------------------------------------------------
  // Display helpers (item 3)
  // ---------------------------------------------------------------------------

  /// Returns the compact note name for [midiNote] (e.g. "C4", "F#3").
  String getNoteLabel(int midiNote) => NoteUtils.getCompactNoteName(midiNote);

  /// Sets the selected MIDI channel.
  void setSelectedChannel(int channel) {
    if (MidiChannel.isValid(channel) && channel != _selectedChannel) {
      _selectedChannel = channel;
      notifyListeners();
    }
  }

  /// Increments the selected MIDI channel.
  void incrementChannel() {
    if (_selectedChannel < MidiChannel.max) {
      _selectedChannel++;
      notifyListeners();
    }
  }

  /// Decrements the selected MIDI channel.
  void decrementChannel() {
    if (_selectedChannel > MidiChannel.min) {
      _selectedChannel--;
      notifyListeners();
    }
  }

  /// Sets the CC controller number.
  void setCCController(int controller) {
    if (controller >= 0 &&
        controller <= MidiProtocol.controllerMax &&
        controller != _ccController) {
      _ccController = controller;
      notifyListeners();
    }
  }

  /// Sets the CC value and sends the control change message.
  void setCCValue(int value) {
    if (value >= 0 && value <= MidiProtocol.controllerMax) {
      _ccValue = value;
      notifyListeners();
      unawaited(_sendControlChange());
    }
  }

  /// Sets the program number and sends the program change message.
  void setProgramNumber(int program) {
    if (program >= 0 && program <= MidiProtocol.programMax) {
      _programNumber = program;
      notifyListeners();
      unawaited(_sendProgramChange());
    }
  }

  /// Sets the pitch bend value and sends the pitch bend message.
  void setPitchBend(double bend) {
    if (bend >= MidiProtocol.pitchBendNormalizedMin &&
        bend <= MidiProtocol.pitchBendNormalizedMax) {
      _pitchBend = bend;
      notifyListeners();
      unawaited(_sendPitchBend());
    }
  }

  /// Resets pitch bend to center position.
  void resetPitchBend() {
    _pitchBend = 0.0;
    notifyListeners();
    unawaited(_sendPitchBend());
  }

  Future<void> _sendControlChange() async {
    try {
      await _midiRepository.sendControlChange(
        _ccController,
        _ccValue,
        _selectedChannel,
      );
    } on Exception catch (e) {
      _log.warning("Error sending CC: $e");
    }
  }

  Future<void> _sendProgramChange() async {
    try {
      await _midiRepository.sendProgramChange(_programNumber, _selectedChannel);
    } on Exception catch (e) {
      _log.warning("Error sending PC: $e");
    }
  }

  Future<void> _sendPitchBend() async {
    try {
      await _midiRepository.sendPitchBend(_pitchBend, _selectedChannel);
    } on Exception catch (e) {
      _log.warning("Error sending pitch bend: $e");
    }
  }

  /// Sends a note on message for the specified MIDI note.
  Future<void> sendNoteOn(
    int midiNote, {
    int velocity = MidiProtocol.defaultVelocity,
  }) async {
    try {
      await _midiRepository.sendNoteOn(midiNote, velocity, _selectedChannel);
    } on Exception catch (e) {
      _log.warning("Error sending note: $e");
    }
  }

  /// Sends a note off message for the specified MIDI note.
  Future<void> sendNoteOff(int midiNote) async {
    try {
      await _midiRepository.sendNoteOff(midiNote, _selectedChannel);
    } on Exception catch (e) {
      _log.warning("Error sending note off: $e");
    }
  }

  void _handleMidiEvent(MidiEvent event) {
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
    _processMidiEvent(event);
  }

  void _processMidiEvent(MidiEvent event) {
    _lastReceivedMessage = event.displayMessage;

    // Update specific controls based on channel and event type
    if (event.channel - 1 == _selectedChannel) {
      switch (event.type) {
        case MidiEventType.controlChange:
          if (event.data1 == _ccController) {
            _ccValue = event.data2;
          }
          break;
        case MidiEventType.programChange:
          _programNumber = event.data1;
          break;
        case MidiEventType.pitchBend:
          _pitchBend = event.pitchBendValue;
          break;
        case MidiEventType.noteOn:
        case MidiEventType.noteOff:
        case MidiEventType.other:
          // These don't update local control values
          break;
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
