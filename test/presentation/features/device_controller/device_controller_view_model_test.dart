// Unit tests for DeviceControllerViewModel.
//
// Tests the business logic, state management, and MIDI operations of the ViewModel.

import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/presentation/features/device_controller/device_controller_view_model.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "../../../shared/test_helpers/mock_repositories.dart";
import "../../../shared/test_helpers/mock_repositories.mocks.dart";
import "../../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("DeviceControllerViewModel Tests", () {
    late MidiDevice mockDevice;
    late DeviceControllerViewModel viewModel;
    late MockIMidiRepository mockMidiRepository;
    late MockMidiRepositoryHelper helper;
    late MidiState midiState;

    setUp(() {
      mockDevice = MidiDevice(
        id: "test-device-1",
        name: "Test MIDI Device",
        type: "BLE",
        connected: true,
        inputPorts: [],
        outputPorts: [],
      );
      mockMidiRepository = MockIMidiRepository();
      helper = MockMidiRepositoryHelper(mockMidiRepository);
      when(
        mockMidiRepository.sendControlChange(any, any, any),
      ).thenAnswer((_) async {});
      when(
        mockMidiRepository.sendProgramChange(any, any),
      ).thenAnswer((_) async {});
      when(mockMidiRepository.sendPitchBend(any, any)).thenAnswer((_) async {});
      midiState = MidiState();
      viewModel = DeviceControllerViewModel(
        midiCoordinator: MidiCoordinator(mockMidiRepository),
        device: mockDevice,
        midiRepository: mockMidiRepository,
        midiState: midiState,
      );
    });

    tearDown(() {
      viewModel.dispose();
      midiState.dispose();
    });

    group("Initialization", () {
      test("should initialize with correct default values", () {
        expect(viewModel.device, equals(mockDevice));
        expect(viewModel.selectedChannel, equals(0));
        expect(viewModel.ccController, equals(1));
        expect(viewModel.ccValue, equals(0));
        expect(viewModel.programNumber, equals(0));
        expect(viewModel.pitchBend, equals(0.0));
        expect(
          viewModel.lastReceivedMessage,
          equals("No MIDI data received yet"),
        );
      });

      test("should set up MIDI listener on initialization", () {
        // ViewModel should initialize without errors
        expect(viewModel, isNotNull);
        expect(viewModel.device.id, equals("test-device-1"));
      });
    });

    group("Channel Management", () {
      test("should set selected channel within valid range", () {
        viewModel.setSelectedChannel(5);
        expect(viewModel.selectedChannel, equals(5));

        viewModel.setSelectedChannel(15);
        expect(viewModel.selectedChannel, equals(15));
      });

      test("should not set channel outside valid range", () {
        viewModel.setSelectedChannel(-1);
        expect(viewModel.selectedChannel, equals(0)); // Should remain unchanged

        viewModel.setSelectedChannel(16);
        expect(viewModel.selectedChannel, equals(0)); // Should remain unchanged
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
        expect(viewModel.selectedChannel, equals(15)); // Should remain at max
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
        expect(viewModel.selectedChannel, equals(0)); // Should remain at min
      });
    });

    group("Control Change Management", () {
      test("should set CC controller within valid range", () {
        viewModel.setCCController(64);
        expect(viewModel.ccController, equals(64));

        viewModel.setCCController(127);
        expect(viewModel.ccController, equals(127));
      });

      test("should not set CC controller outside valid range", () {
        final initialController = viewModel.ccController;

        viewModel.setCCController(-1);
        expect(
          viewModel.ccController,
          equals(initialController),
        ); // Should remain unchanged

        viewModel.setCCController(128);
        expect(
          viewModel.ccController,
          equals(initialController),
        ); // Should remain unchanged
      });

      test("should not set CC value outside valid range", () {
        final initialValue = viewModel.ccValue;

        viewModel.setCCValue(-1);
        expect(viewModel.ccValue, equals(initialValue));

        viewModel.setCCValue(128);
        expect(viewModel.ccValue, equals(initialValue));
      });

      test(
        "should send control change via repository when value changes",
        () async {
          viewModel.setCCController(7);
          viewModel.setCCValue(100);
          await untilCalled(
            mockMidiRepository.sendControlChange(any, any, any),
          );
          verify(mockMidiRepository.sendControlChange(7, 100, 0)).called(1);
        },
      );

      test(
        "should not throw and retain cc value when sendControlChange fails",
        () async {
          when(
            mockMidiRepository.sendControlChange(any, any, any),
          ).thenAnswer((_) => Future.error(Exception("send failed")));

          expect(() => viewModel.setCCValue(99), returnsNormally);
          await untilCalled(
            mockMidiRepository.sendControlChange(any, any, any),
          );
          await Future<void>.value(); // allow catch block to execute

          verify(mockMidiRepository.sendControlChange(any, 99, any)).called(1);
          // Optimistic update: new value is retained even after send failure.
          expect(viewModel.ccValue, equals(99));
          expect(viewModel.lastError, isA<Exception>());
        },
      );
    });

    group("Program Change Management", () {
      test("should not set program number outside valid range", () {
        final initialProgram = viewModel.programNumber;

        viewModel.setProgramNumber(-1);
        expect(viewModel.programNumber, equals(initialProgram));

        viewModel.setProgramNumber(128);
        expect(viewModel.programNumber, equals(initialProgram));
      });

      test(
        "should send program change via repository when number changes",
        () async {
          viewModel.setProgramNumber(42);
          await untilCalled(mockMidiRepository.sendProgramChange(any, any));
          verify(mockMidiRepository.sendProgramChange(42, 0)).called(1);
        },
      );

      test(
        "should not throw and retain program number when sendProgramChange fails",
        () async {
          when(
            mockMidiRepository.sendProgramChange(any, any),
          ).thenAnswer((_) => Future.error(Exception("send failed")));

          expect(() => viewModel.setProgramNumber(10), returnsNormally);
          await untilCalled(mockMidiRepository.sendProgramChange(any, any));
          await Future<void>.value(); // allow catch block to execute

          verify(mockMidiRepository.sendProgramChange(10, any)).called(1);
          // Optimistic update: new value is retained even after send failure.
          expect(viewModel.programNumber, equals(10));
          expect(viewModel.lastError, isA<Exception>());
        },
      );
    });

    group("Pitch Bend Management", () {
      test("should not set pitch bend outside valid range", () {
        final initialPitchBend = viewModel.pitchBend;

        viewModel.setPitchBend(-1.1);
        expect(viewModel.pitchBend, equals(initialPitchBend));

        viewModel.setPitchBend(1.1);
        expect(viewModel.pitchBend, equals(initialPitchBend));
      });

      test("should have correct initial pitch bend value", () {
        expect(viewModel.pitchBend, equals(0.0));
      });

      test(
        "should send pitch bend via repository when value changes",
        () async {
          viewModel.setPitchBend(0.5);
          await untilCalled(mockMidiRepository.sendPitchBend(any, any));
          verify(mockMidiRepository.sendPitchBend(0.5, 0)).called(1);
        },
      );

      test("should send pitch bend via repository on reset", () async {
        viewModel
          ..setPitchBend(0.8)
          ..resetPitchBend();
        await untilCalled(mockMidiRepository.sendPitchBend(any, any));
        verify(mockMidiRepository.sendPitchBend(0.0, 0)).called(1);
      });

      test(
        "should not throw and retain pitch bend when sendPitchBend fails",
        () async {
          when(
            mockMidiRepository.sendPitchBend(any, any),
          ).thenAnswer((_) => Future.error(Exception("send failed")));

          expect(() => viewModel.setPitchBend(0.5), returnsNormally);
          await untilCalled(mockMidiRepository.sendPitchBend(any, any));
          await Future<void>.value(); // allow catch block to execute

          verify(mockMidiRepository.sendPitchBend(0.5, any)).called(1);
          // Optimistic update: new value is retained even after send failure.
          expect(viewModel.pitchBend, equals(0.5));
          expect(viewModel.lastError, isA<Exception>());
        },
      );

      test(
        "should not throw and reset pitch bend to 0.0 when sendPitchBend fails on reset",
        () async {
          // Seed a non-zero value with a succeeding stub so setUp mock is used.
          viewModel.setPitchBend(0.8);
          await Future<void>.value();

          when(
            mockMidiRepository.sendPitchBend(any, any),
          ).thenAnswer((_) => Future.error(Exception("send failed")));

          expect(() => viewModel.resetPitchBend(), returnsNormally);
          await untilCalled(mockMidiRepository.sendPitchBend(any, any));
          await Future<void>.value(); // allow catch block to execute

          verify(mockMidiRepository.sendPitchBend(0.0, any)).called(1);
          // Optimistic update: reset value is retained even after send failure.
          expect(viewModel.pitchBend, equals(0.0));
          expect(viewModel.lastError, isA<Exception>());
        },
      );
    });

    group("MIDI Data Processing", () {
      test("should update lastReceivedMessage when CC event received", () {
        helper.simulateMidiData(
          Uint8List.fromList([0xB0, 7, 100]),
        ); // CC#7=100, ch1
        expect(
          viewModel.lastReceivedMessage,
          equals("CC: Controller 7 = 100 (Ch: 1)"),
        );
      });

      test("should update ccValue from incoming CC on selected channel", () {
        viewModel.setCCController(7);
        // Channel 1 in MIDI = channel 0 internally; status 0xB0 = ch 1
        helper.simulateMidiData(Uint8List.fromList([0xB0, 7, 64]));
        expect(viewModel.ccValue, equals(64));
      });

      test("should update pitchBend from incoming pitch bend event", () {
        // [0xE0, 0x00, 0x40] = center (data1=0, data2=64)
        helper.simulateMidiData(Uint8List.fromList([0xE0, 0x00, 0x40]));
        expect(viewModel.pitchBend, closeTo(0.0, 0.01));
      });
    });

    group("State Management", () {
      test("should notify listeners when channel changes", () {
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test setting same value twice should only notify once
        // ignore: cascade_invocations - Need intermediate expect check
        viewModel
          ..setSelectedChannel(5)
          ..setSelectedChannel(5); // Same value, should not notify
        expect(notificationCount, equals(1));

        // Test increment should notify
        viewModel.incrementChannel();
        expect(notificationCount, equals(2));
      });

      test("should notify listeners when CC controller changes", () {
        var notificationCount = 0;
        viewModel
          ..addListener(() => notificationCount++)
          ..setCCController(10);
        expect(notificationCount, equals(1));
      });
    });
  });
}
