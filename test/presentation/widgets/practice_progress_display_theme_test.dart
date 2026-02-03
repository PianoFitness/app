import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/presentation/widgets/practice_progress_display.dart";

void main() {
  group("PracticeProgressDisplay Theme Tests", () {
    testWidgets("uses theme colors in light mode", (WidgetTester tester) async {
      // Create test exercise for scales
      final testExercise = PracticeExercise(
        steps: [
          PracticeStep(
            notes: [60],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 1 (Right Hand)"},
          ),
          PracticeStep(
            notes: [62],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 2 (Right Hand)"},
          ),
          PracticeStep(
            notes: [64],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 3 (Right Hand)"},
          ),
          PracticeStep(
            notes: [65],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 4 (Right Hand)"},
          ),
          PracticeStep(
            notes: [67],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 5 (Right Hand)"},
          ),
          PracticeStep(
            notes: [69],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 6 (Right Hand)"},
          ),
          PracticeStep(
            notes: [71],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 7 (Right Hand)"},
          ),
          PracticeStep(
            notes: [72],
            type: StepType.sequential,
            metadata: {"displayName": "Degree 8 (Right Hand)"},
          ),
        ],
      );

      // Build widget with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.scales,
              practiceActive: true,
              currentExercise: testExercise,
              currentStepIndex: 3,
            ),
          ),
        ),
      );

      // Verify progress indicator is shown with unified format
      expect(find.text("Step 4/8"), findsOneWidget);
      expect(find.text("Degree 4 (Right Hand)"), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify the container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(const Key("ppd_container")))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);
    });

    testWidgets("uses theme colors in dark mode", (WidgetTester tester) async {
      // Create test exercise for chord progressions
      final testExercise = PracticeExercise(
        steps: [
          PracticeStep(
            notes: [60, 64, 67],
            type: StepType.simultaneous,
            metadata: {"displayName": "I: C Major"},
          ),
          PracticeStep(
            notes: [67, 71, 74],
            type: StepType.simultaneous,
            metadata: {"displayName": "V: G Major"},
          ),
        ],
      );

      // Build widget with dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.chordProgressions,
              practiceActive: true,
              currentExercise: testExercise,
              currentStepIndex: 0,
            ),
          ),
        ),
      );

      // Verify step text and chord name with roman numeral are shown
      expect(find.text("Step 1/2"), findsOneWidget);
      expect(find.text("I: C Major"), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify the container uses theme colors
      final containerDecoration =
          tester
                  .widget<Container>(find.byKey(const Key("ppd_container")))
                  .decoration
              as BoxDecoration;

      expect(containerDecoration.color, isNotNull);
      expect(containerDecoration.border, isNotNull);
    });

    testWidgets("hides when practice is not active", (
      WidgetTester tester,
    ) async {
      // Build widget with practice inactive
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.scales,
              practiceActive: false,
              currentExercise: null,
              currentStepIndex: 0,
            ),
          ),
        ),
      );

      // Should show nothing when practice is not active
      expect(find.byType(Container), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets("hides when exercise is null", (WidgetTester tester) async {
      // Build widget with null exercise
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: PracticeProgressDisplay(
              practiceMode: PracticeMode.scales,
              practiceActive: true,
              currentExercise: null,
              currentStepIndex: 0,
            ),
          ),
        ),
      );

      // Should show nothing when exercise is null
      expect(find.byType(Container), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
