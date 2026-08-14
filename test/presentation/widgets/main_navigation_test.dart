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

Future<void> openGlobalMenu(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key("global_navigation_menu_button")));
  await tester.pumpAndSettle();
}

/// Page titles in MainNavigation's tab order, mirrored here since the
/// app's own list is private to the widget.
const List<String> _pageTitlesForTest = [
  "Curriculum",
  "Practice",
  "Free Play",
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

      // Curriculum is the app's north-star experience and default page.
      expectTabActive(tester, 0);
      expect(find.text("Curriculum"), findsWidgets);
      expect(find.byIcon(Icons.menu_book), findsWidgets);

      expect(
        find.byKey(const Key("global_navigation_menu_button")),
        findsOneWidget,
      );

      // Verify bottom navigation bar and its items using stable key
      expect(find.byKey(const Key("bottom_navigation_bar")), findsOneWidget);
      expect(find.text("Practice"), findsWidgets);
      expect(find.text("Curriculum"), findsWidgets);
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

      // Navigate to Curriculum using stable key
      await navigateToTab(tester, const Key("nav_tab_curriculum"));

      expectTabActive(tester, 0);
      expect(find.text("Curriculum"), findsWidgets);
      expect(find.byIcon(Icons.menu_book), findsWidgets);

      // Navigate to Reference tab using stable key
      await navigateToTab(tester, const Key("nav_tab_reference"));

      // Verify page switched to Reference
      expectTabActive(tester, 3);
      expect(find.text("Reference"), findsWidgets);
      expect(find.byIcon(Icons.library_books), findsWidgets);

      // Navigate to Repertoire tab using stable key
      await navigateToTab(tester, const Key("nav_tab_repertoire"));

      // Verify page switched to Repertoire
      expectTabActive(tester, 4);
      expect(find.text("Repertoire"), findsWidgets);
      expect(find.byIcon(Icons.library_music), findsWidgets);

      // Navigate back to Free Play using stable key
      await navigateToTab(tester, const Key("nav_tab_free_play"));

      // Verify Free Play is available as a secondary destination.
      expectTabActive(tester, 2);
      expect(find.text("Free Play"), findsWidgets);
      expect(find.byIcon(Icons.piano), findsWidgets);
    });

    group("Global Menu", () {
      testWidgets("shows sections and app-wide utilities", (tester) async {
        await pumpPortraitMainNavigation(tester);

        await openGlobalMenu(tester);

        expect(find.byKey(const Key("midi_settings_button")), findsOneWidget);
        expect(find.text("MIDI Settings"), findsOneWidget);
        expect(
          find.byKey(const Key("notification_settings_button")),
          findsOneWidget,
        );
        expect(find.byKey(const Key("profile_button")), findsOneWidget);
        expect(find.byKey(const Key("drawer_metronome")), findsOneWidget);
        expect(find.byKey(const Key("drawer_tab_history")), findsOneWidget);
      });

      testWidgets("stays available across all primary sections", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

        final tabKeys = [
          const Key("nav_tab_practice"),
          const Key("nav_tab_free_play"),
          const Key("nav_tab_reference"),
          const Key("nav_tab_repertoire"),
          const Key("nav_tab_history"),
        ];

        for (final tabKey in tabKeys) {
          await navigateToTab(tester, tabKey);
          expect(
            find.byKey(const Key("global_navigation_menu_button")),
            findsOneWidget,
          );
        }
      });

      testWidgets("opens profile switching inside the persistent shell", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

        await openGlobalMenu(tester);
        await tester.tap(find.byKey(const Key("profile_button")));
        await tester.pumpAndSettle();

        expect(find.text("Profiles"), findsOneWidget);
        expect(find.text("Create Profile"), findsWidgets);
        expect(find.byKey(const Key("content_back_button")), findsOneWidget);
        expect(
          find.byKey(const Key("global_navigation_menu_button")),
          findsOneWidget,
        );
      });

      testWidgets(
        "remains available from curriculum detail and practice routes",
        (tester) async {
          await pumpPortraitMainNavigation(tester);

          await tester.tap(find.byKey(const Key("skill_node_major-scale")));
          await tester.pumpAndSettle();

          expect(find.text("Major scale"), findsOneWidget);
          expect(find.byKey(const Key("content_back_button")), findsOneWidget);
          expect(
            find.byKey(const Key("global_navigation_menu_button")),
            findsOneWidget,
          );
          expect(find.byKey(const Key("metronome_button")), findsOneWidget);

          await tester.tap(
            find.byKey(const Key("practice_major-scale-c-right")),
          );
          await tester.pumpAndSettle();

          expect(find.text("Practice Session"), findsOneWidget);
          expect(
            find.byKey(const Key("global_navigation_menu_button")),
            findsOneWidget,
          );
          expect(find.byKey(const Key("metronome_button")), findsOneWidget);

          await openGlobalMenu(tester);
          expect(find.byKey(const Key("midi_settings_button")), findsOneWidget);
          expect(find.byKey(const Key("profile_button")), findsOneWidget);

          await tester.tap(find.byKey(const Key("midi_settings_button")));
          await tester.pumpAndSettle();

          expect(find.text("MIDI Settings"), findsWidgets);
          expect(
            find.byKey(const Key("global_navigation_menu_button")),
            findsOneWidget,
          );

          await openGlobalMenu(tester);
          await tester.tap(find.byKey(const Key("drawer_tab_history")));
          await tester.pumpAndSettle();

          expectTabActive(tester, 5);
          expect(find.byKey(const Key("content_back_button")), findsNothing);
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

      testWidgets(
        "opening the full view from the quick panel navigates to MetronomePage",
        (tester) async {
          await pumpPortraitMainNavigation(tester);

          await tester.tap(find.byKey(const Key("metronome_button")));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key("metronome_open_full_page")));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key("metronome_quick_panel")), findsNothing);
          expect(find.byKey(const Key("metronome_page")), findsOneWidget);
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
        expectTabActive(tester, 3);
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
        expect(indexedStack.index, equals(2));
        expect(indexedStack.children.length, equals(6));

        // Navigate to History tab and verify IndexedStack index updates
        await navigateToTab(tester, const Key("nav_tab_history"));
        final historyStack = tester.widget<IndexedStack>(
          find.byType(IndexedStack),
        );
        expect(historyStack.index, equals(5));
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

        expect(find.byTooltip("Open navigation"), findsOneWidget);

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

        await openGlobalMenu(tester);
        expect(find.byKey(const Key("navigation_drawer")), findsOneWidget);

        await navigateToTab(tester, const Key("drawer_tab_practice"));

        // Selecting a destination closes the drawer again.
        final scaffoldState = tester.state<ScaffoldState>(
          find.byKey(const Key("main_navigation_scaffold")),
        );
        expect(scaffoldState.isDrawerOpen, isFalse);
        expectTabActive(tester, 1);
        expect(find.text("Practice"), findsWidgets);
      });
    });
  });
}
