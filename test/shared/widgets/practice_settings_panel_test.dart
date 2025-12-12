import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;
import "package:piano_fitness/shared/widgets/practice_settings_panel.dart";

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

        // Find all three buttons
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
        final segmentedButton =
            find.byType(SegmentedButton<HandSelection>).evaluate().first.widget
                as SegmentedButton<HandSelection>;

        // Verify right hand is selected
        expect(segmentedButton.selected, equals({HandSelection.right}));
      });

      testWidgets(
        "should call onHandSelectionChanged when left hand selected",
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

          // Get the SegmentedButton widget to trigger selection directly
          final segmentedButton =
              find
                      .byType(SegmentedButton<HandSelection>)
                      .evaluate()
                      .first
                      .widget
                  as SegmentedButton<HandSelection>;

          // Programmatically trigger the selection callback
          segmentedButton.onSelectionChanged!({HandSelection.left});
          await tester.pumpAndSettle();

          // Verify callback was called with correct value
          expect(capturedSelection, equals(HandSelection.left));
        },
      );

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

          // Get the SegmentedButton widget to trigger selection directly
          final segmentedButton =
              find
                      .byType(SegmentedButton<HandSelection>)
                      .evaluate()
                      .first
                      .widget
                  as SegmentedButton<HandSelection>;

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
          final segmentedButton =
              find
                      .byType(SegmentedButton<HandSelection>)
                      .evaluate()
                      .first
                      .widget
                  as SegmentedButton<HandSelection>;

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

        // Find the SegmentedButton
        final segmentedButton =
            find.byType(SegmentedButton<HandSelection>).evaluate().first.widget
                as SegmentedButton<HandSelection>;

        // Verify showSelectedIcon is false
        expect(segmentedButton.showSelectedIcon, equals(false));

        // Verify no checkmark icons are present
        expect(find.byIcon(Icons.check), findsNothing);
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

        // Initial state
        var segmentedButton =
            find.byType(SegmentedButton<HandSelection>).evaluate().first.widget
                as SegmentedButton<HandSelection>;
        expect(segmentedButton.selected, equals({HandSelection.right}));

        // Programmatically trigger left hand selection
        segmentedButton.onSelectionChanged!({HandSelection.left});
        await tester.pumpAndSettle();

        // Rebuild and verify selection changed
        segmentedButton =
            find.byType(SegmentedButton<HandSelection>).evaluate().first.widget
                as SegmentedButton<HandSelection>;
        expect(segmentedButton.selected, equals({HandSelection.left}));
      });
    });
  });
}
