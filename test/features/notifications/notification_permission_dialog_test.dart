import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/notifications/widgets/notification_permission_dialog.dart";

void main() {
  group("NotificationPermissionDialog", () {
    testWidgets("renders dialog with correct title and steps", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const NotificationPermissionDialog(),
                );
              },
              child: const Text("Show Dialog"),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text("Show Dialog"));
      await tester.pumpAndSettle();

      // Check title
      expect(find.text("Notifications Disabled"), findsOneWidget);
      // Check steps
      expect(find.text("Open your device Settings"), findsOneWidget);
      expect(find.text("Find Piano Fitness in the app list"), findsOneWidget);
      expect(find.text("Enable Notifications"), findsOneWidget);
      // Check info text
      expect(
        find.textContaining(
          "You can always change notification settings later",
        ),
        findsOneWidget,
      );
      // Check button
      expect(find.text("I Understand"), findsOneWidget);
    });

    testWidgets("scrolls content if needed", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const NotificationPermissionDialog(),
                );
              },
              child: const Text("Show Dialog"),
            ),
          ),
        ),
      );
      await tester.tap(find.text("Show Dialog"));
      await tester.pumpAndSettle();
      // Try to scroll the dialog content
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);
    });
  });
}
