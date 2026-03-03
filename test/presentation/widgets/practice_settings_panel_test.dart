import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;
import "package:piano_fitness/presentation/widgets/practice_settings_panel.dart";

/// Tests for PracticeSettingsPanel widget, specifically hand selection functionality.
///
/// Note: SegmentedButton does not expose individual segments with Keys, so tests
/// trigger onSelectionChanged callbacks programmatically to verify wiring and state
/// management. This complies with project guidelines (no find.text() selectors).
///
void main() {
  group("PracticeSettingsPanel", () {
    // Test helper to create a minimal widget tree with PracticeSettingsPanel
    Widget createTestWidget({
      required HandSelection selectedHandSelection,
      required void Function(HandSelection) onHandSelectionChanged,
      PracticeMode practiceMode = PracticeMode.scales,
    }) {
      final configuration = ExerciseConfiguration(
        practiceMode: practiceMode,
        handSelection: selectedHandSelection,
        key: music.Key.c,
        scaleType: music.ScaleType.major,
      );

      return MaterialApp(
        home: Scaffold(
          body: PracticeSettingsPanel(
            configuration: configuration,
            onConfigurationChanged: (newConfig) {
              if (newConfig.handSelection != selectedHandSelection) {
                onHandSelectionChanged(newConfig.handSelection);
              }
            },
            practiceActive: false,
            onResetPractice: () {},
            autoProgressKeys: false,
            onAutoProgressKeysChanged: (_) {},
          ),
        ),
      );
    }

    group("Hand selection SegmentedButton", () {
      testWidgets("should display SegmentedButton widget", (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            selectedHandSelection: HandSelection.right,
            onHandSelectionChanged: (_) {},
          ),
        );

        // Verify the SegmentedButton is rendered
        expect(find.byType(SegmentedButton<HandSelection>), findsOneWidget);
      });

      testWidgets("should show right hand as initially selected", (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            selectedHandSelection: HandSelection.right,
            onHandSelectionChanged: (_) {},
          ),
        );

        // Find the SegmentedButton
        final segmentedButtonFinder = find.byType(
          SegmentedButton<HandSelection>,
        );
        expect(segmentedButtonFinder, findsOneWidget);
        final segmentedButton = tester.widget<SegmentedButton<HandSelection>>(
          segmentedButtonFinder,
        );

        // Verify right hand is selected
        expect(segmentedButton.selected, equals({HandSelection.right}));
      });

      testWidgets("should call onHandSelectionChanged when left hand selected", (
        tester,
      ) async {
        HandSelection? capturedSelection;

        await tester.pumpWidget(
          createTestWidget(
            selectedHandSelection: HandSelection.right,
            onHandSelectionChanged: (selection) {
              capturedSelection = selection;
            },
          ),
        );

        // Get the SegmentedButton widget to access its callback
        // Note: SegmentedButton does not expose individual segments with Keys,
        // so we trigger the callback programmatically to verify correct wiring.
        final segmentedButtonFinder = find.byType(
          SegmentedButton<HandSelection>,
        );
        expect(segmentedButtonFinder, findsOneWidget);
        final segmentedButton = tester.widget<SegmentedButton<HandSelection>>(
          segmentedButtonFinder,
        );

        // Programmatically trigger the selection callback
        segmentedButton.onSelectionChanged!({HandSelection.left});
        await tester.pumpAndSettle();

        // Verify callback was called with correct value
        expect(capturedSelection, equals(HandSelection.left));
      });

      testWidgets(
        "should call onHandSelectionChanged when both hands selected",
        (tester) async {
          HandSelection? capturedSelection;

          await tester.pumpWidget(
            createTestWidget(
              selectedHandSelection: HandSelection.right,
              onHandSelectionChanged: (selection) {
                capturedSelection = selection;
              },
            ),
          );

          // Get the SegmentedButton widget to access its callback
          final segmentedButtonFinder = find.byType(
            SegmentedButton<HandSelection>,
          );
          expect(segmentedButtonFinder, findsOneWidget);
          final segmentedButton = tester.widget<SegmentedButton<HandSelection>>(
            segmentedButtonFinder,
          );

          // Programmatically trigger the selection callback
          segmentedButton.onSelectionChanged!({HandSelection.both});
          await tester.pumpAndSettle();

          // Verify callback was called with correct value
          expect(capturedSelection, equals(HandSelection.both));
        },
      );

      testWidgets(
        "should enforce single selection (only one button selected)",
        (tester) async {
          await tester.pumpWidget(
            createTestWidget(
              selectedHandSelection: HandSelection.right,
              onHandSelectionChanged: (_) {},
            ),
          );

          // Find the SegmentedButton
          final segmentedButtonFinder = find.byType(
            SegmentedButton<HandSelection>,
          );
          expect(segmentedButtonFinder, findsOneWidget);
          final segmentedButton = tester.widget<SegmentedButton<HandSelection>>(
            segmentedButtonFinder,
          );

          // Verify only one selection is active
          expect(segmentedButton.selected.length, equals(1));
        },
      );

      testWidgets("should not show checkmark icon on selection", (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            selectedHandSelection: HandSelection.left,
            onHandSelectionChanged: (_) {},
          ),
        );

        // Find the SegmentedButton widget
        final segmentedButtonFinder = find.byType(
          SegmentedButton<HandSelection>,
        );
        expect(segmentedButtonFinder, findsOneWidget);
        final segmentedButton = tester.widget<SegmentedButton<HandSelection>>(
          segmentedButtonFinder,
        );

        // Verify showSelectedIcon is false
        expect(segmentedButton.showSelectedIcon, equals(false));

        // Verify no checkmark icons are present within the SegmentedButton subtree
        // Use descendant finder to scope the search and avoid false positives
        // from other widgets in the tree
        final checkIconFinder = find.descendant(
          of: segmentedButtonFinder,
          matching: find.byIcon(Icons.check),
        );
        expect(checkIconFinder, findsNothing);
      });

      testWidgets("should update selection when state changes", (tester) async {
        HandSelection currentSelection = HandSelection.right;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return createTestWidget(
                selectedHandSelection: currentSelection,
                onHandSelectionChanged: (selection) {
                  setState(() {
                    currentSelection = selection;
                  });
                },
              );
            },
          ),
        );

        // Verify initial state
        final segmentedButtonFinder = find.byType(
          SegmentedButton<HandSelection>,
        );
        expect(segmentedButtonFinder, findsOneWidget);
        var segmentedButton = tester.widget<SegmentedButton<HandSelection>>(
          segmentedButtonFinder,
        );
        expect(segmentedButton.selected, equals({HandSelection.right}));

        // Programmatically trigger left hand selection
        segmentedButton.onSelectionChanged!({HandSelection.left});
        await tester.pumpAndSettle();

        // Verify the state change triggered a UI update
        expect(segmentedButtonFinder, findsOneWidget);
        segmentedButton = tester.widget<SegmentedButton<HandSelection>>(
          segmentedButtonFinder,
        );
        expect(segmentedButton.selected, equals({HandSelection.left}));
      });
    });
  });
}
