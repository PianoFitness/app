import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi_device_discovery_service.dart";
import "package:piano_fitness/presentation/features/midi_settings/midi_settings_view_model.dart";

class FakeMidiDeviceDiscoveryService implements IMidiDeviceDiscoveryService {
  List<MidiDevice> mockDevices = [];
  BluetoothStatus currentBluetoothStatus = BluetoothStatus.poweredOn;
  bool isScanning = false;

  @override
  Stream<void> get setupChanged => const Stream.empty();

  @override
  Stream<BluetoothStatus> get bluetoothStatusChanged => const Stream.empty();

  @override
  BluetoothStatus get bluetoothStatus => currentBluetoothStatus;

  @override
  Future<List<MidiDevice>> getDevices() async => mockDevices;

  @override
  Future<void> startBluetooth() async {}

  @override
  Future<void> waitUntilBluetoothIsInitialized() async {}

  @override
  Future<void> startScanning() async {
    isScanning = true;
  }

  @override
  void stopScanning() {
    isScanning = false;
  }

  @override
  Future<void> connectToDevice(MidiDevice device) async {}

  @override
  Future<void> disconnectDevice(MidiDevice device) async {}

  @override
  void dispose() {}
}

void main() {
  group("MidiSettingsViewModel Unit Tests", () {
    late FakeMidiDeviceDiscoveryService fakeService;

    setUp(() {
      fakeService = FakeMidiDeviceDiscoveryService();
    });

    test("initializes channel and validates bounds", () async {
      final viewModel = MidiSettingsViewModel(
        discoveryService: fakeService,
        initialChannel: 5,
      );
      await Future<void>.value();

      expect(viewModel.selectedChannel, equals(5));
      expect(
        () => MidiSettingsViewModel(
          discoveryService: fakeService,
          initialChannel: 20,
        ),
        throwsRangeError,
      );
      viewModel.dispose();
    });

    test("channel increment and decrement stay in bounds", () async {
      final viewModel = MidiSettingsViewModel(discoveryService: fakeService);
      await Future<void>.value();

      viewModel.decrementChannel();
      expect(viewModel.selectedChannel, equals(0));

      viewModel.incrementChannel();
      expect(viewModel.selectedChannel, equals(1));

      viewModel.setSelectedChannel(15);
      viewModel.incrementChannel();
      expect(viewModel.selectedChannel, equals(15));

      viewModel.dispose();
    });

    test("getDeviceIconForType returns correct icons", () async {
      final viewModel = MidiSettingsViewModel(discoveryService: fakeService);
      await Future<void>.value();

      expect(viewModel.getDeviceIconForType("native"), isNotNull);
      expect(viewModel.getDeviceIconForType("BLE"), isNotNull);
      expect(viewModel.getDeviceIconForType("network"), isNotNull);
      expect(viewModel.getDeviceIconForType("unknown"), isNotNull);

      viewModel.dispose();
    });
  });
}
