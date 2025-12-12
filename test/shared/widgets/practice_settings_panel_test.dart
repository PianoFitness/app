import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;
import "package:piano_fitness/shared/widgets/practice_settings_panel.dart";

/// Tests for PracticeSettingsPanel widget, specifically hand selection functionality.
///
/// ## Testing Approach for SegmentedButton
///
/// **Important**: Flutter's SegmentedButton widget does not expose individual segment
/// widgets with Keys for testing. The segments are rendered internally without public
/// API access. This is an architectural limitation of the SegmentedButton implementation.
///
/// ### Why Programmatic Callback Triggering
///
/// 1. **No Individual Segment Keys**: SegmentedButton does not support adding Keys to
///    individual segments, only to the button container itself.
///
/// 2. **Text-Based Selection Forbidden**: Per project guidelines (test/GUIDELINES.md),
///    text-based selectors (find.text() with tester.tap()) are forbidden as they:
///    - Break on copy changes/localization
///    - Are fragile and fail precommit checks (scripts/check-test-selectors.sh)
///    - Violate project key-based testing standards
///
/// 3. **Programmatic Approach**: We trigger the onSelectionChanged callback directly
///    to verify the wiring is correct. While this doesn't test gesture handling, it:
///    - Validates the callback logic
///    - Complies with project testing guidelines
///    - Is the only viable approach given SegmentedButton API constraints
///    - Still provides value by ensuring correct state management
///
/// 4. **Alternative Considered**: Using Semantics/accessibility identifiers was explored
///    but SegmentedButton doesn't expose semantic labels for individual segments either.
///
/// ### What These Tests Verify
///
/// - Correct button rendering (text labels present)
/// - Selected state matches the selectedHandSelection parameter
/// - onSelectionChanged callback is properly wired
/// - State updates trigger UI re-renders correctly
/// - showSelectedIcon configuration is respected
///
/// ### Future Improvements
///
/// If Flutter adds Keys/Semantics support for individual SegmentedButton segments,
/// these tests should be updated to use find.byKey() with tester.tap() for more
/// comprehensive gesture/hit-testing validation.
///
void main() {
  group("PracticeSettingsPanel", () {
    // Test helper to create a minimal widget tree with PracticeSettingsPanel
    Widget createTestWidget({
      required HandSelection selectedHandSelection,
      required void Function(HandSelection) onHandSelectionChanged,
      PracticeMode practiceMode = PracticeMode.scales,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PracticeSettingsPanel(
            practiceMode: practiceMode,
            selectedKey: music.Key.c,
            selectedScaleType: music.ScaleType.major,
            selectedRootNote: MusicalNote.c,
            selectedArpeggioType: ArpeggioType.major,
            selectedArpeggioOctaves: ArpeggioOctaves.one,
            selectedChordProgression: null,
            selectedChordType: ChordType.major,
            includeInversions: false,
            selectedHandSelection: selectedHandSelection,
            practiceActive: false,
            onResetPractice: () {},
            onPracticeModeChanged: (_) {},
            onKeyChanged: (_) {},
            onScaleTypeChanged: (_) {},
            onRootNoteChanged: (_) {},
            onArpeggioTypeChanged: (_) {},
            onArpeggioOctavesChanged: (_) {},
            onChordProgressionChanged: (_) {},
            onChordTypeChanged: (_) {},
            onIncludeInversionsChanged: (_) {},
            onHandSelectionChanged: onHandSelectionChanged,
          ),
        ),
      );
    }

    group("Hand selection SegmentedButton", () {
      testWidgets("should display all three hand selection options", (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            selectedHandSelection: HandSelection.right,
            onHandSelectionChanged: (_) {},
          ),
        );

        // Verify the segment labels are rendered for user visibility
        // Note: These are not used as selectors for interaction (per guidelines),
        // but we verify they exist for UI completeness
        expect(find.text("Left Hand"), findsOneWidget);
        expect(find.text("Right Hand"), findsOneWidget);
        expect(find.text("Both Hands"), findsOneWidget);
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
        // Note: We trigger the callback programmatically because SegmentedButton
        // does not expose individual segments with Keys for tester.tap().
        // This validates the callback wiring while complying with project
        // guidelines that forbid text-based selectors.
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

      testWidgets("should call onHandSelectionChanged when both hands selected", (
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
        // (See test documentation header for rationale on programmatic approach)
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
      });

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
        // (See test documentation header for rationale on programmatic approach)
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
