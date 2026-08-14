import "package:flutter/material.dart";

import "package:piano_fitness/presentation/constants/typography_constants.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/theme/piano_key_colors.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";

/// The Material 3 theme foundation for Piano Fitness.
///
/// Feature widgets should prefer values from [ThemeData] and its extensions
/// instead of defining local colors, shapes, or typography. Keeping the light
/// and dark themes here makes those shared decisions easy to review together.
abstract final class AppTheme {
  /// The seed used to generate the app's Material 3 color schemes.
  static const Color seedColor = Colors.deepPurple;

  /// The app's light Material 3 theme.
  static final ThemeData light = _build(Brightness.light);

  /// The app's dark Material 3 theme.
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final baseTheme = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    final compactControlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        indicatorColor: colorScheme.secondaryContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, ComponentDimensions.minTouchTarget),
          shape: compactControlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, ComponentDimensions.minTouchTarget),
          shape: compactControlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, ComponentDimensions.minTouchTarget),
          shape: compactControlShape,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        if (brightness == Brightness.light) ...const [
          SemanticColors.light,
          PianoKeyColors.light,
        ] else ...const [SemanticColors.dark, PianoKeyColors.dark],
      ],
    );
  }

  /// Applies the Piano Fitness type scale without discarding Material 3's
  /// font weights, letter spacing, and line heights.
  static TextTheme _textTheme(TextTheme materialTextTheme) {
    return materialTextTheme.copyWith(
      displayLarge: materialTextTheme.displayLarge?.copyWith(
        fontSize: FontSizes.displayLarge,
      ),
      displayMedium: materialTextTheme.displayMedium?.copyWith(
        fontSize: FontSizes.displayMedium,
      ),
      displaySmall: materialTextTheme.displaySmall?.copyWith(
        fontSize: FontSizes.displaySmall,
      ),
      headlineLarge: materialTextTheme.headlineLarge?.copyWith(
        fontSize: FontSizes.headlineLarge,
      ),
      headlineMedium: materialTextTheme.headlineMedium?.copyWith(
        fontSize: FontSizes.headlineMedium,
      ),
      headlineSmall: materialTextTheme.headlineSmall?.copyWith(
        fontSize: FontSizes.headlineSmall,
      ),
      titleLarge: materialTextTheme.titleLarge?.copyWith(
        fontSize: FontSizes.titleLarge,
      ),
      titleMedium: materialTextTheme.titleMedium?.copyWith(
        fontSize: FontSizes.titleMedium,
      ),
      titleSmall: materialTextTheme.titleSmall?.copyWith(
        fontSize: FontSizes.titleSmall,
      ),
      bodyLarge: materialTextTheme.bodyLarge?.copyWith(
        fontSize: FontSizes.bodyLarge,
      ),
      bodyMedium: materialTextTheme.bodyMedium?.copyWith(
        fontSize: FontSizes.bodyMedium,
      ),
      bodySmall: materialTextTheme.bodySmall?.copyWith(
        fontSize: FontSizes.bodySmall,
      ),
      labelLarge: materialTextTheme.labelLarge?.copyWith(
        fontSize: FontSizes.labelLarge,
      ),
      labelMedium: materialTextTheme.labelMedium?.copyWith(
        fontSize: FontSizes.labelMedium,
      ),
      labelSmall: materialTextTheme.labelSmall?.copyWith(
        fontSize: FontSizes.labelSmall,
      ),
    );
  }
}
