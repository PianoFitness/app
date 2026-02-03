import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";
import "../../shared/test_helpers/widget_test_helper.dart";

/// Helper function to navigate to a specific tab by key.
/// This avoids text-based finders and uses stable key-based navigation.
Future<void> navigateToTab(WidgetTester tester, Key tabKey) async {
  final tabFinder = find.byKey(tabKey);
  expect(tabFinder, findsOneWidget);

  await tester.tap(tabFinder);
  await tester.pumpAndSettle();
}

/// Helper function to verify the current tab is active by checking the bottom nav state
void expectTabActive(WidgetTester tester, int expectedIndex) {
  final bottomNav = find.byKey(const Key("bottom_navigation_bar"));
  final bottomNavWidget = tester.widget<BottomNavigationBar>(bottomNav);
  expect(bottomNavWidget.currentIndex, equals(expectedIndex));
}

void main() {
  group("MainNavigation Widget Tests", () {
    testWidgets("should display main navigation with initial content", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const MainNavigation()));
      await tester.pumpAndSettle();

      // Verify app bar with initial page (Free Play) - text appears in both app bar and bottom nav
      expect(find.text("Free Play"), findsWidgets);
      expect(find.byIcon(Icons.piano), findsWidgets);

      // Verify MIDI and notification settings buttons are present using stable keys
      expect(find.byKey(const Key("midi_settings_button")), findsOneWidget);
      expect(
        find.byKey(const Key("notification_settings_button")),
        findsOneWidget,
      );

      // Verify bottom navigation bar and its items using stable key
      expect(find.byKey(const Key("bottom_navigation_bar")), findsOneWidget);
      expect(find.text("Practice"), findsWidgets);
      expect(find.text("Reference"), findsWidgets);
      expect(find.text("Repertoire"), findsWidgets);
    });

    testWidgets("should navigate between bottom navigation pages", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const MainNavigation()));
      await tester.pumpAndSettle();

      // Navigate to Practice tab using stable key
      await navigateToTab(tester, const Key("nav_tab_practice"));

      // Verify page switched to Practice (text appears in both app bar and bottom nav)
      expectTabActive(tester, 1);
      expect(find.text("Practice"), findsWidgets);
      expect(find.byIcon(Icons.school), findsWidgets);

      // Navigate to Reference tab using stable key
      await navigateToTab(tester, const Key("nav_tab_reference"));

      // Verify page switched to Reference
      expectTabActive(tester, 2);
      expect(find.text("Reference"), findsWidgets);
      expect(find.byIcon(Icons.library_books), findsWidgets);

      // Navigate to Repertoire tab using stable key
      await navigateToTab(tester, const Key("nav_tab_repertoire"));

      // Verify page switched to Repertoire
      expectTabActive(tester, 3);
      expect(find.text("Repertoire"), findsWidgets);
      expect(find.byIcon(Icons.library_music), findsWidgets);

      // Navigate back to Free Play using stable key
      await navigateToTab(tester, const Key("nav_tab_free_play"));

      // Verify back to initial state
      expectTabActive(tester, 0);
      expect(find.text("Free Play"), findsWidgets);
      expect(find.byIcon(Icons.piano), findsWidgets);
    });

    group("MIDI Controls Integration", () {
      testWidgets("should display MIDI settings button with correct tooltip", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Find MIDI settings button using stable key
        final settingsButton = find.byKey(const Key("midi_settings_button"));
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
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Verify MIDI settings button is interactive using stable key
        final settingsButton = find.byKey(const Key("midi_settings_button"));
        expect(settingsButton, findsOneWidget);

        final buttonWidget = tester.widget<IconButton>(settingsButton);
        expect(buttonWidget.onPressed, isNotNull);
        expect(buttonWidget.tooltip, equals("MIDI Settings"));
      });

      testWidgets(
        "should display notification settings button with correct tooltip",
        (tester) async {
          await tester.pumpWidget(createTestWidget(const MainNavigation()));
          await tester.pumpAndSettle();

          // Find notification settings button using stable key
          final notificationButton = find.byKey(
            const Key("notification_settings_button"),
          );
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
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Verify notification settings button is interactive using stable key
        final notificationButton = find.byKey(
          const Key("notification_settings_button"),
        );
        expect(notificationButton, findsOneWidget);

        final buttonWidget = tester.widget<IconButton>(notificationButton);
        expect(buttonWidget.onPressed, isNotNull);
        expect(buttonWidget.tooltip, equals("Notification Settings"));
      });

      testWidgets(
        "should maintain MIDI controls accessibility across all pages",
        (tester) async {
          await tester.pumpWidget(createTestWidget(const MainNavigation()));
          await tester.pumpAndSettle();

          final tabKeys = [
            const Key("nav_tab_practice"),
            const Key("nav_tab_reference"),
            const Key("nav_tab_repertoire"),
          ];

          for (final tabKey in tabKeys) {
            // Navigate to page using stable navigation helper
            await navigateToTab(tester, tabKey);

            // Verify MIDI controls are still accessible using stable keys
            expect(
              find.byKey(const Key("midi_settings_button")),
              findsOneWidget,
            );
            expect(
              find.byKey(const Key("notification_settings_button")),
              findsOneWidget,
            );

            // Test that settings button is interactive (without navigating)
            final settingsButton = find.byKey(
              const Key("midi_settings_button"),
            );
            expect(
              tester.widget<IconButton>(settingsButton).onPressed,
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
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Navigate to Practice using stable helper
        await navigateToTab(tester, const Key("nav_tab_practice"));

        // Verify bottom nav shows Practice as selected
        expectTabActive(tester, 1);

        // Navigate to Reference using stable helper
        await navigateToTab(tester, const Key("nav_tab_reference"));

        // Verify state updated
        expectTabActive(tester, 2);
      });

      testWidgets("should use IndexedStack to preserve page state", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Verify IndexedStack is used for page management
        expect(find.byType(IndexedStack), findsOneWidget);

        // Navigate between pages using stable helpers
        await navigateToTab(tester, const Key("nav_tab_practice")); // Practice
        await navigateToTab(
          tester,
          const Key("nav_tab_free_play"),
        ); // Free Play

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
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Find Semantics widgets with header property using predicate
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && (w.properties.header ?? false),
          ),
          findsWidgets,
          reason: "Should have at least one Semantics widget with header=true",
        );
      });

      testWidgets("should provide tooltips for action buttons", (tester) async {
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Test MIDI settings tooltip using stable key
        final settingsButton = find.byKey(const Key("midi_settings_button"));
        final settingsWidget = tester.widget<IconButton>(settingsButton);
        expect(settingsWidget.tooltip, equals("MIDI Settings"));

        // Test notifications tooltip using stable key
        final notificationsButton = find.byKey(
          const Key("notification_settings_button"),
        );
        final notificationsWidget = tester.widget<IconButton>(
          notificationsButton,
        );
        expect(notificationsWidget.tooltip, equals("Notification Settings"));
      });
    });
  });
}
