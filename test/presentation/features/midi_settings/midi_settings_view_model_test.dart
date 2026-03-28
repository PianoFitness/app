// Unit tests for MidiSettingsViewModel.
//
// Tests the business logic, state management, and MIDI operations of the ViewModel.

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/presentation/features/midi_settings/midi_settings_view_model.dart";
import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("MidiSettingsViewModel Tests", () {
    late MidiSettingsViewModel viewModel;
    late MockIMidiDeviceDiscoveryService mockService;

    setUp(() async {
      mockService = MockIMidiDeviceDiscoveryService();

      // Stub streams to return empty streams (no events)
      when(mockService.setupChanged).thenAnswer((_) => const Stream.empty());
      when(
        mockService.bluetoothStatusChanged,
      ).thenAnswer((_) => const Stream.empty());

      // Stub getDevices to return empty list
      when(mockService.getDevices()).thenAnswer((_) async => []);

      viewModel = MidiSettingsViewModel(
        discoveryService: mockService,
        initialChannel: 5,
      );

      // Drain microtask queue through nested awaits in _setupMidi
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() {
      viewModel.dispose();
    });

    group("Initialization", () {
      test("should initialize with correct default values", () {
        expect(viewModel.selectedChannel, equals(5));
        expect(viewModel.devices, isEmpty);
        expect(viewModel.midiStatus, contains("MIDI"));
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));
      });

      test(
        "should initialize with default channel when not specified",
        () async {
          final defaultViewModel = MidiSettingsViewModel(
            discoveryService: mockService,
          );
          expect(defaultViewModel.selectedChannel, equals(0));
          await Future<void>.delayed(Duration.zero);
          defaultViewModel.dispose();
        },
      );

      test("should throw RangeError for invalid initialChannel below 0", () {
        expect(
          () => MidiSettingsViewModel(
            discoveryService: mockService,
            initialChannel: -1,
          ),
          throwsA(
            isA<RangeError>().having(
              (e) => e.toString(),
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("should throw RangeError for invalid initialChannel above 15", () {
        expect(
          () => MidiSettingsViewModel(
            discoveryService: mockService,
            initialChannel: 16,
          ),
          throwsA(
            isA<RangeError>().having(
              (e) => e.toString(),
              "message",
              contains("MIDI channel must be between 0 and 15"),
            ),
          ),
        );
      });

      test("should accept valid initialChannel at boundaries", () async {
        final vmZero = MidiSettingsViewModel(discoveryService: mockService);
        expect(vmZero.selectedChannel, equals(0));
        await Future<void>.delayed(Duration.zero);
        vmZero.dispose();

        final vmFifteen = MidiSettingsViewModel(
          discoveryService: mockService,
          initialChannel: 15,
        );
        expect(vmFifteen.selectedChannel, equals(15));
        await Future<void>.delayed(Duration.zero);
        vmFifteen.dispose();
      });
    });

    group("Channel Management", () {
      test("should set selected channel within valid range", () {
        viewModel.setSelectedChannel(10);
        expect(viewModel.selectedChannel, equals(10));

        viewModel.setSelectedChannel(0);
        expect(viewModel.selectedChannel, equals(0));

        viewModel.setSelectedChannel(15);
        expect(viewModel.selectedChannel, equals(15));
      });

      test("should not set channel outside valid range", () {
        final initialChannel = viewModel.selectedChannel;

        viewModel.setSelectedChannel(-1);
        expect(viewModel.selectedChannel, equals(initialChannel));

        viewModel.setSelectedChannel(16);
        expect(viewModel.selectedChannel, equals(initialChannel));
      });

      test("should increment channel correctly", () {
        viewModel
          ..setSelectedChannel(5)
          ..incrementChannel();
        expect(viewModel.selectedChannel, equals(6));
      });

      test("should not increment channel beyond maximum", () {
        viewModel
          ..setSelectedChannel(15)
          ..incrementChannel();
        expect(viewModel.selectedChannel, equals(15));
      });

      test("should decrement channel correctly", () {
        viewModel
          ..setSelectedChannel(5)
          ..decrementChannel();
        expect(viewModel.selectedChannel, equals(4));
      });

      test("should not decrement channel below minimum", () {
        viewModel
          ..setSelectedChannel(0)
          ..decrementChannel();
        expect(viewModel.selectedChannel, equals(0));
      });
    });

    group("Device Management", () {
      test("should update device list", () async {
        expect(viewModel.devices, isEmpty);

        await viewModel.updateDeviceList();

        expect(viewModel.devices, isA<List<MidiDevice>>());
      });

      test("should reflect devices returned by service", () async {
        final fakeDevices = [
          MidiDevice(
            id: "dev-1",
            name: "Test Keyboard",
            type: "BLE",
            connected: false,
            inputPorts: [],
            outputPorts: [],
          ),
        ];
        when(mockService.getDevices()).thenAnswer((_) async => fakeDevices);

        await viewModel.updateDeviceList();

        expect(viewModel.devices.length, equals(1));
        expect(viewModel.devices.first.name, equals("Test Keyboard"));
      });

      test("should provide device icon for different types", () {
        expect(viewModel.getDeviceIconForType("BLE"), equals(Icons.bluetooth));
        expect(viewModel.getDeviceIconForType("native"), equals(Icons.devices));
        expect(
          viewModel.getDeviceIconForType("network"),
          equals(Icons.language),
        );
        expect(
          viewModel.getDeviceIconForType("unknown"),
          equals(Icons.device_unknown),
        );
      });
    });

    group("State Management", () {
      test("should notify listeners when channel changes", () {
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // ignore: cascade_invocations - Need intermediate expect check
        viewModel
          ..setSelectedChannel(10)
          ..setSelectedChannel(10); // Same value should not notify
        expect(notificationCount, equals(1));

        viewModel
          ..incrementChannel()
          ..decrementChannel();
        expect(notificationCount, equals(3));
      });

      test("should provide state flags correctly", () {
        // After initialization with empty device list, status contains
        // "No MIDI devices found" which triggers shouldShowErrorButtons
        expect(viewModel.shouldShowErrorButtons, isTrue);
        expect(viewModel.shouldShowResetInfo, isTrue);
        expect(viewModel.shouldShowMidiActivity, isFalse);
      });
    });

    group("Error Handling", () {
      test("should handle retry setup", () async {
        await viewModel.retrySetup();

        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));
      });

      test("should clean up resources properly during retry setup", () async {
        await viewModel.retrySetup();

        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));
      });

      test("should reset state before calling cleanup in retrySetup", () async {
        final future = viewModel.retrySetup();

        // State is synchronously reset before async operations
        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));

        await future;

        expect(viewModel.devices, isEmpty);
        expect(viewModel.isScanning, equals(false));
      });

      test("should handle sequential retry setup calls safely", () async {
        await viewModel.retrySetup();
        await viewModel.retrySetup();
        await viewModel.retrySetup();

        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.midiStatus, isNotEmpty);
      });
    });

    group("Disposal", () {
      test("should dispose resources properly", () async {
        final disposalViewModel = MidiSettingsViewModel(
          discoveryService: mockService,
          initialChannel: 1,
        );
        await Future<void>.delayed(Duration.zero);
        expect(disposalViewModel.dispose, returnsNormally);
      });
    });
  });
}
