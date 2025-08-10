import "dart:typed_data";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/play/play_page_view_model.dart";
import "package:piano_fitness/shared/models/midi_state.dart";

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock the flutter_midi_command method channel to prevent MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(
            "plugins.invisiblewrench.com/flutter_midi_command",
          ),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case "sendData":
                // Mock successful MIDI data sending
                return true;
              case "getDevices":
                return <Map<String, dynamic>>[];
              case "devices":
                return <Map<String, dynamic>>[];
              case "connectToDevice":
                return true;
              case "disconnectDevice":
                return true;
              case "startScanning":
                return true;
              case "stopScanning":
                return true;
              case "startScanningForBluetoothDevices":
                return true;
              case "stopScanningForBluetoothDevices":
                return true;
              default:
                return null;
            }
          },
        );
  });

  group("PlayPageViewModel Tests", () {
    late PlayPageViewModel viewModel;
    late MidiState mockMidiState;

    setUp(() async {
      viewModel = PlayPageViewModel(initialChannel: 5);
      mockMidiState = MidiState();
      viewModel.setMidiState(mockMidiState);

      // Wait for any async initialization to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    tearDown(() async {
      viewModel.dispose();
      mockMidiState.dispose();

      // Wait for any pending async operations to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    test("should initialize with correct MIDI channel", () {
      expect(viewModel.midiChannel, equals(5));
      expect(mockMidiState.selectedChannel, equals(5));
    });

    test("should handle MIDI data and update state for note on events", () {
      final midiData = Uint8List.fromList([0x90, 60, 100]);

      viewModel.handleMidiData(midiData);

      expect(mockMidiState.activeNotes.contains(60), isTrue);
      expect(mockMidiState.lastNote, "Note ON: 60 (Ch: 1, Vel: 100)");
      expect(mockMidiState.hasRecentActivity, isTrue);
    });

    test("should handle MIDI data and update state for note off events", () {
      // First add a note
      mockMidiState.noteOn(60, 100, 1);
      expect(mockMidiState.activeNotes.contains(60), isTrue);

      final midiData = Uint8List.fromList([0x80, 60, 0]);

      viewModel.handleMidiData(midiData);

      expect(mockMidiState.activeNotes.contains(60), isFalse);
      expect(mockMidiState.lastNote, "Note OFF: 60 (Ch: 1)");
    });

    test(
      "should handle MIDI data and update state for control change events",
      () {
        final midiData = Uint8List.fromList([0xB0, 7, 100]);

        viewModel.handleMidiData(midiData);

        expect(mockMidiState.lastNote, "CC: Controller 7 = 100 (Ch: 1)");
        expect(mockMidiState.hasRecentActivity, isTrue);
      },
    );

    test(
      "should handle MIDI data and update state for program change events",
      () {
        final midiData = Uint8List.fromList([0xC0, 42]);

        viewModel.handleMidiData(midiData);

        expect(mockMidiState.lastNote, "Program Change: 42 (Ch: 1)");
      },
    );

    test("should handle MIDI data and update state for pitch bend events", () {
      final midiData = Uint8List.fromList([0xE0, 0x00, 0x60]);

      viewModel.handleMidiData(midiData);

      expect(mockMidiState.lastNote.contains("Pitch Bend"), isTrue);
    });

    test("should handle virtual note playing", () async {
      const testNote = 60;

      // This test verifies the method doesn't throw
      // In a real implementation, this would trigger MIDI output
      await viewModel.playVirtualNote(testNote);

      // Verify the last note message was set (if MIDI state is available)
      expect(
        mockMidiState.lastNote.contains("Virtual Note ON: $testNote"),
        isTrue,
      );
    });

    test("should handle cases with no MIDI state set", () {
      final viewModelWithoutState = PlayPageViewModel();
      final midiData = Uint8List.fromList([0x90, 60, 100]);

      // Should not crash when no MIDI state is set
      expect(
        () => viewModelWithoutState.handleMidiData(midiData),
        returnsNormally,
      );

      viewModelWithoutState.dispose();
    });

    test("should provide access to MIDI command instance", () {
      expect(viewModel.midiCommand, isNotNull);
    });

    group("MIDI Data Processing Integration", () {
      test(
        "should integrate correctly with MidiService for various event types",
        () {
          final testCases = [
            // Note On
            Uint8List.fromList([0x90, 64, 80]),
            // Note Off
            Uint8List.fromList([0x80, 64, 0]),
            // Control Change
            Uint8List.fromList([0xB0, 1, 127]),
            // Program Change
            Uint8List.fromList([0xC0, 42]),
            // Pitch Bend
            Uint8List.fromList([0xE0, 0x00, 0x40]),
          ];

          for (final midiData in testCases) {
            // Clear previous state
            mockMidiState.setLastNote("");

            viewModel.handleMidiData(midiData);

            // Verify that some update occurred (specific content depends on event type)
            expect(mockMidiState.lastNote.isNotEmpty, isTrue);
          }
        },
      );

      test("should filter out clock and active sense messages", () {
        final clockMessage = Uint8List.fromList([0xF8]); // MIDI Clock
        final activeSenseMessage = Uint8List.fromList([0xFE]); // Active Sense

        mockMidiState.setLastNote("Previous message");

        viewModel.handleMidiData(clockMessage);
        expect(mockMidiState.lastNote, equals("Previous message"));

        viewModel.handleMidiData(activeSenseMessage);
        expect(mockMidiState.lastNote, equals("Previous message"));
      });
    });
  });
}
