import "dart:async";
import "dart:typed_data";

/// Repository interface for MIDI operations
///
/// Abstracts MIDI device communication, connection management,
/// and message handling. Implementations should handle platform-specific
/// MIDI plugin integration.
///
/// The repository provides raw MIDI data via [midiDataStream]. MIDI parsing
/// and state management are handled in the domain and application layers
/// respectively to maintain separation of concerns.
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

  /// Get currently connected device
  ///
  /// **Note**: This is currently unimplemented and always returns null.
  /// Device connection state is tracked at the service layer.
  /// This will be enhanced in Phase 4 to expose connected device information.
  ///
  /// TODO(Phase 4): Implement device tracking in MidiConnectionService
  MidiDevice? get connectedDevice;

  /// Dispose of resources (close streams, cleanup handlers)
  void dispose();
}

/// MIDI device information
class MidiDevice {
  MidiDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.connected,
    required this.inputPorts,
    required this.outputPorts,
  });

  final String id;
  final String name;
  final String type;
  final bool connected;
  final List<MidiPort> inputPorts;
  final List<MidiPort> outputPorts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiDevice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          connected == other.connected;

  @override
  int get hashCode => Object.hash(id, name, type, connected);
}

/// MIDI port information
class MidiPort {
  MidiPort({required this.id});

  final int id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiPort && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
