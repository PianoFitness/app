import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/theme/piano_key_colors.dart";

void main() {
  group("PianoKeyColors Theme Extension Tests", () {
    test("light theme defines explicit keys and contrast label colors", () {
      const colors = PianoKeyColors.light;
      expect(colors.whiteKey, equals(const Color(0xFFFAFAFA)));
      expect(colors.blackKey, equals(const Color(0xFF212121)));
      expect(colors.whiteLabel, equals(const Color(0xFF212121)));
      expect(colors.blackLabel, equals(const Color(0xFFFAFAFA)));
    });

    test("dark theme defines explicit keys and contrast label colors", () {
      const colors = PianoKeyColors.dark;
      expect(colors.whiteKey, equals(const Color(0xFFE0E0E0)));
      expect(colors.blackKey, equals(const Color(0xFF303030)));
      expect(colors.whiteLabel, equals(const Color(0xFF212121)));
      expect(colors.blackLabel, equals(const Color(0xFFE0E0E0)));
    });

    test("copyWith copies modified colors and keeps defaults", () {
      const original = PianoKeyColors.light;
      final copy = original.copyWith(
        whiteLabel: Colors.blue,
        blackLabel: Colors.red,
      );

      expect(copy.whiteKey, equals(original.whiteKey));
      expect(copy.blackKey, equals(original.blackKey));
      expect(copy.whiteLabel, equals(Colors.blue));
      expect(copy.blackLabel, equals(Colors.red));
    });

    test("lerp interpolates key and label colors correctly", () {
      const light = PianoKeyColors.light;
      const dark = PianoKeyColors.dark;

      final lerpedHalf = light.lerp(dark, 0.5);
      expect(
        lerpedHalf.whiteKey,
        equals(Color.lerp(light.whiteKey, dark.whiteKey, 0.5)),
      );
      expect(
        lerpedHalf.blackKey,
        equals(Color.lerp(light.blackKey, dark.blackKey, 0.5)),
      );
      expect(
        lerpedHalf.whiteLabel,
        equals(Color.lerp(light.whiteLabel, dark.whiteLabel, 0.5)),
      );
      expect(
        lerpedHalf.blackLabel,
        equals(Color.lerp(light.blackLabel, dark.blackLabel, 0.5)),
      );

      final lerpedSelf = light.lerp(null, 0.5);
      expect(lerpedSelf, equals(light));
    });
  });
}
