import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/presentation/accessibility/services/piano_semantics_service.dart";

void main() {
  group("PianoSemanticsService Tests", () {
    test(
      "getKeyboardDescription returns correct label with highlighted notes",
      () {
        final desc = PianoSemanticsService.getKeyboardDescription(
          PianoMode.practice,
          [60, 64, 67],
        );
        expect(desc, contains("Practice mode"));
        expect(desc, contains("C4"));
        expect(desc, contains("E4"));
        expect(desc, contains("G4"));
      },
    );

    test(
      "getKeyboardDescription returns correct description when no notes highlighted",
      () {
        final desc = PianoSemanticsService.getKeyboardDescription(
          PianoMode.play,
          [],
        );
        expect(desc, contains("No notes highlighted"));
      },
    );

    test(
      "getKeyboardLabel and getKeyboardHint return mode specific strings",
      () {
        final label = PianoSemanticsService.getKeyboardLabel(
          PianoMode.reference,
        );
        final hint = PianoSemanticsService.getKeyboardHint(PianoMode.reference);

        expect(label, isNotEmpty);
        expect(hint, isNotEmpty);
      },
    );

    test("getKeyDescription handles active and inactive keys", () {
      final activeKey = PianoSemanticsService.getKeyDescription(60, true);
      final inactiveKey = PianoSemanticsService.getKeyDescription(60, false);

      expect(activeKey, contains("C4"));
      expect(activeKey, contains("highlighted"));
      expect(inactiveKey, contains("C4"));
    });

    test("getNotesChangeAnnouncement builds note string", () {
      final announcement = PianoSemanticsService.getNotesChangeAnnouncement([
        60,
        62,
      ]);
      expect(announcement, contains("C4"));
      expect(announcement, contains("D4"));
    });

    testWidgets("createAccessibleWrapper wraps child with Semantics widget", (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PianoSemanticsService.createAccessibleWrapper(
            child: const Text("Keyboard Child"),
            mode: PianoMode.practice,
            highlightedMidiNotes: [60],
          ),
        ),
      );

      expect(find.text("Keyboard Child"), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
