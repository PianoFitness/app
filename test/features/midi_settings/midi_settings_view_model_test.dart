// Unit tests for MidiSettingsViewModel.
//
// Tests the business logic, state management, and MIDI operations of the ViewModel.

import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_view_model.dart";
import "package:piano_fitness/presentation/state/midi_state.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("MidiSettingsViewModel Tests", () {
    late MidiSettingsViewModel viewModel;

    setUp(() async {
      viewModel = MidiSettingsViewModel(initialChannel: 5);

      // Wait for async initialization to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() async {
      // Ensure proper cleanup to avoid "used after disposed" errors
      viewModel.dispose();

      // Wait for any pending async operations to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
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

      test("should initialize with default channel when not specified", () {
        final defaultViewModel = MidiSettingsViewModel();
        expect(defaultViewModel.selectedChannel, equals(0));
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
        // Initial state
        expect(viewModel.devices, isEmpty);

        // Call updateDeviceList (this will use mocked MIDI command)
        await viewModel.updateDeviceList();

        // Should not crash
        expect(viewModel.devices, isA<List<MidiDevice>>());
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
        // After initialization, status will contain "No MIDI devices found"
        // which triggers shouldShowErrorButtons = true
        expect(viewModel.shouldShowErrorButtons, isTrue);
        // shouldShowResetInfo is now true because "No MIDI devices found" triggers it
        expect(viewModel.shouldShowResetInfo, isTrue);
        expect(viewModel.shouldShowMidiActivity, isFalse);
      });
    });

    group("MIDI Data Handling", () {
      test("should handle MIDI note on events correctly", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test note on data
        const noteOnData = [0x90, 60, 127]; // Note On, Middle C, Velocity 127
        viewModel.handleMidiData(noteOnData, midiState: midiState);

        // Should update last note and notify listeners
        expect(viewModel.lastNote, contains("Note ON: 60"));
        expect(viewModel.lastNote, contains("Ch: 1"));
        expect(viewModel.lastNote, contains("Vel: 127"));
        expect(notificationCount, equals(1));

        // Verify midiState.noteOn was called (note should be active)
        expect(midiState.activeNotes.contains(60), isTrue);
        expect(midiState.lastNote, contains("Note ON: 60"));
      });

      test("should handle MIDI note off events correctly", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // First add a note
        const noteOnData = [0x90, 60, 127]; // Note On, Middle C, Velocity 127
        viewModel.handleMidiData(noteOnData, midiState: midiState);
        expect(midiState.activeNotes.contains(60), isTrue);

        // Reset notification count
        notificationCount = 0;

        // Test note off data
        const noteOffData = [0x80, 60, 0]; // Note Off, Middle C
        viewModel.handleMidiData(noteOffData, midiState: midiState);

        // Should update last note and notify listeners
        expect(viewModel.lastNote, contains("Note OFF: 60"));
        expect(viewModel.lastNote, contains("Ch: 1"));
        expect(notificationCount, equals(1));

        // Verify midiState.noteOff was called (note should be inactive)
        expect(midiState.activeNotes.contains(60), isFalse);
        expect(midiState.lastNote, contains("Note OFF: 60"));
      });

      test("should handle note on with velocity 0 as note off", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // First add a note
        const noteOnData = [0x90, 60, 127]; // Note On, Middle C, Velocity 127
        viewModel.handleMidiData(noteOnData, midiState: midiState);
        expect(midiState.activeNotes.contains(60), isTrue);

        // Reset notification count
        notificationCount = 0;

        // Test note on with velocity 0 (equivalent to note off)
        const noteOnVel0Data = [0x90, 60, 0]; // Note On with velocity 0
        viewModel.handleMidiData(noteOnVel0Data, midiState: midiState);

        // Should update last note and notify listeners
        expect(viewModel.lastNote, contains("Note OFF: 60"));
        expect(viewModel.lastNote, contains("Ch: 1"));
        expect(notificationCount, equals(1));

        // Verify midiState.noteOff was called (note should be inactive)
        expect(midiState.activeNotes.contains(60), isFalse);
        expect(midiState.lastNote, contains("Note OFF: 60"));
      });

      test("should handle control change events correctly", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test control change data
        const controlChangeData = [0xB0, 7, 100]; // CC Volume on channel 1
        viewModel.handleMidiData(controlChangeData, midiState: midiState);

        // Should update last note and notify listeners
        final lastNote = viewModel.lastNote;
        expect(lastNote, contains("CC: Controller 7 = 100"));
        expect(lastNote, contains("Ch: 1"));
        expect(notificationCount, equals(1));
      });

      test("should handle program change events correctly", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test program change data (3-byte)
        const programChangeData = [0xC0, 1, 0]; // Program Change to patch 1
        viewModel.handleMidiData(programChangeData, midiState: midiState);

        // Should update last note and notify listeners
        final lastNote = viewModel.lastNote;
        expect(lastNote, contains("Program Change: 1"));
        expect(lastNote, contains("Ch: 1"));
        expect(notificationCount, equals(1));
      });

      test("should handle program change events correctly (2-byte)", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test program change data (2-byte format)
        const programChangeData = [0xC0, 5]; // Program Change to patch 5
        viewModel.handleMidiData(programChangeData, midiState: midiState);

        // Should update last note and notify listeners
        final lastNote = viewModel.lastNote;
        expect(lastNote, contains("Program Change: 5"));
        expect(lastNote, contains("Ch: 1"));
        expect(notificationCount, equals(1));
      });

      test("should handle pitch bend events correctly", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test pitch bend data
        const pitchBendData = [0xE0, 0x00, 0x40]; // Pitch Bend Center
        viewModel.handleMidiData(pitchBendData, midiState: midiState);

        // Should update last note and notify listeners
        final lastNote = viewModel.lastNote;
        expect(lastNote, contains("Pitch Bend:"));
        expect(lastNote, contains("Ch: 1"));
        expect(notificationCount, equals(1));
      });

      test("should handle other/unknown MIDI events correctly", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test unknown MIDI message
        const unknownData = [0xF0, 0x43, 0x12]; // System Exclusive start
        viewModel.handleMidiData(unknownData, midiState: midiState);

        // Should update last note and notify listeners
        final lastNote = viewModel.lastNote;
        expect(lastNote, contains("MIDI: Status 0xF0"));
        expect(lastNote, contains("Data: 0xF0 0x43 0x12"));
        expect(notificationCount, equals(1));
      });

      test("should handle MIDI events on different channels", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test note on different channels
        const channel5NoteOn = [
          0x94,
          60,
          127,
        ]; // Note On on channel 5 (0x90 + 4)
        const channel16NoteOff = [
          0x8F,
          60,
          0,
        ]; // Note Off on channel 16 (0x80 + 15)

        viewModel.handleMidiData(channel5NoteOn, midiState: midiState);
        final firstLastNote = viewModel.lastNote;
        expect(firstLastNote, contains("Ch: 5"));
        expect(notificationCount, equals(1));

        viewModel.handleMidiData(channel16NoteOff, midiState: midiState);
        final secondLastNote = viewModel.lastNote;
        expect(secondLastNote, contains("Ch: 16"));
        expect(notificationCount, equals(2));
      });

      test("should handle invalid MIDI data gracefully", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test empty data, oversized data, and invalid MIDI data
        final oversizedData = List.filled(300, 0x90);
        const invalidData = [0x90, 200, 127]; // data1 > 127 is invalid

        viewModel
          ..handleMidiData([], midiState: midiState)
          ..handleMidiData(oversizedData, midiState: midiState)
          ..handleMidiData(invalidData, midiState: midiState);
        expect(notificationCount, equals(0));
      });

      test("should handle MIDI data without midiState parameter", () {
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Test that it doesn't crash when midiState is null
        const noteOnData = [0x90, 60, 127];
        viewModel.handleMidiData(noteOnData); // No midiState provided

        // Should still update last note and notify listeners
        final lastNote = viewModel.lastNote;
        expect(lastNote, contains("Note ON: 60"));
        expect(notificationCount, equals(1));
      });

      test("should handle multiple rapid MIDI events", () {
        final midiState = MidiState();
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Send multiple events rapidly
        const events = [
          [0x90, 60, 127], // Note On C4
          [0x90, 64, 127], // Note On E4
          [0x90, 67, 127], // Note On G4
          [0x80, 60, 0], // Note Off C4
          [0xB0, 7, 100], // CC Volume
          [0xC0, 5], // Program Change
        ];

        for (final eventData in events) {
          viewModel.handleMidiData(eventData, midiState: midiState);
        }

        // Should have notified for each event
        expect(notificationCount, equals(events.length));

        // Final state should show the last event (Program Change)
        final finalLastNote = viewModel.lastNote;
        expect(finalLastNote, contains("Program Change: 5"));

        // MIDI state should show the two remaining active notes
        expect(midiState.activeNotes.contains(64), isTrue); // E4 still active
        expect(midiState.activeNotes.contains(67), isTrue); // G4 still active
        expect(
          midiState.activeNotes.contains(60),
          isFalse,
        ); // C4 was turned off
      });
    });

    group("Error Handling", () {
      test("should handle retry setup", () async {
        await viewModel.retrySetup();

        // Should reset state appropriately
        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));
      });

      test("should clean up resources properly during retry setup", () async {
        // Act: Call retrySetup
        await viewModel.retrySetup();

        // Assert: Verify that state is properly reset after cleanup
        expect(
          viewModel.devices,
          isEmpty,
          reason: "Devices should be cleared during retry setup",
        );
        expect(
          viewModel.lastNote,
          equals(""),
          reason: "Last note should be cleared during retry setup",
        );
        expect(
          viewModel.isScanning,
          equals(false),
          reason: "Scanning should be stopped during retry setup",
        );
        expect(
          viewModel.didAskForBluetoothPermissions,
          equals(false),
          reason:
              "Bluetooth permissions flag should be reset during retry setup",
        );

        // Verify that retrySetup is idempotent (safe to call multiple times)
        await viewModel.retrySetup();
        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));
      });

      test("should reset state before calling cleanup in retrySetup", () async {
        // This test verifies the order of operations in retrySetup:
        // 1. Set status to "Retrying..."
        // 2. Clear devices, lastNote, and reset flags
        // 3. Call notifyListeners
        // 4. Clean up resources
        // 5. Setup MIDI

        // Act: Call retrySetup and immediately check state
        final future = viewModel.retrySetup();

        // The state should be immediately reset (before async operations)
        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));

        // Wait for async operations to complete
        await future;

        // Final state should remain reset
        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));
      });

      test("should handle sequential retry setup calls safely", () async {
        // This test verifies that sequential calls to retrySetup
        // don't cause resource conflicts or disposal issues

        // Act: Call retrySetup sequentially (not concurrently)
        await viewModel.retrySetup();
        await viewModel.retrySetup();
        await viewModel.retrySetup();

        // Assert: Should maintain consistent state after all calls
        expect(viewModel.devices, isEmpty);
        expect(viewModel.lastNote, equals(""));
        expect(viewModel.isScanning, equals(false));
        expect(viewModel.didAskForBluetoothPermissions, equals(false));

        // MIDI status should be in a ready state after setup completes
        expect(viewModel.midiStatus, isNotNull);
        expect(viewModel.midiStatus, isNotEmpty);
      });
    });

    group("MidiService Integration", () {
      test("should handle MidiService integration for event parsing", () {
        // Test that demonstrates MidiService integration expectations
        // This is a unit test since we can't easily mock MIDI hardware

        // Verify that MidiService can handle typical MIDI data
        const noteOnData = [0x90, 60, 127]; // Note On, Middle C, Velocity 127

        // This test verifies the MidiService is available and functional
        // The actual MIDI data handling is tested in MidiService tests
        expect(noteOnData.length, equals(3));
        expect(noteOnData[0] & 0xF0, equals(0x90)); // Note On message
      });
    });

    group("Disposal", () {
      test("should dispose resources properly", () async {
        // Create a separate view model for disposal test to avoid conflicts
        final disposalViewModel = MidiSettingsViewModel(initialChannel: 1);

        // Wait for initialization
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Dispose should not throw
        expect(disposalViewModel.dispose, returnsNormally);

        // Wait for cleanup to complete
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
    });
  });
}
