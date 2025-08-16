import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/practice/practice_page.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);
  tearDownAll(MidiMocks.tearDown);

  group("PracticePage Tests", () {
    testWidgets("should create PracticePage without errors", (tester) async {
      const Widget testWidget = MaterialApp(home: PracticePage());

      await tester.pumpWidget(testWidget);
      await tester.pump();

      expect(find.byType(PracticePage), findsOneWidget);
    });
  });
}
