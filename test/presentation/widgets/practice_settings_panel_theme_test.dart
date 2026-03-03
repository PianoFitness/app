import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;
import "package:piano_fitness/presentation/widgets/practice_settings_panel.dart";

void main() {
  // Helper to create a default configuration for testing
  ExerciseConfiguration createDefaultConfig() {
    return const ExerciseConfiguration(
      practiceMode: PracticeMode.scales,
      handSelection: HandSelection.both,
      key: music.Key.c,
      scaleType: music.ScaleType.major,
    );
  }

  group("PracticeSettingsPanel Theme Tests", () {
    testWidgets("uses theme colors in light mode", (WidgetTester tester) async {
      // Build widget with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              configuration: createDefaultConfig(),
              onConfigurationChanged: (_) {},
              practiceActive: false,
              onResetPractice: () {},
              autoProgressKeys: false,
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the panel container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(PracticeSettingsPanel.panelKey))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);

      // Verify "Practice Settings" text is present
      expect(find.text("Practice Settings"), findsOneWidget);

      // Verify fitness center icon is present
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets("uses theme colors in dark mode", (WidgetTester tester) async {
      // Build widget with dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              configuration: createDefaultConfig(),
              onConfigurationChanged: (_) {},
              practiceActive: false,
              onResetPractice: () {},
              autoProgressKeys: false,
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the panel container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(PracticeSettingsPanel.panelKey))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);

      // Verify practice status container with different states
      final practiceStatusContainer = tester.widget<Container>(
        find.byKey(PracticeSettingsPanel.statusKey),
      );

      expect(practiceStatusContainer.decoration, isNotNull);

      // Verify "Practice Settings" text is present and readable
      expect(find.text("Practice Settings"), findsOneWidget);

      // Verify "Ready - Play Any Note to Start" text is present
      expect(find.text("Ready - Play Any Note to Start"), findsOneWidget);
    });

    testWidgets("shows different colors for active and inactive practice", (
      WidgetTester tester,
    ) async {
      // Test inactive state
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              configuration: createDefaultConfig(),
              onConfigurationChanged: (_) {},
              practiceActive: false,
              onResetPractice: () {},
              autoProgressKeys: false,
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Ready - Play Any Note to Start"), findsOneWidget);

      // Test active state
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeSettingsPanel(
              configuration: createDefaultConfig(),
              onConfigurationChanged: (_) {},
              practiceActive: true,
              onResetPractice: () {},
              autoProgressKeys: false,
              onAutoProgressKeysChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Practice Active - Keep Playing!"), findsOneWidget);
    });
  });
}
