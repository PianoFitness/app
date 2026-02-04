import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/play/play_page_view_model.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";
import "../../shared/test_helpers/mock_repositories.mocks.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("PlayPageViewModel Tests", () {
    late PlayPageViewModel viewModel;
    late MockIMidiRepository mockMidiRepository;
    late MidiState midiState;

    setUp(() async {
      // Create mock dependencies
      mockMidiRepository = MockIMidiRepository();
      midiState = MidiState();

      // Create ViewModel with injected dependencies
      viewModel = PlayPageViewModel(
        midiRepository: mockMidiRepository,
        midiState: midiState,
        initialChannel: 5,
      );

      // Note: Play page now uses local MIDI state, so we don't set external state

      // No delay needed; tests await specific async calls as required
    });

    tearDown(() async {
      viewModel.dispose();
      midiState.dispose();

      // No delay needed here either
    });

    test("should initialize with correct MIDI channel", () {
      expect(viewModel.midiChannel, equals(5));
      expect(viewModel.midiState.selectedChannel, equals(5));
    });

    test("should handle virtual note playing", () async {
      const testNote = 60;

      // This test verifies the method doesn't throw
      // In a real implementation, this would trigger MIDI output
      await viewModel.playVirtualNote(testNote);

      // Verify the last note message was set in local MIDI state
      expect(
        viewModel.midiState.lastNote.contains("Virtual Note ON: $testNote"),
        isTrue,
      );
    });

    test("should handle virtual note playing with local MIDI state", () async {
      // Create another ViewModel instance with different dependencies for this test
      final testMidiRepository = MockIMidiRepository();
      final testMidiState = MidiState();
      final viewModelWithLocalState = PlayPageViewModel(
        midiRepository: testMidiRepository,
        midiState: testMidiState,
      );

      // Should not crash and should work with local MIDI state
      await expectLater(viewModelWithLocalState.playVirtualNote(60), completes);

      // Verify the note was processed in local state
      expect(
        viewModelWithLocalState.midiState.lastNote.contains("Virtual"),
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
            midiState.setLastNote("");

            // Test MIDI data handling through the domain service
            MidiService.handleMidiData(midiData, (event) {
              switch (event.type) {
                case MidiEventType.noteOn:
                  midiState.noteOn(event.data1, event.data2, event.channel);
                  break;
                case MidiEventType.noteOff:
                  midiState.noteOff(event.data1, event.channel);
                  break;
                case MidiEventType.controlChange:
                case MidiEventType.programChange:
                case MidiEventType.pitchBend:
                case MidiEventType.other:
                  midiState.setLastNote(event.displayMessage);
                  break;
              }
            });

            // Verify that some update occurred (specific content depends on event type)
            expect(midiState.lastNote.isNotEmpty, isTrue);
          }
        },
      );

      test(
        "should filter out clock and active sense messages through service",
        () {
          final clockMessage = Uint8List.fromList([0xF8]); // MIDI Clock
          final activeSenseMessage = Uint8List.fromList([0xFE]); // Active Sense

          midiState.setLastNote("Previous message");

          // Test that MidiService filters these messages
          MidiService.handleMidiData(clockMessage, (event) {
            midiState.setLastNote(event.displayMessage);
          });
          expect(midiState.lastNote, equals("Previous message"));

          MidiService.handleMidiData(activeSenseMessage, (event) {
            midiState.setLastNote(event.displayMessage);
          });
          expect(midiState.lastNote, equals("Previous message"));
        },
      );
    });
  });
}
