import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/practice/practice_page.dart";
import "../../shared/test_helpers/widget_test_helper.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);
  tearDownAll(MidiMocks.tearDown);

  group("PracticePage Tests", () {
    testWidgets("should create PracticePage without errors", (tester) async {
      await tester.pumpWidget(createTestWidget(const PracticePage()));
      await tester.pump();

      expect(find.byType(PracticePage), findsOneWidget);
    });
  });
}
