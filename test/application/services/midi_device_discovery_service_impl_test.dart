import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/services/midi/midi_device_discovery_service_impl.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi_device_discovery_service.dart";

class FakeMidiCommandDevice implements midi_cmd.MidiDevice {
  FakeMidiCommandDevice(this.id, this.name, this.type, this.connected);

  @override
  final String id;
  @override
  final String name;
  @override
  final midi_cmd.MidiDeviceType type;
  @override
  final bool connected;

  @override
  List<midi_cmd.MidiPort> get inputPorts => [];

  @override
  List<midi_cmd.MidiPort> get outputPorts => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMidiCommand implements midi_cmd.MidiCommand {
  midi_cmd.BluetoothState currentBluetoothState =
      midi_cmd.BluetoothState.poweredOn;
  List<midi_cmd.MidiDevice>? mockDevices;
  midi_cmd.MidiDevice? lastConnectedDevice;
  midi_cmd.MidiDevice? lastDisconnectedDevice;

  @override
  midi_cmd.BluetoothState get bluetoothState => currentBluetoothState;

  @override
  Future<List<midi_cmd.MidiDevice>?> get devices async => mockDevices;

  @override
  Future<void> connectToDevice(
    midi_cmd.MidiDevice device, {
    Duration? awaitConnectionTimeout,
  }) async {
    lastConnectedDevice = device;
  }

  @override
  void disconnectDevice(midi_cmd.MidiDevice device) {
    lastDisconnectedDevice = device;
  }

  @override
  Future<void> startBluetooth() async {}

  @override
  Future<void> waitUntilBluetoothIsInitialized() async {}

  @override
  Future<void> startScanningForBluetoothDevices() async {}

  @override
  void stopScanningForBluetoothDevices() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group("MidiDeviceDiscoveryServiceImpl Unit Tests", () {
    late FakeMidiCommand fakeCommand;
    late MidiDeviceDiscoveryServiceImpl service;

    setUp(() {
      fakeCommand = FakeMidiCommand();
      service = MidiDeviceDiscoveryServiceImpl(midiCommand: fakeCommand);
    });

    tearDown(() {
      service.dispose();
    });

    test("bluetoothStatus maps status correctly", () {
      fakeCommand.currentBluetoothState = midi_cmd.BluetoothState.unsupported;
      expect(service.bluetoothStatus, equals(BluetoothStatus.unsupported));

      fakeCommand.currentBluetoothState = midi_cmd.BluetoothState.poweredOff;
      expect(service.bluetoothStatus, equals(BluetoothStatus.poweredOff));

      fakeCommand.currentBluetoothState = midi_cmd.BluetoothState.poweredOn;
      expect(service.bluetoothStatus, equals(BluetoothStatus.poweredOn));
    });

    test(
      "getDevices populates deviceCache and returns domain models",
      () async {
        fakeCommand.mockDevices = [
          FakeMidiCommandDevice(
            "dev1",
            "Test Keyboard",
            midi_cmd.MidiDeviceType.values.first,
            true,
          ),
        ];

        final devices = await service.getDevices();

        expect(devices.length, equals(1));
        expect(devices.first.id, equals("dev1"));
        expect(devices.first.name, equals("Test Keyboard"));
        expect(
          devices.first.type,
          equals(midi_cmd.MidiDeviceType.values.first.name),
        );
        expect(devices.first.connected, isTrue);
      },
    );

    test("connectToDevice throws StateError if device not in cache", () async {
      final dev = MidiDevice(
        id: "uncached",
        name: "Unknown Keyboard",
        type: "bluetooth",
        connected: false,
        inputPorts: [],
        outputPorts: [],
      );

      expect(() => service.connectToDevice(dev), throwsStateError);
    });

    test("disconnectDevice throws StateError if device not in cache", () async {
      final dev = MidiDevice(
        id: "uncached",
        name: "Unknown Keyboard",
        type: "bluetooth",
        connected: false,
        inputPorts: [],
        outputPorts: [],
      );

      expect(() => service.disconnectDevice(dev), throwsStateError);
    });

    test("connectToDevice and disconnectDevice succeed when cached", () async {
      fakeCommand.mockDevices = [
        FakeMidiCommandDevice(
          "dev1",
          "Test Keyboard",
          midi_cmd.MidiDeviceType.values.last,
          false,
        ),
      ];

      final devices = await service.getDevices();
      expect(devices, isNotEmpty);

      await service.connectToDevice(devices.first);
      expect(fakeCommand.lastConnectedDevice?.id, equals("dev1"));

      await service.disconnectDevice(devices.first);
      expect(fakeCommand.lastDisconnectedDevice?.id, equals("dev1"));
    });

    test("startBluetooth, startScanning, stopScanning pass through", () async {
      expect(service.startBluetooth(), completes);
      expect(service.waitUntilBluetoothIsInitialized(), completes);
      expect(service.startScanning(), completes);
      service.stopScanning();
    });
  });
}
