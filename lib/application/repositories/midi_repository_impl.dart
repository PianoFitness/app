import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";

/// Implementation of IMidiRepository wrapping MidiConnectionService
///
/// Wraps the singleton MidiConnectionService to provide repository interface.
/// MidiConnectionService maintains its singleton pattern internally.
class MidiRepositoryImpl implements IMidiRepository {
  MidiRepositoryImpl()
    : _service = MidiConnectionService(),
      _midiCommand = midi_cmd.MidiCommand();

  final MidiConnectionService _service;
  final midi_cmd.MidiCommand _midiCommand;
  final StreamController<Uint8List> _midiDataController =
      StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List> get midiDataStream => _midiDataController.stream;

  @override
  Future<List<MidiDevice>> listDevices() async {
    try {
      final devices = await _midiCommand.devices;
      return devices
              ?.map(
                (device) => MidiDevice(
                  id: device.id,
                  name: device.name,
                  type: device.type,
                ),
              )
              .toList() ??
          [];
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error listing MIDI devices: $e");
        print(stackTrace);
      }
      return [];
    }
  }

  @override
  Future<void> connectToDevice(String deviceId) async {
    try {
      final devices = await _midiCommand.devices;
      final device = devices?.firstWhere((d) => d.id == deviceId);
      if (device != null) {
        await _midiCommand.connectToDevice(device);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error connecting to MIDI device: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _service.disconnect();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error disconnecting MIDI device: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> sendData(Uint8List data) async {
    try {
      _midiCommand.sendData(data);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error sending MIDI data: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> sendNoteOn(int note, int velocity, int channel) async {
    final data = Uint8List.fromList([0x90 + channel, note, velocity]);
    await sendData(data);
  }

  @override
  Future<void> sendNoteOff(int note, int channel) async {
    final data = Uint8List.fromList([0x80 + channel, note, 0]);
    await sendData(data);
  }

  @override
  void registerDataHandler(void Function(Uint8List) handler) {
    _service.registerDataHandler(handler);
  }

  @override
  void unregisterDataHandler(void Function(Uint8List) handler) {
    _service.unregisterDataHandler(handler);
  }

  @override
  void processMidiData(Uint8List data, MidiState midiState) {
    MidiConnectionService.handleStandardMidiData(data, midiState);
  }

  @override
  MidiDevice? get connectedDevice {
    // MidiConnectionService doesn't expose connected device currently
    // This will need to be enhanced in Phase 4
    return null;
  }

  @override
  void dispose() {
    // Clean up MIDI command resources
    try {
      // Disconnect any active connections through the cached _midiCommand
      _service.disconnect().catchError((Object e) {
        if (kDebugMode) {
          print("Error disconnecting during disposal: $e");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error during MIDI cleanup: $e");
      }
    }

    // Close the stream controller
    _midiDataController.close();
  }
}
