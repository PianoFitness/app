import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/constants/typography_constants.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/theme/app_theme.dart";
import "package:piano_fitness/presentation/theme/piano_key_colors.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";

void main() {
  group("AppTheme", () {
    test("builds Material 3 light and dark themes", () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.light.extension<SemanticColors>(), SemanticColors.light);
      expect(AppTheme.light.extension<PianoKeyColors>(), PianoKeyColors.light);

      expect(AppTheme.dark.useMaterial3, isTrue);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.dark.extension<SemanticColors>(), SemanticColors.dark);
      expect(AppTheme.dark.extension<PianoKeyColors>(), PianoKeyColors.dark);
    });

    test("keeps Material 3 typography details while applying app sizes", () {
      final materialTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.seedColor),
        useMaterial3: true,
      );
      final appTitle = AppTheme.light.textTheme.titleLarge!;
      final materialTitle = materialTheme.textTheme.titleLarge!;

      expect(appTitle.fontSize, FontSizes.titleLarge);
      expect(appTitle.fontWeight, materialTitle.fontWeight);
      expect(appTitle.letterSpacing, materialTitle.letterSpacing);
      expect(appTitle.height, materialTitle.height);
      expect(
        AppTheme.light.textTheme.bodyMedium!.fontSize,
        FontSizes.bodyMedium,
      );
      expect(
        AppTheme.light.textTheme.labelSmall!.fontSize,
        FontSizes.labelSmall,
      );
    });

    test("uses the shared shapes and accessible button height", () {
      final cardShape =
          AppTheme.light.cardTheme.shape! as RoundedRectangleBorder;
      final cardRadius = cardShape.borderRadius as BorderRadius;
      final filledButtonSize = AppTheme
          .light
          .filledButtonTheme
          .style!
          .minimumSize!
          .resolve(const <WidgetState>{});
      final dialogShape =
          AppTheme.light.dialogTheme.shape! as RoundedRectangleBorder;
      final dialogRadius = dialogShape.borderRadius as BorderRadius;

      expect(cardRadius.topLeft.x, AppBorderRadius.large);
      expect(filledButtonSize!.height, ComponentDimensions.minTouchTarget);
      expect(dialogRadius.topLeft.x, AppBorderRadius.xLarge);
      expect(AppTheme.light.cardTheme.elevation, 0);
    });
  });
}
