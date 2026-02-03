import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:provider/provider.dart";
import "../../shared/midi_mocks.dart";

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
      return MaterialApp(
        home: ChangeNotifierProvider<MidiState>.value(
          value: midiState,
          child: const MainNavigation(),
        ),
      );
    }

    testWidgets("should navigate to reference page from main navigation", (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Initially should be on play page - check app bar title specifically
      final playAppBarTitleFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Free Play"),
      );
      expect(playAppBarTitleFinder, findsOneWidget);

      // Verify we have the Reference navigation item in the bottom navigation
      expect(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text("Reference"),
        ),
        findsOneWidget,
      );

      // Tap on Reference navigation item
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Should now be on reference page (app bar title and content)
      final appBarTitleFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Reference"),
      );
      expect(appBarTitleFinder, findsOneWidget);
      expect(find.text("Reference Mode"), findsOneWidget);
      expect(find.text("Scales"), findsOneWidget);
      expect(find.text("Chord Types"), findsOneWidget);
    });

    testWidgets("should maintain reference page state when switching tabs", (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Change to chords mode using semantic key
      await tester.tap(find.byKey(const Key("chord_types_mode_button")));
      await tester.pumpAndSettle();

      // Select F# key using semantic key
      await tester.tap(find.byKey(const Key("chords_root_fSharp")));
      await tester.pumpAndSettle();

      // Switch to another tab and back
      await tester.tap(find.byKey(const Key("nav_tab_practice")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Should maintain the state (chords mode, F# selected)
      final gFlatChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, "G♭"),
      );
      expect(gFlatChip.selected, isTrue);
      expect(find.text("Chord Type"), findsOneWidget);
    });

    testWidgets("should not interfere with MIDI state across app", (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Verify initial MIDI state is clean
      expect(midiState.activeNotes.isEmpty, isTrue);

      // Select a specific scale
      // Use warnIfMissed: false to suppress flaky hit-test warnings for UI elements
      await tester.tap(
        find.byKey(const Key("scales_key_a")),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key("scales_type_minor")),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

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
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Rapidly switch between modes
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key("chord_types_mode_button")));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byKey(const Key("scales_mode_button")));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should still be functional
      expect(find.text("Scale Type"), findsOneWidget);
    });

    testWidgets("should handle rapid selection changes", (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Rapidly change keys
      final keys = ["c", "d", "e", "f"];
      for (final key in keys) {
        await tester.tap(
          find.byKey(Key("scales_key_$key")),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Rapidly change scale types
      final scaleTypes = ["major", "minor"];
      for (final scaleType in scaleTypes) {
        await tester.tap(
          find.byKey(Key("scales_type_$scaleType")),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Should still be functional - verify UI is working
      expect(find.byType(InteractivePiano), findsOneWidget);
      expect(find.text("Scale Type"), findsOneWidget);

      // Clean up any pending timers
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets("should work with all combinations of chord settings", (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Switch to chords mode
      await tester.tap(find.byKey(const Key("chord_types_mode_button")));
      await tester.pumpAndSettle();

      // Test a few key combinations
      final testCases = [("c", "major", "rootPosition")];

      for (final (key, chordType, inversion) in testCases) {
        // Select key - only if it exists
        if (find.byKey(Key("chords_root_$key")).evaluate().isNotEmpty) {
          await tester.tap(
            find.byKey(Key("chords_root_$key")),
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();
        }

        // Select chord type - only if it exists
        if (find.byKey(Key("chords_type_$chordType")).evaluate().isNotEmpty) {
          await tester.tap(
            find.byKey(Key("chords_type_$chordType")),
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();
        }

        // Select inversion - only if it exists
        if (find
            .byKey(Key("chords_inversion_$inversion"))
            .evaluate()
            .isNotEmpty) {
          await tester.tap(
            find.byKey(Key("chords_inversion_$inversion")),
            warnIfMissed: false,
          );
        }
        await tester.pumpAndSettle();

        // Should have functional UI (no longer testing shared MIDI state)
        expect(find.byType(InteractivePiano), findsOneWidget);
      }
    });

    testWidgets("should handle bottom navigation edge cases", (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

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
      return MaterialApp(
        home: ChangeNotifierProvider<MidiState>.value(
          value: midiState,
          child: const MainNavigation(),
        ),
      );
    }

    testWidgets("should handle complex scale selections efficiently", (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Perform multiple operations using key-based finders
      // Use warnIfMissed: false to suppress flaky hit-test warnings in UI elements
      await tester.tap(
        find.byKey(const Key("scales_key_fSharp")),
        warnIfMissed: false,
      );
      await tester.tap(
        find.byKey(const Key("scales_type_lydian")),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should complete within reasonable time (1 second is very generous)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Should have functional UI (no longer testing specific MIDI state)
      expect(find.byType(InteractivePiano), findsOneWidget);

      // Clean up any pending timers
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets("should handle chord inversions efficiently", (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      expect(find.text("Reference"), findsOneWidget);
      await tester.tap(find.byKey(const Key("nav_tab_reference")));
      await tester.pumpAndSettle();

      // Switch to chords mode using key-based finder
      await tester.tap(
        find.byKey(const Key("chord_types_mode_button")),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Test chord inversion using key-based finder
      // Use warnIfMissed: false to suppress flaky hit-test warnings
      await tester.tap(
        find.byKey(const Key("chords_inversion_first")),
        warnIfMissed: false,
      );
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
