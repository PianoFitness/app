import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/play/play_page_view_model.dart";
import "package:piano_fitness/models/midi_state.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("PlayPageViewModel Tests", () {
    late PlayPageViewModel viewModel;
    late MidiState mockMidiState;

    setUp(() {
      viewModel = PlayPageViewModel(initialChannel: 5);
      mockMidiState = MidiState();
      viewModel.setMidiState(mockMidiState);
    });

    tearDown(() {
      viewModel.dispose();
      mockMidiState.dispose();
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

    test("should correctly convert note positions to MIDI numbers", () {
      // Test C4 (middle C)
      final c4Position = NotePosition(note: Note.C, octave: 4);
      expect(viewModel.convertNotePositionToMidi(c4Position), equals(60));

      // Test C#4
      final cSharp4Position = NotePosition(
        note: Note.C,
        octave: 4,
        accidental: Accidental.Sharp,
      );
      expect(viewModel.convertNotePositionToMidi(cSharp4Position), equals(61));

      // Test Bb4
      final bFlat4Position = NotePosition(
        note: Note.B,
        octave: 4,
        accidental: Accidental.Flat,
      );
      expect(viewModel.convertNotePositionToMidi(bFlat4Position), equals(70));

      // Test A0 (lowest piano key)
      final a0Position = NotePosition(note: Note.A, octave: 0);
      expect(viewModel.convertNotePositionToMidi(a0Position), equals(21));

      // Test C8 (highest piano key)
      final c8Position = NotePosition(note: Note.C, octave: 8);
      expect(viewModel.convertNotePositionToMidi(c8Position), equals(108));
    });

    test("should provide correct 49-key range", () {
      final range = viewModel.getFixed49KeyRange();

      expect(range, isNotNull);
      expect(range, isA<NoteRange>());
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

    group("Note Position to MIDI Conversion Edge Cases", () {
      test("should handle all natural notes correctly", () {
        const octave = 4;
        final expectedMidiNumbers = {
          Note.C: 60, // C4
          Note.D: 62, // D4
          Note.E: 64, // E4
          Note.F: 65, // F4
          Note.G: 67, // G4
          Note.A: 69, // A4
          Note.B: 71, // B4
        };

        for (final entry in expectedMidiNumbers.entries) {
          final position = NotePosition(note: entry.key, octave: octave);
          expect(
            viewModel.convertNotePositionToMidi(position),
            equals(entry.value),
            reason: "Failed for ${entry.key}$octave",
          );
        }
      });

      test("should handle sharp accidentals correctly", () {
        const octave = 4;
        final testCases = [
          (Note.C, 61), // C#4
          (Note.D, 63), // D#4
          (Note.F, 66), // F#4
          (Note.G, 68), // G#4
          (Note.A, 70), // A#4
        ];

        for (final (note, expectedMidi) in testCases) {
          final position = NotePosition(
            note: note,
            octave: octave,
            accidental: Accidental.Sharp,
          );
          expect(
            viewModel.convertNotePositionToMidi(position),
            equals(expectedMidi),
            reason: "Failed for ${note}#$octave",
          );
        }
      });

      test("should handle flat accidentals correctly", () {
        const octave = 4;
        final testCases = [
          (Note.D, 61), // Db4 = C#4
          (Note.E, 63), // Eb4 = D#4
          (Note.G, 66), // Gb4 = F#4
          (Note.A, 68), // Ab4 = G#4
          (Note.B, 70), // Bb4 = A#4
        ];

        for (final (note, expectedMidi) in testCases) {
          final position = NotePosition(
            note: note,
            octave: octave,
            accidental: Accidental.Flat,
          );
          expect(
            viewModel.convertNotePositionToMidi(position),
            equals(expectedMidi),
            reason: "Failed for ${note}b$octave",
          );
        }
      });

      test("should handle different octaves correctly", () {
        final testCases = [
          (0, 12), // C0
          (1, 24), // C1
          (2, 36), // C2
          (3, 48), // C3
          (4, 60), // C4 (middle C)
          (5, 72), // C5
          (6, 84), // C6
          (7, 96), // C7
          (8, 108), // C8
        ];

        for (final (octave, expectedMidi) in testCases) {
          final position = NotePosition(note: Note.C, octave: octave);
          expect(
            viewModel.convertNotePositionToMidi(position),
            equals(expectedMidi),
            reason: "Failed for C$octave",
          );
        }
      });
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
