// Unit tests for PianoKeyVisual.

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_key_visual.dart";

void main() {
  group("PianoKeyVisual", () {
    test("empty has no indicators set", () {
      expect(PianoKeyVisual.empty.fill, isNull);
      expect(PianoKeyVisual.empty.outline, isNull);
      expect(PianoKeyVisual.empty.dot, isNull);
      expect(PianoKeyVisual.empty.label, isNull);
    });

    test("independently composes fill, outline, dot, and label", () {
      const visual = PianoKeyVisual(
        fill: Colors.red,
        outline: Colors.blue,
        dot: Colors.green,
        label: "2",
      );

      expect(visual.fill, Colors.red);
      expect(visual.outline, Colors.blue);
      expect(visual.dot, Colors.green);
      expect(visual.label, "2");
    });

    test("copyWith replaces only the given fields", () {
      const visual = PianoKeyVisual(fill: Colors.red, label: "1");
      final updated = visual.copyWith(outline: Colors.blue);

      expect(updated.fill, Colors.red);
      expect(updated.outline, Colors.blue);
      expect(updated.label, "1");
    });

    test("copyWith clears a field when explicitly passed null", () {
      const visual = PianoKeyVisual(fill: Colors.red, label: "1");
      final cleared = visual.copyWith(label: null);

      expect(cleared.fill, Colors.red);
      expect(cleared.label, isNull);
    });

    test("has value equality", () {
      const a = PianoKeyVisual(fill: Colors.red, label: "1");
      const b = PianoKeyVisual(fill: Colors.red, label: "1");
      const c = PianoKeyVisual(fill: Colors.blue, label: "1");

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
