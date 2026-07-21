import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";
import "../../shared/test_helpers/pump_helpers.dart";
import "../../shared/test_helpers/widget_test_helper.dart";

/// Pumps [MainNavigation] at a portrait phone size.
///
/// Most of these tests assert on the portrait bottom-nav-bar layout, so
/// they need an explicit portrait size rather than the test default; see
/// [pumpPortrait] for why.
Future<void> pumpPortraitMainNavigation(WidgetTester tester) async {
  await pumpPortrait(tester, createTestWidget(const MainNavigation()));
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
    expect(
      tester.widget<NavigationBar>(bottomNav).selectedIndex,
      equals(expectedIndex),
    );
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

      // Verify the overflow menu (MIDI/notification settings) is present
      expect(find.byKey(const Key("more_actions_button")), findsOneWidget);

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
      // MIDI Settings and Notification Settings live behind a shared "more"
      // overflow menu (see _buildMoreActionsButton) rather than each having
      // its own app bar icon, so these tests open the menu before asserting
      // on its items.
      testWidgets("should display MIDI settings entry with correct label", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

        await tester.tap(find.byKey(const Key("more_actions_button")));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key("midi_settings_button")), findsOneWidget);
        expect(find.text("MIDI Settings"), findsOneWidget);
      });

      testWidgets("should have an interactive MIDI settings entry", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

        await tester.tap(find.byKey(const Key("more_actions_button")));
        await tester.pumpAndSettle();

        final item = tester.widget<PopupMenuItem<Object?>>(
          find.byKey(const Key("midi_settings_button")),
        );
        expect(item.enabled, isTrue);
      });

      testWidgets(
        "should display notification settings entry with correct label",
        (tester) async {
          await pumpPortraitMainNavigation(tester);

          await tester.tap(find.byKey(const Key("more_actions_button")));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key("notification_settings_button")),
            findsOneWidget,
          );
          expect(find.text("Notification Settings"), findsOneWidget);
        },
      );

      testWidgets("should have an interactive notification settings entry", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

        await tester.tap(find.byKey(const Key("more_actions_button")));
        await tester.pumpAndSettle();

        final item = tester.widget<PopupMenuItem<Object?>>(
          find.byKey(const Key("notification_settings_button")),
        );
        expect(item.enabled, isTrue);
      });

      testWidgets(
        "should maintain the overflow menu's accessibility across all pages",
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

            // Verify the overflow menu is still present and opens with both
            // settings entries.
            expect(
              find.byKey(const Key("more_actions_button")),
              findsOneWidget,
            );
            await tester.tap(find.byKey(const Key("more_actions_button")));
            await tester.pumpAndSettle();
            expect(
              find.byKey(const Key("midi_settings_button")),
              findsOneWidget,
            );
            expect(
              find.byKey(const Key("notification_settings_button")),
              findsOneWidget,
            );
            // Close the menu before navigating to the next tab.
            await tester.tapAt(const Offset(0, 0));
            await tester.pumpAndSettle();
          }
        },
      );
    });

    group("Metronome Quick Access", () {
      testWidgets("should display the metronome button", (tester) async {
        await pumpPortraitMainNavigation(tester);

        final metronomeButton = find.byKey(const Key("metronome_button"));
        expect(metronomeButton, findsOneWidget);
        expect(
          tester.widget<IconButton>(metronomeButton).tooltip,
          equals("Metronome"),
        );
      });

      testWidgets(
        "tapping the metronome button opens the quick panel with controls",
        (tester) async {
          await pumpPortraitMainNavigation(tester);

          await tester.tap(find.byKey(const Key("metronome_button")));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key("metronome_quick_panel")),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key("metronome_start_stop_button")),
            findsOneWidget,
          );
          expect(find.byKey(const Key("metronome_bpm_slider")), findsOneWidget);
        },
      );

      testWidgets(
        "starting the metronome from the quick panel updates the app bar icon",
        (tester) async {
          await pumpPortraitMainNavigation(tester);

          await tester.tap(find.byKey(const Key("metronome_button")));
          await tester.pumpAndSettle();

          await tester.tap(
            find.byKey(const Key("metronome_start_stop_button")),
          );
          await tester.pump();

          // Close the sheet and check the app bar button reflects playing state.
          await tester.tapAt(const Offset(0, 0));
          await tester.pumpAndSettle();

          final metronomeButton = tester.widget<IconButton>(
            find.byKey(const Key("metronome_button")),
          );
          expect(metronomeButton.tooltip, contains("playing"));
        },
      );

      testWidgets("metronome keeps playing when navigating between tabs", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

        await tester.tap(find.byKey(const Key("metronome_button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("metronome_start_stop_button")));
        await tester.pump();
        await tester.tapAt(const Offset(0, 0)); // close the sheet
        await tester.pumpAndSettle();

        await navigateToTab(tester, const Key("nav_tab_reference"));

        final metronomeButton = tester.widget<IconButton>(
          find.byKey(const Key("metronome_button")),
        );
        expect(metronomeButton.tooltip, contains("playing"));

        // Stop it again so the periodic Timer doesn't outlive the test.
        await tester.tap(find.byKey(const Key("metronome_button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("metronome_start_stop_button")));
        await tester.pump();
      });
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

        // The overflow menu button is a PopupMenuButton<_MoreAction>, a
        // type private to main_navigation.dart, so its tooltip is checked
        // via the Tooltip it renders rather than casting to the widget type.
        expect(find.byTooltip("More options"), findsOneWidget);

        // Test the metronome quick-access tooltip using its stable key
        final metronomeButton = find.byKey(const Key("metronome_button"));
        final metronomeWidget = tester.widget<IconButton>(metronomeButton);
        expect(metronomeWidget.tooltip, equals("Metronome"));
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
