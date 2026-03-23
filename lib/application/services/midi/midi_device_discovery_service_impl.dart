import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi_device_discovery_service.dart";

/// Application-layer implementation of [IMidiDeviceDiscoveryService].
///
/// Wraps [midi_cmd.MidiCommand] and translates between library types and
/// domain types, keeping all flutter_midi_command references confined to
/// this class.
class MidiDeviceDiscoveryServiceImpl implements IMidiDeviceDiscoveryService {
  MidiDeviceDiscoveryServiceImpl({midi_cmd.MidiCommand? midiCommand})
    : _midiCommand = midiCommand ?? midi_cmd.MidiCommand();

  final midi_cmd.MidiCommand _midiCommand;

  /// Cache of library devices keyed by device ID, populated on [getDevices].
  final Map<String, midi_cmd.MidiDevice> _deviceCache = {};

  @override
  Stream<void> get setupChanged =>
      _midiCommand.onMidiSetupChanged?.map((_) {}) ?? const Stream.empty();

  @override
  Stream<BluetoothStatus> get bluetoothStatusChanged =>
      _midiCommand.onBluetoothStateChanged.map(_toStatus);

  @override
  BluetoothStatus get bluetoothStatus => _toStatus(_midiCommand.bluetoothState);

  @override
  Future<List<MidiDevice>> getDevices() async {
    final libraryDevices = await _midiCommand.devices ?? [];
    _deviceCache
      ..clear()
      ..addEntries(libraryDevices.map((d) => MapEntry(d.id, d)));
    return libraryDevices.map(_toDomainDevice).toList();
  }

  @override
  Future<void> startBluetoothCentral() => _midiCommand.startBluetoothCentral();

  @override
  Future<void> waitUntilBluetoothIsInitialized() =>
      _midiCommand.waitUntilBluetoothIsInitialized();

  @override
  Future<void> startScanning() =>
      _midiCommand.startScanningForBluetoothDevices();

  @override
  void stopScanning() => _midiCommand.stopScanningForBluetoothDevices();

  @override
  Future<void> connectToDevice(MidiDevice device) async {
    final libraryDevice = _deviceCache[device.id];
    if (libraryDevice != null) {
      await _midiCommand.connectToDevice(libraryDevice);
    }
  }

  @override
  void disconnectDevice(MidiDevice device) {
    final libraryDevice = _deviceCache[device.id];
    if (libraryDevice != null) {
      _midiCommand.disconnectDevice(libraryDevice);
    }
  }

  @override
  void dispose() => _deviceCache.clear();

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  MidiDevice _toDomainDevice(midi_cmd.MidiDevice d) => MidiDevice(
    id: d.id,
    name: d.name,
    type: d.type,
    connected: d.connected,
    inputPorts: d.inputPorts.map((p) => MidiPort(id: p.id)).toList(),
    outputPorts: d.outputPorts.map((p) => MidiPort(id: p.id)).toList(),
  );

  BluetoothStatus _toStatus(midi_cmd.BluetoothState state) {
    switch (state) {
      case midi_cmd.BluetoothState.unsupported:
        return BluetoothStatus.unsupported;
      case midi_cmd.BluetoothState.poweredOff:
        return BluetoothStatus.poweredOff;
      case midi_cmd.BluetoothState.poweredOn:
        return BluetoothStatus.poweredOn;
      case midi_cmd.BluetoothState.resetting:
        return BluetoothStatus.resetting;
      case midi_cmd.BluetoothState.unauthorized:
        return BluetoothStatus.unauthorized;
      case midi_cmd.BluetoothState.unknown:
        return BluetoothStatus.unknown;
      case midi_cmd.BluetoothState.other:
        return BluetoothStatus.other;
    }
  }
}
