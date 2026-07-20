import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as scales;
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "../../../shared/test_helpers/widget_test_helper.dart";
import "../../../shared/midi_mocks.dart";

/// Pumps [widget] at a portrait phone size.
///
/// The default flutter_test viewport (800x600) is landscape-shaped, but
/// these tests assert on the portrait bottom-nav-bar layout, so they need
/// an explicit portrait size rather than the test default.
Future<void> pumpPortrait(WidgetTester tester, Widget widget) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Selects [mode] via the reference page's mode dropdown.
///
/// The dropdowns in the reference page's configuration row are addressed
/// by their generic runtime type (each type appears at most once), and
/// exercised by calling `onChanged` directly rather than opening the
/// dropdown menu overlay and tapping option text, matching this project's
/// convention of avoiding brittle `find.text()`-based interactions.
Future<void> selectReferenceMode(
  WidgetTester tester,
  ReferenceMode mode,
) async {
  final dropdown = tester.widget<DropdownButtonFormField<ReferenceMode>>(
    find.byType(DropdownButtonFormField<ReferenceMode>),
  );
  dropdown.onChanged!(mode);
  await tester.pumpAndSettle();
}

Future<void> selectReferenceKey(WidgetTester tester, scales.Key key) async {
  final dropdown = tester.widget<DropdownButtonFormField<scales.Key>>(
    find.byType(DropdownButtonFormField<scales.Key>),
  );
  dropdown.onChanged!(key);
  await tester.pumpAndSettle();
}

Future<void> selectReferenceScaleType(
  WidgetTester tester,
  scales.ScaleType type,
) async {
  final dropdown = tester.widget<DropdownButtonFormField<scales.ScaleType>>(
    find.byType(DropdownButtonFormField<scales.ScaleType>),
  );
  dropdown.onChanged!(type);
  await tester.pumpAndSettle();
}

Future<void> selectReferenceChordType(
  WidgetTester tester,
  ChordType type,
) async {
  final dropdown = tester.widget<DropdownButtonFormField<ChordType>>(
    find.byType(DropdownButtonFormField<ChordType>),
  );
  dropdown.onChanged!(type);
  await tester.pumpAndSettle();
}

Future<void> selectReferenceChordInversion(
  WidgetTester tester,
  ChordInversion inversion,
) async {
  final dropdown = tester.widget<DropdownButtonFormField<ChordInversion>>(
    find.byType(DropdownButtonFormField<ChordInversion>),
  );
  dropdown.onChanged!(inversion);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("Reference Page Integration Tests", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    Widget createTestApp() {
      // Use the helper variant that allows us to inject a specific MidiState
      // so we can verify it in tests
      return createTestWidgetWithMocks(
        child: const MainNavigation(),
        midiState: midiState,
      );
    }

    testWidgets("should navigate to reference page from main navigation", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestApp());

      // Initially should be on play page - check app bar title specifically
      final playAppBarTitleFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Free Play"),
      );
      expect(playAppBarTitleFinder, findsOneWidget);

      // Verify we have the Reference navigation item in the bottom navigation
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text("Reference"),
        ),
        findsOneWidget,
      );

      // Tap on Reference navigation item
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Should now be on reference page (app bar title and configuration row)
      final appBarTitleFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Reference"),
      );
      expect(appBarTitleFinder, findsOneWidget);
      expect(
        find.byType(DropdownButtonFormField<ReferenceMode>),
        findsOneWidget,
      );
      expect(find.byType(PianoKeyboard), findsOneWidget);
    });

    testWidgets("should maintain reference page state when switching tabs", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestApp());

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Change to chords mode and select F#
      await selectReferenceMode(tester, ReferenceMode.chordTypes);
      await selectReferenceKey(tester, scales.Key.fSharp);

      // Switch to another tab and back
      await tester.tap(find.byKey(const Key("nav_tab_practice")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Should maintain the state (chords mode, F# selected)
      final modeDropdown = tester
          .widget<DropdownButtonFormField<ReferenceMode>>(
            find.byType(DropdownButtonFormField<ReferenceMode>),
          );
      expect(modeDropdown.initialValue, ReferenceMode.chordTypes);

      final keyDropdown = tester.widget<DropdownButtonFormField<scales.Key>>(
        find.byType(DropdownButtonFormField<scales.Key>),
      );
      expect(keyDropdown.initialValue, scales.Key.fSharp);
    });

    testWidgets("should not interfere with MIDI state across app", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestApp());

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Verify initial MIDI state is clean
      expect(midiState.activeNotes.isEmpty, isTrue);

      // Select a specific scale
      await selectReferenceKey(tester, scales.Key.a);
      final keyDropdown = tester.widget<DropdownButtonFormField<scales.Key>>(
        find.byType(DropdownButtonFormField<scales.Key>),
      );
      expect(keyDropdown.initialValue, scales.Key.a);

      await selectReferenceScaleType(tester, scales.ScaleType.minor);
      final scaleTypeDropdown = tester
          .widget<DropdownButtonFormField<scales.ScaleType>>(
            find.byType(DropdownButtonFormField<scales.ScaleType>),
          );
      expect(scaleTypeDropdown.initialValue, scales.ScaleType.minor);

      // The shared MIDI state should NOT be affected by reference page selections
      // (This prevents cross-page interference)
      expect(midiState.activeNotes.isEmpty, isTrue);

      // Switch to play page
      await tester.tap(find.byKey(const Key("nav_tab_free_play")));
      await tester.pumpAndSettle();

      // The MIDI state should still be clean (no interference from reference page)
      expect(midiState.activeNotes.isEmpty, isTrue);
    });

    testWidgets("should handle rapid mode switching", (tester) async {
      await pumpPortrait(tester, createTestApp());

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Rapidly switch between modes
      for (int i = 0; i < 5; i++) {
        await selectReferenceMode(tester, ReferenceMode.chordTypes);
        await selectReferenceMode(tester, ReferenceMode.scales);
      }

      await tester.pumpAndSettle();

      // Should still be functional
      expect(
        find.byType(DropdownButtonFormField<scales.ScaleType>),
        findsOneWidget,
      );
    });

    testWidgets("should handle rapid selection changes", (tester) async {
      await pumpPortrait(tester, createTestApp());

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Rapidly change keys
      for (final key in [
        scales.Key.c,
        scales.Key.d,
        scales.Key.e,
        scales.Key.f,
      ]) {
        await selectReferenceKey(tester, key);
      }

      // Rapidly change scale types
      for (final scaleType in [
        scales.ScaleType.major,
        scales.ScaleType.minor,
      ]) {
        await selectReferenceScaleType(tester, scaleType);
      }

      await tester.pumpAndSettle();

      // Should still be functional - verify UI is working
      expect(find.byType(PianoKeyboard), findsOneWidget);
      expect(
        find.byType(DropdownButtonFormField<scales.ScaleType>),
        findsOneWidget,
      );

      // Clean up any pending timers
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets("should work with all combinations of chord settings", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestApp());

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Switch to chords mode
      await selectReferenceMode(tester, ReferenceMode.chordTypes);

      // Test a key combination
      await selectReferenceKey(tester, scales.Key.c);
      await selectReferenceChordType(tester, ChordType.major);
      await selectReferenceChordInversion(tester, ChordInversion.root);

      // Should have functional UI (no longer testing shared MIDI state)
      expect(find.byType(PianoKeyboard), findsOneWidget);

      // Wait for any pending async operations (e.g., MIDI activity timers)
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();
    });

    testWidgets("should handle bottom navigation edge cases", (tester) async {
      await pumpPortrait(tester, createTestApp());

      // Rapid tab switching
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key("nav_tab_reference")));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byKey(const Key("nav_tab_practice")));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byKey(const Key("nav_tab_free_play")));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should be on Free Play page and app should still be functional
      // Look for Free Play in the app bar title specifically
      final appBarTitleFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Free Play"),
      );
      expect(appBarTitleFinder, findsOneWidget);
    });
  });

  group("Reference Page Performance Tests", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    Widget createTestApp() {
      return createTestWidgetWithMocks(
        child: const MainNavigation(),
        midiState: midiState,
      );
    }

    testWidgets("should handle complex scale selections efficiently", (
      tester,
    ) async {
      await pumpPortrait(tester, createTestApp());

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      await selectReferenceKey(tester, scales.Key.fSharp);
      await selectReferenceScaleType(tester, scales.ScaleType.lydian);
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should complete within reasonable time (1 second is very generous)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Should have functional UI (no longer testing specific MIDI state)
      expect(find.byType(PianoKeyboard), findsOneWidget);

      // Clean up any pending timers
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets("should handle chord inversions efficiently", (tester) async {
      await pumpPortrait(tester, createTestApp());

      // Navigate to reference page
      expect(find.text("Reference"), findsOneWidget);
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Switch to chords mode
      await selectReferenceMode(tester, ReferenceMode.chordTypes);

      final stopwatch = Stopwatch()..start();

      await selectReferenceChordInversion(tester, ChordInversion.first);
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should complete efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      // Should have functional UI - check for reference page AppBar title only
      final appBarTitleFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Reference"),
      );
      expect(appBarTitleFinder, findsOneWidget);
    });
  });
}
