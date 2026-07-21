import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";

void main() {
  group("SemanticColors Unit Tests", () {
    test("light and dark presets provide valid non-null colors", () {
      expect(SemanticColors.light, isNotNull);
      expect(SemanticColors.dark, isNotNull);
      expect(SemanticColors.light.success, isA<Color>());
      expect(SemanticColors.dark.success, isA<Color>());
    });

    test("copyWith creates modified copy", () {
      final modified = SemanticColors.light.copyWith(success: Colors.purple);
      expect(modified.success, equals(Colors.purple));
      expect(modified.warning, equals(SemanticColors.light.warning));
    });

    test("lerp interpolates between light and dark themes", () {
      final interpolated = SemanticColors.light.lerp(SemanticColors.dark, 0.5);
      expect(interpolated, isA<SemanticColors>());
      expect(interpolated.success, isNotNull);

      final nonSemanticLerp = SemanticColors.light.lerp(null, 0.5);
      expect(nonSemanticLerp, equals(SemanticColors.light));
    });
  });
}
