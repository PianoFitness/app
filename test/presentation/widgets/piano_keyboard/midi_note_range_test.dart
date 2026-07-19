// Unit tests for MidiNoteRange.

import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/midi_note_range.dart";

void main() {
  group("MidiNoteRange", () {
    test("stores fromMidi and toMidi", () {
      const range = MidiNoteRange(fromMidi: 36, toMidi: 84);
      expect(range.fromMidi, 36);
      expect(range.toMidi, 84);
    });

    test("supports a single-note range", () {
      const range = MidiNoteRange(fromMidi: 60, toMidi: 60);
      expect(range.fromMidi, 60);
      expect(range.toMidi, 60);
    });

    test("asserts fromMidi <= toMidi", () {
      expect(
        () => MidiNoteRange(fromMidi: 84, toMidi: 36),
        throwsA(isA<AssertionError>()),
      );
    });

    test("has value equality", () {
      const a = MidiNoteRange(fromMidi: 36, toMidi: 84);
      const b = MidiNoteRange(fromMidi: 36, toMidi: 84);
      const c = MidiNoteRange(fromMidi: 21, toMidi: 108);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test("toString is human-readable", () {
      const range = MidiNoteRange(fromMidi: 36, toMidi: 84);
      expect(range.toString(), contains("36"));
      expect(range.toString(), contains("84"));
    });
  });
}
