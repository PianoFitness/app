import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/presentation/accessibility/services/musical_announcements_service.dart";

void main() {
  group("MusicalAnnouncementsService Tests", () {
    testWidgets("announces notes change gracefully", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  MusicalAnnouncementsService.announceNotesChange(context, [60, 64]);
                },
                child: const Text("Announce Notes"),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text("Announce Notes"));
      await tester.pumpAndSettle();
      expect(find.text("Announce Notes"), findsOneWidget);
    });

    testWidgets("announces mode change, timer, midi status, practice feedback, general, note, chord, error", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  MusicalAnnouncementsService.announceModeChange(context, PianoMode.practice);
                  MusicalAnnouncementsService.announceTimerChange(context, "Timer Started");
                  MusicalAnnouncementsService.announceMidiStatus(context, "Connected");
                  MusicalAnnouncementsService.announcePracticeFeedback(context, "Great job!");
                  MusicalAnnouncementsService.announceGeneral(context, "General message");
                  MusicalAnnouncementsService.announceNote(context, "C4");
                  MusicalAnnouncementsService.announceChord(context, ["C4", "E4", "G4"]);
                  MusicalAnnouncementsService.announceChord(context, ["C4"]);
                  MusicalAnnouncementsService.announceChord(context, []);
                  MusicalAnnouncementsService.announceStatus(context, "Ready");
                  MusicalAnnouncementsService.announceError(context, "Failed connection");
                },
                child: const Text("Trigger All"),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text("Trigger All"));
      await tester.pumpAndSettle();
      expect(find.text("Trigger All"), findsOneWidget);
    });
  });
}
