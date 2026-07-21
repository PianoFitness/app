// Unit tests for piano_keyboard_geometry.dart: range expansion, key layout,
// and MIDI-note hit testing.

import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/midi_note_range.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard_geometry.dart";

void main() {
  group("expandToWhiteKeyBoundary", () {
    test("leaves an already white-boundary range unchanged", () {
      // C2 (36) to C6 (84) are both white keys.
      const range = MidiNoteRange(fromMidi: 36, toMidi: 84);
      final expanded = expandToWhiteKeyBoundary(range);
      expect(expanded, equals(range));
    });

    test("expands a black-key start downward to the nearest white key", () {
      // 61 = C#4 (black); expands down to 60 = C4 (white).
      const range = MidiNoteRange(fromMidi: 61, toMidi: 72);
      final expanded = expandToWhiteKeyBoundary(range);
      expect(expanded.fromMidi, 60);
      expect(expanded.toMidi, 72);
    });

    test("expands a black-key end upward to the nearest white key", () {
      // 70 = A#4 (black); expands up to 71 = B4 (white).
      const range = MidiNoteRange(fromMidi: 60, toMidi: 70);
      final expanded = expandToWhiteKeyBoundary(range);
      expect(expanded.fromMidi, 60);
      expect(expanded.toMidi, 71);
    });

    test("never truncates the requested range, only widens it", () {
      const range = MidiNoteRange(fromMidi: 61, toMidi: 70);
      final expanded = expandToWhiteKeyBoundary(range);
      expect(expanded.fromMidi, lessThanOrEqualTo(range.fromMidi));
      expect(expanded.toMidi, greaterThanOrEqualTo(range.toMidi));
    });

    test("handles a single black-key note by expanding both directions", () {
      const range = MidiNoteRange(fromMidi: 61, toMidi: 61); // C#4
      final expanded = expandToWhiteKeyBoundary(range);
      expect(expanded.fromMidi, 60); // C4
      expect(expanded.toMidi, 62); // D4
    });
  });

  group("PianoKeyboardLayout", () {
    PianoKeyboardLayout layoutFor(MidiNoteRange range, {double width = 44}) {
      return PianoKeyboardLayout(
        range: expandToWhiteKeyBoundary(range),
        whiteKeyWidth: width,
        height: 120,
      );
    }

    test("lays out white keys sequentially left to right", () {
      final layout = layoutFor(const MidiNoteRange(fromMidi: 60, toMidi: 72));
      expect(layout.whiteKeys, isNotEmpty);
      for (var i = 0; i < layout.whiteKeys.length; i++) {
        expect(layout.whiteKeys[i].rect.left, i * 44);
        expect(layout.whiteKeys[i].rect.width, 44);
      }
      // Ascending MIDI order.
      for (var i = 1; i < layout.whiteKeys.length; i++) {
        expect(
          layout.whiteKeys[i].midiNote,
          greaterThan(layout.whiteKeys[i - 1].midiNote),
        );
      }
    });

    test("totalWidth matches the white-key count", () {
      final layout = layoutFor(const MidiNoteRange(fromMidi: 36, toMidi: 84));
      expect(layout.totalWidth, layout.whiteKeys.length * 44);
    });

    test("black keys sit between their neighboring white keys", () {
      final layout = layoutFor(const MidiNoteRange(fromMidi: 60, toMidi: 72));
      final blackKeyMidiNotes = layout.blackKeys
          .map((k) => k.midiNote)
          .toList();
      // C4-C5 octave: C#4, D#4, F#4, G#4, A#4.
      expect(blackKeyMidiNotes, containsAll([61, 63, 66, 68, 70]));

      for (final blackKey in layout.blackKeys) {
        expect(blackKey.rect.height, lessThan(120));
        expect(blackKey.rect.width, lessThan(44));
      }
    });

    test("no black key is laid out between E/F or B/C", () {
      final layout = layoutFor(const MidiNoteRange(fromMidi: 60, toMidi: 72));
      final blackKeyMidiNotes = layout.blackKeys.map((k) => k.midiNote);
      expect(blackKeyMidiNotes, isNot(contains(64))); // no E#4
      expect(blackKeyMidiNotes, isNot(contains(71))); // no B#4
    });

    group("hitTest", () {
      test("resolves a white-key-only point to the white key", () {
        final layout = layoutFor(const MidiNoteRange(fromMidi: 60, toMidi: 72));
        // C4 is the first white key; well below the black-key overlap band.
        final midi = layout.hitTest(const Offset(10, 110));
        expect(midi, 60);
      });

      test(
        "resolves a point within the black-key overlap band to the black key",
        () {
          final layout = layoutFor(
            const MidiNoteRange(fromMidi: 60, toMidi: 72),
          );
          final blackKey = layout.blackKeys.firstWhere((k) => k.midiNote == 61);
          final midi = layout.hitTest(blackKey.rect.center);
          expect(midi, 61);
        },
      );

      test(
        "falls through to the white key below the black-key overlap band",
        () {
          final layout = layoutFor(
            const MidiNoteRange(fromMidi: 60, toMidi: 72),
          );
          final blackKey = layout.blackKeys.firstWhere((k) => k.midiNote == 61);
          // Same x as the black key, but below its bottom edge.
          final belowBlackKey = Offset(
            blackKey.rect.center.dx,
            blackKey.rect.bottom + 5,
          );
          final midi = layout.hitTest(belowBlackKey);
          // C#4's neighbors are C4 (60) and D4 (62); either is an
          // acceptable white key beneath the overlap band depending on
          // exactly where the boundary falls.
          expect(midi, anyOf(60, 62));
        },
      );

      test("returns null outside the keyboard bounds", () {
        final layout = layoutFor(const MidiNoteRange(fromMidi: 60, toMidi: 72));
        expect(layout.hitTest(const Offset(-10, 10)), isNull);
        expect(layout.hitTest(Offset(layout.totalWidth + 10, 10)), isNull);
        expect(layout.hitTest(const Offset(10, 500)), isNull);
      });
    });

    for (final span in [
      (name: "25-key", from: 60, to: 84),
      (name: "49-key", from: 36, to: 84),
      (name: "61-key", from: 36, to: 96),
      (name: "88-key", from: 21, to: 108),
    ]) {
      test("computes a consistent layout for a ${span.name} range", () {
        final layout = layoutFor(
          MidiNoteRange(fromMidi: span.from, toMidi: span.to),
        );

        // Every white key should be independently hit-testable at its
        // center, low enough to clear any overlapping black key.
        for (final whiteKey in layout.whiteKeys) {
          final probe = Offset(
            whiteKey.rect.center.dx,
            whiteKey.rect.bottom - 1,
          );
          expect(layout.hitTest(probe), whiteKey.midiNote);
        }

        // Every black key should be hit-testable at its own center.
        for (final blackKey in layout.blackKeys) {
          expect(layout.hitTest(blackKey.rect.center), blackKey.midiNote);
        }
      });
    }
  });
}
