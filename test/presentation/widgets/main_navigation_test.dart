import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/profile_sort_order.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";

import "../../shared/test_helpers/pump_helpers.dart";
import "../../shared/test_helpers/widget_test_helper.dart";
import "../../shared/test_helpers/mock_repositories.mocks.dart";

Future<void> pumpPortraitMainNavigation(WidgetTester tester) async {
  await pumpPortrait(tester, createTestWidget(const MainNavigation()));
}

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

void expectTabActive(WidgetTester tester, int expectedIndex) {
  final bottomNav = find.byKey(const Key("bottom_navigation_bar"));
  if (bottomNav.evaluate().isNotEmpty) {
    expect(
      tester.widget<NavigationBar>(bottomNav).selectedIndex,
      expectedIndex,
    );
  }
}

void main() {
  group("MainNavigation", () {
    testWidgets("opens on Curriculum with three primary destinations", (
      tester,
    ) async {
      await pumpPortraitMainNavigation(tester);

      expectTabActive(tester, 0);
      expect(find.text("Curriculum"), findsWidgets);
      expect(find.byKey(const Key("nav_tab_curriculum")), findsOneWidget);
      expect(find.byKey(const Key("nav_tab_piano")), findsOneWidget);
      expect(find.byKey(const Key("nav_tab_progress")), findsOneWidget);
      expect(find.byKey(const Key("nav_tab_practice")), findsNothing);
      expect(find.byKey(const Key("nav_tab_reference")), findsNothing);
      expect(find.byKey(const Key("nav_tab_repertoire")), findsNothing);
    });

    testWidgets("moves directly between Curriculum, Piano, and Progress", (
      tester,
    ) async {
      await pumpPortraitMainNavigation(tester);

      await navigateToTab(tester, const Key("nav_tab_piano"));
      expectTabActive(tester, 1);
      expect(find.text("Piano"), findsWidgets);
      expect(find.byKey(const Key("piano_keyboard")), findsOneWidget);
      expect(find.byKey(const Key("piano_show_notes_button")), findsOneWidget);

      await navigateToTab(tester, const Key("nav_tab_progress"));
      expectTabActive(tester, 2);
      expect(find.text("Progress"), findsWidgets);
      expect(find.byKey(const Key("progress_open_curriculum")), findsOneWidget);

      await tester.tap(find.byKey(const Key("progress_open_curriculum")));
      await tester.pumpAndSettle();
      expectTabActive(tester, 0);
    });

    group("Global menu", () {
      testWidgets("contains primary destinations and app-wide utilities", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);
        await openGlobalMenu(tester);

        expect(find.byKey(const Key("drawer_tab_curriculum")), findsOneWidget);
        expect(find.byKey(const Key("drawer_tab_piano")), findsOneWidget);
        expect(find.byKey(const Key("drawer_tab_progress")), findsOneWidget);
        expect(find.byKey(const Key("drawer_metronome")), findsOneWidget);
        expect(find.byKey(const Key("midi_settings_button")), findsOneWidget);
        expect(
          find.byKey(const Key("notification_settings_button")),
          findsOneWidget,
        );
        expect(find.byKey(const Key("profile_button")), findsOneWidget);
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
        "opens MIDI and Progress without unwinding a practice route",
        (tester) async {
          await pumpPortraitMainNavigation(tester);

          await tester.tap(find.byKey(const Key("skill_node_major-scale")));
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const Key("practice_major-scale-c-right")),
          );
          await tester.pumpAndSettle();

          expect(find.text("Practice Session"), findsOneWidget);
          expect(find.byKey(const Key("metronome_button")), findsOneWidget);

          await openGlobalMenu(tester);
          await tester.tap(find.byKey(const Key("midi_settings_button")));
          await tester.pumpAndSettle();

          expect(find.text("MIDI Settings"), findsWidgets);
          expect(
            find.byKey(const Key("global_navigation_menu_button")),
            findsOneWidget,
          );

          await openGlobalMenu(tester);
          await tester.tap(find.byKey(const Key("drawer_tab_progress")));
          await tester.pumpAndSettle();

          expectTabActive(tester, 2);
          expect(find.byKey(const Key("content_back_button")), findsNothing);
        },
      );
    });

    group("Metronome", () {
      testWidgets("is always available and opens its quick controls", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);

        final button = find.byKey(const Key("metronome_button"));
        expect(button, findsOneWidget);
        expect(tester.widget<IconButton>(button).tooltip, "Metronome");

        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key("metronome_quick_panel")), findsOneWidget);
        expect(
          find.byKey(const Key("metronome_start_stop_button")),
          findsOneWidget,
        );
      });

      testWidgets("opens the full view inside the persistent shell", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);
        await tester.tap(find.byKey(const Key("metronome_button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("metronome_open_full_page")));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key("metronome_page")), findsOneWidget);
        expect(find.byKey(const Key("content_back_button")), findsOneWidget);
        expect(
          find.byKey(const Key("global_navigation_menu_button")),
          findsOneWidget,
        );
      });

      testWidgets("keeps playing while switching primary destinations", (
        tester,
      ) async {
        await pumpPortraitMainNavigation(tester);
        await tester.tap(find.byKey(const Key("metronome_button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("metronome_start_stop_button")));
        await tester.pump();
        await tester.tapAt(const Offset(0, 0));
        await tester.pumpAndSettle();

        await navigateToTab(tester, const Key("nav_tab_piano"));
        expect(
          tester
              .widget<IconButton>(find.byKey(const Key("metronome_button")))
              .tooltip,
          contains("playing"),
        );

        await tester.tap(find.byKey(const Key("metronome_button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("metronome_start_stop_button")));
        await tester.pump();
      });
    });

    testWidgets("uses an IndexedStack to preserve three page states", (
      tester,
    ) async {
      await pumpPortraitMainNavigation(tester);
      await navigateToTab(tester, const Key("nav_tab_piano"));

      final stack = tester.widget<IndexedStack>(
        find.byType(IndexedStack).first,
      );
      expect(stack.index, 1);
      expect(stack.children.length, 3);
    });

    testWidgets("resets nested content when the active profile changes", (
      tester,
    ) async {
      final profiles = MockIUserProfileRepository();
      final profileChanges = StreamController<String?>();
      addTearDown(profileChanges.close);
      when(profiles.getActiveProfileId()).thenAnswer((_) async => null);
      when(
        profiles.activeProfileIdChanges,
      ).thenAnswer((_) => profileChanges.stream);
      when(
        profiles.getSortOrder(),
      ).thenAnswer((_) async => ProfileSortOrder.lastActive);
      when(profiles.getAllProfiles()).thenAnswer((_) async => []);

      await pumpPortrait(
        tester,
        createTestWidgetWithMocks(
          child: const MainNavigation(),
          userProfileRepository: profiles,
        ),
      );
      await tester.tap(find.byKey(const Key("skill_node_major-scale")));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key("content_back_button")), findsOneWidget);

      profileChanges.add("new-profile");
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("content_back_button")), findsNothing);
      expect(find.text("Curriculum"), findsWidgets);
    });

    testWidgets("provides semantic headers and global action tooltips", (
      tester,
    ) async {
      await pumpPortraitMainNavigation(tester);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && (widget.properties.header ?? false),
        ),
        findsWidgets,
      );
      expect(find.byTooltip("Open navigation"), findsOneWidget);
      expect(find.byTooltip("Metronome"), findsOneWidget);
    });

    group("Landscape", () {
      testWidgets("uses the drawer instead of a bottom bar", (tester) async {
        await tester.pumpWidget(createTestWidget(const MainNavigation()));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key("bottom_navigation_bar")), findsNothing);
        await openGlobalMenu(tester);
        await navigateToTab(tester, const Key("drawer_tab_piano"));

        final scaffoldState = tester.state<ScaffoldState>(
          find.byKey(const Key("main_navigation_scaffold")),
        );
        expect(scaffoldState.isDrawerOpen, isFalse);
        expect(find.text("Piano"), findsWidgets);
      });
    });
  });
}
