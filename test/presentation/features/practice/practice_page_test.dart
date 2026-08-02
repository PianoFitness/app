import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/presentation/features/practice/practice_page.dart";
import "package:piano_fitness/presentation/features/practice/practice_page_view_model.dart";
import "../../../shared/test_helpers/widget_test_helper.dart";
import "../../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);
  tearDownAll(MidiMocks.tearDown);

  group("PracticePage Tests", () {
    testWidgets("should create PracticePage without errors", (tester) async {
      await tester.pumpWidget(createTestWidget(const PracticePage()));
      await tester.pump();

      expect(find.byType(PracticePage), findsOneWidget);
    });

    testWidgets("forwards initial configuration and back tooltip", (
      tester,
    ) async {
      const configuration = ExerciseConfiguration(
        practiceMode: PracticeMode.dominantCadence,
        handSelection: HandSelection.right,
        key: music.Key.d,
      );

      await tester.pumpWidget(
        createTestWidget(
          const PracticePage(
            initialConfiguration: configuration,
            backTooltip: "Back to Technique Tree",
          ),
        ),
      );
      await tester.pump();

      final scaffoldContext = tester.element(
        find.byKey(const ValueKey("practice_page_scaffold")),
      );
      final viewModel = scaffoldContext.read<PracticePageViewModel>();
      expect(
        viewModel.currentConfiguration!.practiceMode,
        PracticeMode.dominantCadence,
      );
      expect(
        viewModel.currentConfiguration!.handSelection,
        HandSelection.right,
      );
      expect(viewModel.currentConfiguration!.key, music.Key.d);
      expect(find.byTooltip("Back to Technique Tree"), findsOneWidget);
    });
  });
}
