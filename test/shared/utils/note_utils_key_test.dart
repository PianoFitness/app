import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("NoteUtils keyToMidiNumber Tests", () {
    test("should convert all keys to correct MIDI numbers in octave 4", () {
      // Test all 12 chromatic keys
      expect(NoteUtils.keyToMidiNumber(music.Key.c), equals(60)); // C4
      expect(NoteUtils.keyToMidiNumber(music.Key.cSharp), equals(61)); // C#4
      expect(NoteUtils.keyToMidiNumber(music.Key.d), equals(62)); // D4
      expect(NoteUtils.keyToMidiNumber(music.Key.dSharp), equals(63)); // D#4
      expect(NoteUtils.keyToMidiNumber(music.Key.e), equals(64)); // E4
      expect(NoteUtils.keyToMidiNumber(music.Key.f), equals(65)); // F4
      expect(NoteUtils.keyToMidiNumber(music.Key.fSharp), equals(66)); // F#4
      expect(NoteUtils.keyToMidiNumber(music.Key.g), equals(67)); // G4
      expect(NoteUtils.keyToMidiNumber(music.Key.gSharp), equals(68)); // G#4
      expect(NoteUtils.keyToMidiNumber(music.Key.a), equals(69)); // A4
      expect(NoteUtils.keyToMidiNumber(music.Key.aSharp), equals(70)); // A#4
      expect(NoteUtils.keyToMidiNumber(music.Key.b), equals(71)); // B4
    });

    test("should provide consistent mapping for common keys", () {
      // Test some common chord progression keys
      expect(NoteUtils.keyToMidiNumber(music.Key.c), equals(60)); // Middle C
      expect(NoteUtils.keyToMidiNumber(music.Key.g), equals(67)); // G major
      expect(NoteUtils.keyToMidiNumber(music.Key.f), equals(65)); // F major
      expect(NoteUtils.keyToMidiNumber(music.Key.d), equals(62)); // D major
    });

    test("should maintain chromatic spacing", () {
      // Verify that adjacent keys are 1 semitone apart
      final cMidi = NoteUtils.keyToMidiNumber(music.Key.c);
      final cSharpMidi = NoteUtils.keyToMidiNumber(music.Key.cSharp);
      final dMidi = NoteUtils.keyToMidiNumber(music.Key.d);

      expect(cSharpMidi - cMidi, equals(1));
      expect(dMidi - cSharpMidi, equals(1));
    });
  });
}
