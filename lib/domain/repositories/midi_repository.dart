import "dart:async";
import "dart:typed_data";
import "package:piano_fitness/application/state/midi_state.dart";

/// Repository interface for MIDI operations
///
/// Abstracts MIDI device communication, connection management,
/// and message handling. Implementations should handle platform-specific
/// MIDI plugin integration.
abstract class IMidiRepository {
  /// Stream of raw MIDI data bytes from connected devices
  Stream<Uint8List> get midiDataStream;

  /// List available MIDI devices for connection
  Future<List<MidiDevice>> listDevices();

  /// Connect to a MIDI device
  Future<void> connectToDevice(String deviceId);

  /// Disconnect from current device
  Future<void> disconnect();

  /// Send raw MIDI message bytes
  Future<void> sendData(Uint8List data);

  /// Send structured MIDI note-on message
  Future<void> sendNoteOn(int note, int velocity, int channel);

  /// Send structured MIDI note-off message
  Future<void> sendNoteOff(int note, int channel);

  /// Register handler for incoming MIDI data
  void registerDataHandler(void Function(Uint8List) handler);

  /// Unregister MIDI data handler
  void unregisterDataHandler(void Function(Uint8List) handler);

  /// Process MIDI data and update state
  ///
  /// Parses raw MIDI bytes and updates the provided MidiState with
  /// note on/off events and other MIDI messages. This centralizes
  /// MIDI data processing logic in the repository layer.
  void processMidiData(Uint8List data, MidiState midiState);

  /// Get currently connected device
  MidiDevice? get connectedDevice;

  /// Dispose of resources (close streams, cleanup handlers)
  void dispose();
}

/// MIDI device information
class MidiDevice {
  MidiDevice({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final String type;
}
