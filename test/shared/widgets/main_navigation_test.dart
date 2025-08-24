import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/widgets/main_navigation.dart";

void main() {
  group("MainNavigation Widget Tests", () {
    testWidgets("should display main navigation with initial content", (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
      await tester.pumpAndSettle();

      // Verify app bar with initial page (Free Play) - text appears in both app bar and bottom nav
      expect(find.text("Free Play"), findsWidgets);
      expect(find.byIcon(Icons.piano), findsWidgets);

      // Verify MIDI and notification settings buttons are present
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      // Verify bottom navigation bar and its items
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text("Practice"), findsWidgets);
      expect(find.text("Reference"), findsWidgets);
      expect(find.text("Repertoire"), findsWidgets);
    });

    testWidgets("should navigate between bottom navigation pages", (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
      await tester.pumpAndSettle();

      // Tap Practice tab
      await tester.tap(find.text("Practice"));
      await tester.pumpAndSettle();

      // Verify page switched to Practice (text appears in both app bar and bottom nav)
      expect(find.text("Practice"), findsWidgets);
      expect(find.byIcon(Icons.school), findsWidgets);

      // Tap Reference tab
      await tester.tap(find.text("Reference").last);
      await tester.pumpAndSettle();

      // Verify page switched to Reference
      expect(find.text("Reference"), findsWidgets);
      expect(find.byIcon(Icons.library_books), findsWidgets);

      // Tap Repertoire tab
      await tester.tap(find.text("Repertoire").last);
      await tester.pumpAndSettle();

      // Verify page switched to Repertoire
      expect(find.text("Repertoire"), findsWidgets);
      expect(find.byIcon(Icons.library_music), findsWidgets);

      // Tap back to Free Play
      await tester.tap(find.text("Free Play").last);
      await tester.pumpAndSettle();

      // Verify back to initial state
      expect(find.text("Free Play"), findsWidgets);
      expect(find.byIcon(Icons.piano), findsWidgets);
    });

    group("MIDI Controls Integration", () {
      testWidgets("should display MIDI settings button with correct tooltip", (
        tester,
      ) async {
        await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
        await tester.pumpAndSettle();

        // Find MIDI settings button
        final settingsButton = find.byIcon(Icons.settings);
        expect(settingsButton, findsOneWidget);

        // Verify tooltip
        await tester.longPress(settingsButton);
        await tester.pumpAndSettle();
        expect(find.text("MIDI Settings"), findsOneWidget);

        // Dismiss tooltip
        await tester.tapAt(const Offset(0, 0));
        await tester.pumpAndSettle();
      });

      testWidgets("should have interactive MIDI settings button", (
        tester,
      ) async {
        await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
        await tester.pumpAndSettle();

        // Verify MIDI settings button is interactive
        final settingsButton = find.ancestor(
          of: find.byIcon(Icons.settings),
          matching: find.byType(IconButton),
        );
        expect(settingsButton, findsOneWidget);

        final buttonWidget = tester.widget<IconButton>(settingsButton);
        expect(buttonWidget.onPressed, isNotNull);
        expect(buttonWidget.tooltip, equals("MIDI Settings"));
      });

      testWidgets(
        "should display notification settings button with correct tooltip",
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
          await tester.pumpAndSettle();

          // Find notification settings button
          final notificationButton = find.byIcon(Icons.notifications);
          expect(notificationButton, findsOneWidget);

          // Verify tooltip
          await tester.longPress(notificationButton);
          await tester.pumpAndSettle();
          expect(find.text("Notification Settings"), findsOneWidget);

          // Dismiss tooltip
          await tester.tapAt(const Offset(0, 0));
          await tester.pumpAndSettle();
        },
      );

      testWidgets("should have interactive notification settings button", (
        tester,
      ) async {
        await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
        await tester.pumpAndSettle();

        // Verify notification settings button is interactive
        final notificationButton = find.ancestor(
          of: find.byIcon(Icons.notifications),
          matching: find.byType(IconButton),
        );
        expect(notificationButton, findsOneWidget);

        final buttonWidget = tester.widget<IconButton>(notificationButton);
        expect(buttonWidget.onPressed, isNotNull);
        expect(buttonWidget.tooltip, equals("Notification Settings"));
      });

      testWidgets(
        "should maintain MIDI controls accessibility across all pages",
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
          await tester.pumpAndSettle();

          final pages = ["Practice", "Reference", "Repertoire"];

          for (final pageName in pages) {
            // Navigate to page using bottom nav (last occurrence of text)
            await tester.tap(find.text(pageName).last);
            await tester.pumpAndSettle();

            // Verify MIDI controls are still accessible
            expect(find.byIcon(Icons.settings), findsOneWidget);
            expect(find.byIcon(Icons.notifications), findsOneWidget);

            // Test that settings button is interactive (without navigating)
            final settingsButton = find.byIcon(Icons.settings);
            expect(
              tester
                  .widget<IconButton>(
                    find.ancestor(
                      of: settingsButton,
                      matching: find.byType(IconButton),
                    ),
                  )
                  .onPressed,
              isNotNull,
            );
          }
        },
      );
    });

    group("Navigation State Management", () {
      testWidgets("should preserve bottom navigation state correctly", (
        tester,
      ) async {
        await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
        await tester.pumpAndSettle();

        // Navigate to Practice
        await tester.tap(find.text("Practice"));
        await tester.pumpAndSettle();

        // Verify bottom nav shows Practice as selected
        final bottomNav = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNav.currentIndex, equals(1));

        // Navigate to Reference
        await tester.tap(find.text("Reference"));
        await tester.pumpAndSettle();

        // Verify state updated
        final updatedBottomNav = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(updatedBottomNav.currentIndex, equals(2));
      });

      testWidgets("should use IndexedStack to preserve page state", (
        tester,
      ) async {
        await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
        await tester.pumpAndSettle();

        // Verify IndexedStack is used for page management
        expect(find.byType(IndexedStack), findsOneWidget);

        // Navigate between pages
        await tester.tap(find.text("Practice"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Free Play"));
        await tester.pumpAndSettle();

        // IndexedStack should preserve state of all pages
        final indexedStack = tester.widget<IndexedStack>(
          find.byType(IndexedStack),
        );
        expect(indexedStack.index, equals(0));
        expect(indexedStack.children.length, equals(4));
      });
    });

    group("Accessibility", () {
      testWidgets("should have proper semantic headers for page titles", (
        tester,
      ) async {
        await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
        await tester.pumpAndSettle();

        // Find all semantic widgets
        final semanticsWidgets = find.byType(Semantics);
        expect(semanticsWidgets, findsWidgets);

        // Look for a Semantics widget with header property set
        bool foundHeader = false;
        for (int i = 0; i < tester.widgetList(semanticsWidgets).length; i++) {
          final semanticsWidget = tester
              .widgetList<Semantics>(semanticsWidgets)
              .elementAt(i);
          if (semanticsWidget.properties.header == true) {
            foundHeader = true;
            break;
          }
        }
        expect(
          foundHeader,
          isTrue,
          reason: "Should have at least one Semantics widget with header=true",
        );
      });

      testWidgets("should provide tooltips for action buttons", (tester) async {
        await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
        await tester.pumpAndSettle();

        // Test MIDI settings tooltip
        final settingsButton = find.ancestor(
          of: find.byIcon(Icons.settings),
          matching: find.byType(IconButton),
        );
        final settingsWidget = tester.widget<IconButton>(settingsButton);
        expect(settingsWidget.tooltip, equals("MIDI Settings"));

        // Test notifications tooltip
        final notificationsButton = find.ancestor(
          of: find.byIcon(Icons.notifications),
          matching: find.byType(IconButton),
        );
        final notificationsWidget = tester.widget<IconButton>(
          notificationsButton,
        );
        expect(notificationsWidget.tooltip, equals("Notification Settings"));
      });
    });
  });
}
