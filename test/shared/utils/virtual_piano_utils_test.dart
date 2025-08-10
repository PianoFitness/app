import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/utils/virtual_piano_utils.dart";
import "../midi_mocks.dart";

void main() {
  group("VirtualPianoUtils Unit Tests", () {
    late MidiState midiState;

    setUpAll(MidiMocks.setUp);

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      VirtualPianoUtils.dispose();
      midiState.dispose();
    });

    tearDownAll(MidiMocks.tearDown);

    group("dispose method tests", () {
      test("should complete without throwing errors", () async {
        // Play some notes to create active timers
        await VirtualPianoUtils.playVirtualNote(60, midiState, (note) {});
        await VirtualPianoUtils.playVirtualNote(64, midiState, (note) {});

        // Call dispose - should not throw
        expect(VirtualPianoUtils.dispose, returnsNormally);
      });

      test("should be safe to call multiple times", () async {
        // Play a note
        await VirtualPianoUtils.playVirtualNote(60, midiState, (note) {});

        // Call dispose multiple times - should not throw
        expect(() {
          VirtualPianoUtils.dispose();
          VirtualPianoUtils.dispose();
          VirtualPianoUtils.dispose();
        }, returnsNormally);
      });

      test("should prevent stuck notes by attempting cleanup", () async {
        // This test verifies the core purpose of the dispose enhancement:
        // preventing stuck notes when dispose is called before timers fire

        // Play several notes
        await VirtualPianoUtils.playVirtualNote(60, midiState, (note) {}); // C4
        await VirtualPianoUtils.playVirtualNote(64, midiState, (note) {}); // E4
        await VirtualPianoUtils.playVirtualNote(67, midiState, (note) {}); // G4

        // Immediately dispose (before the 500ms timers would fire)
        // The key test is that this should not throw and should attempt cleanup
        expect(VirtualPianoUtils.dispose, returnsNormally);
      });
    });

    group("playVirtualNote functionality", () {
      test("should execute callback and update MIDI state", () async {
        var notePressed = false;
        var pressedNote = 0;

        await VirtualPianoUtils.playVirtualNote(
          60, // Middle C
          midiState,
          (note) {
            notePressed = true;
            pressedNote = note;
          },
        );

        // Verify callback was called
        expect(notePressed, isTrue);
        expect(pressedNote, equals(60));

        // Verify MIDI state was updated
        expect(midiState.lastNote.contains("Virtual Note ON: 60"), isTrue);
        expect(midiState.lastNote.contains("Ch: 1"), isTrue);
        expect(midiState.lastNote.contains("Vel: 64"), isTrue);
      });

      test("should handle different MIDI channels", () async {
        // Set channel to 5 (0-indexed, so channel 6 in UI)
        midiState.setSelectedChannel(5);

        await VirtualPianoUtils.playVirtualNote(
          67, // G4
          midiState,
          (note) {},
        );

        // Verify the channel was used in the message
        expect(midiState.lastNote.contains("Ch: 6"), isTrue);
      });
    });

    group("integration tests", () {
      test("should play notes and dispose successfully", () async {
        // This is a comprehensive integration test
        final notesPlayed = <int>[];

        // Play a chord
        await VirtualPianoUtils.playVirtualNote(60, midiState, notesPlayed.add);
        await VirtualPianoUtils.playVirtualNote(64, midiState, notesPlayed.add);
        await VirtualPianoUtils.playVirtualNote(67, midiState, notesPlayed.add);

        // Verify all notes were played
        expect(notesPlayed, equals([60, 64, 67]));

        // Verify MIDI state reflects the last note
        expect(midiState.lastNote.contains("Virtual Note ON: 67"), isTrue);

        // Dispose should work without errors
        expect(VirtualPianoUtils.dispose, returnsNormally);

        // After dispose, should still be able to play new notes
        await VirtualPianoUtils.playVirtualNote(72, midiState, notesPlayed.add);

        expect(notesPlayed.last, equals(72));
      });
    });
  });
}
