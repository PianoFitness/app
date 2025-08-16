import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/widgets/main_navigation.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
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

      // Initially should be on play page
      expect(find.text("Piano Fitness"), findsOneWidget);
      expect(find.text("Free Play Mode"), findsOneWidget);

      // Tap on Reference tab
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Should now be on reference page
      expect(find.text("Reference"), findsOneWidget);
      expect(find.text("Reference Mode"), findsOneWidget);
      expect(find.text("Scales"), findsOneWidget);
      expect(find.text("Chords"), findsOneWidget);
    });

    testWidgets("should maintain reference page state when switching tabs", (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Change to chords mode
      await tester.tap(find.text("Chords"));
      await tester.pumpAndSettle();

      // Select F# key
      await tester.tap(find.text("G♭"));
      await tester.pumpAndSettle();

      // Switch to another tab and back
      await tester.tap(find.text("Practice"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Should maintain the state (chords mode, F# selected)
      final gFlatChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, "G♭"),
      );
      expect(gFlatChip.selected, isTrue);
      expect(find.text("Chord Type"), findsOneWidget);
    });

    testWidgets("should integrate with MIDI state across app", (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Select a specific scale
      await tester.tap(find.text("A"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Minor"));
      await tester.pumpAndSettle();

      // The MIDI state should be updated with the scale notes
      expect(midiState.activeNotes.isNotEmpty, isTrue);

      // Switch to play page
      await tester.tap(find.text("Free Play"));
      await tester.pumpAndSettle();

      // The MIDI state should still contain the highlighted notes
      // (This tests that the reference page doesn't clear the state when disposing)
      expect(midiState.activeNotes.isNotEmpty, isTrue);
    });

    testWidgets("should handle rapid mode switching", (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Rapidly switch between modes
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text("Chords"));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text("Scales"));
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
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Rapidly change keys
      final keys = ["C", "D♭", "D", "E♭", "E", "F"];
      for (final key in keys) {
        await tester.tap(find.text(key));
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Rapidly change scale types
      final scaleTypes = ["Major", "Minor", "Dorian", "Phrygian"];
      for (final scaleType in scaleTypes) {
        await tester.tap(find.text(scaleType));
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Should still be functional and have notes highlighted
      expect(midiState.activeNotes.isNotEmpty, isTrue);
    });

    testWidgets("should work with all combinations of chord settings", (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Switch to chords mode
      await tester.tap(find.text("Chords"));
      await tester.pumpAndSettle();

      // Test a few key combinations
      final testCases = [
        ("C", "Major", "Root Position"),
        ("G♭", "Minor", "1st Inversion"),
        ("A", "Diminished", "2nd Inversion"),
        ("E", "Augmented", "Root Position"),
      ];

      for (final (key, chordType, inversion) in testCases) {
        // Select key
        await tester.tap(find.text(key));
        await tester.pumpAndSettle();

        // Select chord type
        await tester.tap(find.text(chordType));
        await tester.pumpAndSettle();

        // Select inversion
        await tester.tap(find.text(inversion));
        await tester.pumpAndSettle();

        // Should have highlighted notes
        expect(midiState.activeNotes.isNotEmpty, isTrue);
      }
    });

    testWidgets("should handle bottom navigation edge cases", (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Rapid tab switching
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text("Reference"));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text("Practice"));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text("Free Play"));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should be on Free Play page and app should still be functional
      expect(find.text("Free Play Mode"), findsOneWidget);
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
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Perform multiple operations
      await tester.tap(find.text("G♭"));
      await tester.tap(find.text("Lydian"));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should complete within reasonable time (1 second is very generous)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Should have the correct notes highlighted
      expect(midiState.activeNotes.length, equals(21)); // 7 notes × 3 octaves
    });

    testWidgets("should handle chord inversions efficiently", (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to reference page
      await tester.tap(find.text("Reference"));
      await tester.pumpAndSettle();

      // Switch to chords mode
      await tester.tap(find.text("Chords"));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Test all inversions rapidly
      await tester.tap(find.text("1st Inversion"));
      await tester.pump();
      await tester.tap(find.text("2nd Inversion"));
      await tester.pump();
      await tester.tap(find.text("Root Position"));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should complete efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      // Should have notes highlighted
      expect(midiState.activeNotes.isNotEmpty, isTrue);
    });
  });
}
