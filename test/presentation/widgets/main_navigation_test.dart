import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";
import "../../shared/test_helpers/widget_test_helper.dart";

/// Pumps [MainNavigation] at a portrait phone size.
///
/// The default flutter_test viewport (800x600) is landscape-shaped, but
/// most of these tests assert on the portrait bottom-nav-bar layout, so
/// they need an explicit portrait size rather than the test default.
Future<void> pumpPortraitMainNavigation(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(createTestWidget(const MainNavigation()));
  await tester.pumpAndSettle();
}

/// Helper function to navigate to a specific tab by key.
/// This avoids text-based finders and uses stable key-based navigation.
Future<void> navigateToTab(WidgetTester tester, Key tabKey) async {
  final tabFinder = find.byKey(tabKey);
  expect(tabFinder, findsOneWidget);

  await tester.tap(tabFinder);
  await tester.pumpAndSettle();
}

/// Page titles in MainNavigation's tab order, mirrored here since the
/// app's own list is private to the widget.
const List<String> _pageTitlesForTest = [
  "Free Play",
  "Practice",
  "Reference",
  "Repertoire",
  "History",
];

/// Helper function to verify the current tab is active.
///
/// MainNavigation shows a bottom [NavigationBar] in portrait, whose
/// `selectedIndex` can be read directly. In landscape, navigation is a
/// [Drawer] that closes itself after a selection, so there's no persistent
/// widget state to read; the AppBar title (which always reflects the
/// active page) is checked instead.
void expectTabActive(WidgetTester tester, int expectedIndex) {
  final bottomNav = find.byKey(const Key("bottom_navigation_bar"));
  if (bottomNav.evaluate().isNotEmpty) {
    expect(tester.widget<NavigationBar>(bottomNav).selectedIndex, equals(expectedIndex));
    return;
  }
  expect(
    find.widgetWithText(AppBar, _pageTitlesForTest[expectedIndex]),
    findsOneWidget,
  );
}

void main() {
  group("MainNavigation Widget Tests", () {
    testWidgets("should display main navigation with initial content", (
      tester,
    ) async {
      await pumpPortraitMainNavigation(tester);

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
      await pumpPortraitMainNavigation(tester);

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
        await pumpPortraitMainNavigation(tester);

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
        await pumpPortraitMainNavigation(tester);

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
          await pumpPortraitMainNavigation(tester);

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
        await pumpPortraitMainNavigation(tester);

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
          await pumpPortraitMainNavigation(tester);

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
        await pumpPortraitMainNavigation(tester);

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
        await pumpPortraitMainNavigation(tester);

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
        expect(indexedStack.children.length, equals(5));

        // Navigate to History tab and verify IndexedStack index updates
        await navigateToTab(tester, const Key("nav_tab_history"));
        final historyStack = tester.widget<IndexedStack>(
          find.byType(IndexedStack),
        );
        expect(historyStack.index, equals(4));
      });
    });

    group("Accessibility", () {
      testWidgets("should have proper semantic headers for page titles", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

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
        await pumpPortraitMainNavigation(tester);

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

    // Note: Profile button tests removed due to FutureBuilder complexity in testing
    // The profile button functionality is indirectly tested through integration tests
    // and the profile button implementation is simple and stable

    group("Landscape Layout", () {
      testWidgets(
        "should hide navigation behind a drawer instead of a bottom bar",
        (tester) async {
          // The default flutter_test viewport (800x600) is landscape-shaped.
          await tester.pumpWidget(createTestWidget(const MainNavigation()));
          await tester.pumpAndSettle();

          // No persistent nav bar taking up space; content gets full width.
          expect(find.byKey(const Key("bottom_navigation_bar")), findsNothing);
          // The drawer exists (for the edge-swipe gesture) but starts closed.
          final scaffoldState = tester.state<ScaffoldState>(
            find.byKey(const Key("main_navigation_scaffold")),
          );
          expect(scaffoldState.isDrawerOpen, isFalse);
        },
      );

      testWidgets("should navigate between pages via the drawer", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        // Open the drawer via the AppBar's automatic menu button.
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key("navigation_drawer")), findsOneWidget);

        await navigateToTab(tester, const Key("nav_tab_practice"));

        // Selecting a destination closes the drawer again.
        final scaffoldState = tester.state<ScaffoldState>(
          find.byKey(const Key("main_navigation_scaffold")),
        );
        expect(scaffoldState.isDrawerOpen, isFalse);
        expectTabActive(tester, 1);
        expect(find.byIcon(Icons.school), findsWidgets);
      });
    });
  });
}
