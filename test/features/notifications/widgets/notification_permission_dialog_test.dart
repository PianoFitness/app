import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/notifications/widgets/notification_permission_dialog.dart";

void main() {
  group("NotificationPermissionDialog", () {
    testWidgets("displays correct title and content", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationPermissionDialog())),
      );

      // Verify the dialog title is displayed
      expect(find.text("Notifications Disabled"), findsOneWidget);

      // Verify the notification icon is present
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);

      // Verify the main instruction text is displayed
      expect(
        find.text(
          "Notifications were not enabled. To use notification features:",
        ),
        findsOneWidget,
      );
    });

    testWidgets("displays all three instruction steps", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationPermissionDialog())),
      );

      // Verify all three steps are displayed
      expect(find.text("1."), findsOneWidget);
      expect(find.text("Open your device Settings"), findsOneWidget);

      expect(find.text("2."), findsOneWidget);
      expect(find.text("Find Piano Fitness in the app list"), findsOneWidget);

      expect(find.text("3."), findsOneWidget);
      expect(find.text("Enable Notifications"), findsOneWidget);
    });

    testWidgets("displays additional guidance text", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationPermissionDialog())),
      );

      // Verify the guidance text is displayed
      expect(
        find.text(
          "You can always change notification settings later in the Piano Fitness app.",
        ),
        findsOneWidget,
      );
    });

    testWidgets("dismisses dialog when 'I Understand' is tapped", (
      WidgetTester tester,
    ) async {
      bool dialogDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => const NotificationPermissionDialog(),
                  ).then((_) {
                    dialogDismissed = true;
                  });
                },
                child: const Text("Show Dialog"),
              ),
            ),
          ),
        ),
      );

      // Tap to show the dialog
      await tester.tap(find.text("Show Dialog"));
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.text("I Understand"), findsOneWidget);
      expect(dialogDismissed, isFalse);

      // Tap the "I Understand" button
      await tester.tap(find.text("I Understand"));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(dialogDismissed, isTrue);
      expect(find.text("Notifications Disabled"), findsNothing);
    });

    testWidgets("uses proper theme colors", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(body: NotificationPermissionDialog()),
        ),
      );

      // Find the dialog and verify it uses theme colors
      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      final theme = ThemeData.light();

      expect(alertDialog.backgroundColor, equals(theme.colorScheme.surface));
    });
  });
}
