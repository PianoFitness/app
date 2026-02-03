// Unit tests for MidiState model.
//
// Tests the MIDI state management functionality including note handling,
// channel selection, and state notifications.

import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";

import "package:piano_fitness/presentation/state/midi_state.dart";

void main() {
  group("MidiState Unit Tests", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    test("should handle note on/off correctly", () {
      // Test note on
      midiState.noteOn(60, 127, 1);
      expect(midiState.activeNotes.contains(60), true);
      expect(midiState.lastNote, "Note ON: 60 (Ch: 1, Vel: 127)");
      expect(midiState.hasRecentActivity, true);

      // Test note off
      midiState.noteOff(60, 1);
      expect(midiState.activeNotes.contains(60), false);
      expect(midiState.lastNote, "Note OFF: 60 (Ch: 1)");
      expect(midiState.hasRecentActivity, true);
    });

    test("should handle multiple active notes", () {
      midiState
        ..noteOn(60, 127, 1) // C4
        ..noteOn(64, 100, 1) // E4
        ..noteOn(67, 80, 1); // G4

      expect(midiState.activeNotes.length, 3);
      expect(midiState.activeNotes.contains(60), true);
      expect(midiState.activeNotes.contains(64), true);
      expect(midiState.activeNotes.contains(67), true);

      // Turn off middle note
      midiState.noteOff(64, 1);
      expect(midiState.activeNotes.length, 2);
      expect(midiState.activeNotes.contains(64), false);
      expect(midiState.activeNotes.contains(60), true);
      expect(midiState.activeNotes.contains(67), true);
    });

    test("should convert MIDI notes to NotePosition correctly", () {
      midiState
        ..noteOn(60, 127, 1) // C4
        ..noteOn(61, 127, 1) // C#4
        ..noteOn(62, 127, 1); // D4

      final positions = midiState.highlightedNotePositions;
      expect(positions.length, 3);

      // Check for C4
      final cNote = positions.firstWhere(
        (pos) => pos.note == Note.C && pos.octave == 4,
      );
      expect(cNote.accidental, anyOf(null, Accidental.None));

      // Check for C#4
      final cSharpNote = positions.firstWhere(
        (pos) =>
            pos.note == Note.C &&
            pos.octave == 4 &&
            pos.accidental == Accidental.Sharp,
      );
      expect(cSharpNote.accidental, Accidental.Sharp);

      // Check for D4
      final dNote = positions.firstWhere(
        (pos) => pos.note == Note.D && pos.octave == 4,
      );
      expect(dNote.accidental, anyOf(null, Accidental.None));
    });

    test("should handle channel selection", () {
      expect(midiState.selectedChannel, 0);

      midiState.setSelectedChannel(5);
      expect(midiState.selectedChannel, 5);

      // Test invalid channels are ignored
      midiState.setSelectedChannel(-1);
      expect(midiState.selectedChannel, 5); // Should remain unchanged

      midiState.setSelectedChannel(16);
      expect(midiState.selectedChannel, 5); // Should remain unchanged
    });

    test("should clear active notes", () {
      midiState
        ..noteOn(60, 127, 1)
        ..noteOn(64, 127, 1)
        ..noteOn(67, 127, 1);

      expect(midiState.activeNotes.length, 3);

      midiState.clearActiveNotes();
      expect(midiState.activeNotes.isEmpty, true);
    });

    test("should notify listeners on state changes", () {
      var notified = false;
      midiState.addListener(() {
        notified = true;
      });

      // ignore: cascade_invocations - need to test notification between calls
      midiState.noteOn(60, 127, 1);
      expect(notified, true);

      // Reset notification flag and test another state change
      notified = false;
      // ignore: cascade_invocations - need to test notification between calls
      midiState.setSelectedChannel(5);
      expect(notified, true);

      // Reset notification flag and test clearing notes
      notified = false;
      // ignore: cascade_invocations - need to test notification between calls
      midiState.clearActiveNotes();
      expect(notified, true);
    });

    testWidgets("should reset recent activity after timer", (tester) async {
      midiState.noteOn(60, 127, 1);
      expect(midiState.hasRecentActivity, true);

      // Wait for activity timer to expire
      await tester.pump(const Duration(seconds: 2));
      expect(midiState.hasRecentActivity, false);
    });
  });

  group("MidiState Edge Cases", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    test("should handle invalid MIDI note numbers", () {
      // Add some valid notes first to establish a baseline
      midiState
        ..noteOn(60, 127, 1)
        ..noteOn(64, 127, 1);
      final initialNotesCount = midiState.activeNotes.length;
      expect(initialNotesCount, 2);

      // Test notes outside valid MIDI range - these should still be added to activeNotes
      // because the MidiState doesn't validate MIDI note ranges
      midiState
        ..noteOn(-1, 127, 1)
        ..noteOn(128, 127, 1);

      // Active notes will include invalid notes (this is the current behavior)
      expect(midiState.activeNotes.length, initialNotesCount + 2);

      // But lastNote should still be updated
      expect(midiState.lastNote.contains("Note ON: 128"), true);
    });

    test("should handle duplicate note on/off events", () {
      midiState.noteOn(60, 127, 1);
      expect(midiState.activeNotes.contains(60), true);

      // Duplicate note on should not create duplicate entries
      midiState.noteOn(60, 100, 1);
      expect(midiState.activeNotes.where((note) => note == 60).length, 1);

      // Note off should remove the note
      midiState.noteOff(60, 1);
      expect(midiState.activeNotes.contains(60), false);

      // Duplicate note off should not cause issues
      midiState.noteOff(60, 1);
      expect(midiState.activeNotes.contains(60), false);
    });

    test("should handle velocity and channel parameters", () {
      midiState.noteOn(60, 0, 0); // Minimum velocity and channel
      expect(midiState.lastNote, "Note ON: 60 (Ch: 0, Vel: 0)");

      midiState.noteOn(61, 127, 15); // Maximum velocity and channel
      expect(midiState.lastNote, "Note ON: 61 (Ch: 15, Vel: 127)");
    });
  });

  group("MidiState Highlighted Notes (Reference Mode)", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    test("should set highlighted notes correctly", () {
      final testNotes = {60, 64, 67}; // C Major triad

      midiState.setHighlightedNotes(testNotes);

      expect(midiState.activeNotes, equals(testNotes));
      expect(midiState.highlightedNotePositions.length, equals(3));
    });

    test(
      "should replace existing active notes when setting highlighted notes",
      () {
        // First set some active notes through normal note on
        midiState
          ..noteOn(48, 127, 1)
          ..noteOn(50, 127, 1);

        expect(midiState.activeNotes.length, equals(2));

        // Now set highlighted notes - should replace the existing ones
        final newNotes = {60, 64, 67, 72};
        midiState.setHighlightedNotes(newNotes);

        expect(midiState.activeNotes, equals(newNotes));
        expect(midiState.activeNotes.length, equals(4));
      },
    );

    test("should clear active notes when setting empty highlighted notes", () {
      // First set some active notes
      midiState
        ..noteOn(60, 127, 1)
        ..noteOn(64, 127, 1);

      expect(midiState.activeNotes.length, equals(2));

      // Set empty highlighted notes
      midiState.setHighlightedNotes(<int>{});

      expect(midiState.activeNotes.isEmpty, isTrue);
    });

    test("should notify listeners when setting highlighted notes", () {
      var notified = false;
      midiState.addListener(() {
        notified = true;
      });

      midiState.setHighlightedNotes({60, 64, 67});

      expect(notified, isTrue);
    });

    test("should handle large sets of highlighted notes", () {
      // Create a large set of notes (e.g., multiple octaves of a scale)
      final largeNoteSet = <int>{};
      for (var octave = 2; octave <= 6; octave++) {
        for (var note = 0; note < 12; note++) {
          largeNoteSet.add((octave + 1) * 12 + note);
        }
      }

      midiState.setHighlightedNotes(largeNoteSet);

      expect(midiState.activeNotes.length, equals(largeNoteSet.length));
      expect(midiState.activeNotes, equals(largeNoteSet));
    });

    test("should handle highlighted notes with invalid MIDI values", () {
      // Test with notes outside normal MIDI range
      final notesWithInvalidValues = {-1, 60, 64, 67, 128, 200};

      midiState.setHighlightedNotes(notesWithInvalidValues);

      // MidiState should store all values (it doesn't validate MIDI range)
      expect(midiState.activeNotes, equals(notesWithInvalidValues));
    });

    test("should convert highlighted notes to NotePosition correctly", () {
      final testNotes = {60, 61, 62}; // C4, C#4, D4

      midiState.setHighlightedNotes(testNotes);

      final positions = midiState.highlightedNotePositions;
      expect(positions.length, equals(3));

      // Check for C4 (should have exactly one)
      final cNote = positions.where(
        (pos) =>
            pos.note == Note.C &&
            pos.octave == 4 &&
            pos.accidental != Accidental.Sharp,
      );
      expect(cNote.length, equals(1));

      // Check for C#4
      final cSharpNote = positions.where(
        (pos) =>
            pos.note == Note.C &&
            pos.octave == 4 &&
            pos.accidental == Accidental.Sharp,
      );
      expect(cSharpNote.length, equals(1));

      // Check for D4
      final dNote = positions.where(
        (pos) => pos.note == Note.D && pos.octave == 4,
      );
      expect(dNote.length, equals(1));
    });
  });
}
