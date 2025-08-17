import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/play/play_page_view_model.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_connection_service.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("PlayPageViewModel Tests", () {
    late PlayPageViewModel viewModel;
    late MidiState mockMidiState;

    setUp(() async {
      viewModel = PlayPageViewModel(initialChannel: 5);
      mockMidiState = MidiState();
      // Note: Play page now uses local MIDI state, so we don't set external state

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
      expect(viewModel.localMidiState.selectedChannel, equals(5));
    });

    test("should handle virtual note playing", () async {
      const testNote = 60;

      // This test verifies the method doesn't throw
      // In a real implementation, this would trigger MIDI output
      await viewModel.playVirtualNote(testNote);

      // Verify the last note message was set in local MIDI state
      expect(
        viewModel.localMidiState.lastNote.contains(
          "Virtual Note ON: $testNote",
        ),
        isTrue,
      );
    });

    test("should handle virtual note playing with local MIDI state", () async {
      final viewModelWithLocalState = PlayPageViewModel();

      // Should not crash and should work with local MIDI state
      await expectLater(viewModelWithLocalState.playVirtualNote(60), completes);

      // Verify the note was processed in local state
      expect(
        viewModelWithLocalState.localMidiState.lastNote.contains("Virtual"),
        isTrue,
      );

      viewModelWithLocalState.dispose();
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

            // Test MIDI data handling through the centralized service
            MidiConnectionService.handleStandardMidiData(
              midiData,
              mockMidiState,
            );

            // Verify that some update occurred (specific content depends on event type)
            expect(mockMidiState.lastNote.isNotEmpty, isTrue);
          }
        },
      );

      test(
        "should filter out clock and active sense messages through service",
        () {
          final clockMessage = Uint8List.fromList([0xF8]); // MIDI Clock
          final activeSenseMessage = Uint8List.fromList([0xFE]); // Active Sense

          mockMidiState.setLastNote("Previous message");

          // Test that the service filters these messages
          MidiConnectionService.handleStandardMidiData(
            clockMessage,
            mockMidiState,
          );
          expect(mockMidiState.lastNote, equals("Previous message"));

          MidiConnectionService.handleStandardMidiData(
            activeSenseMessage,
            mockMidiState,
          );
          expect(mockMidiState.lastNote, equals("Previous message"));
        },
      );
    });
  });
}
