import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:piano_fitness/pages/practice_page.dart";
import "package:piano_fitness/utils/scales.dart" as music;
import "package:piano_fitness/widgets/practice_settings_panel.dart";
import "package:provider/provider.dart";

void main() {
  group("PracticePage Tests", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    Widget createTestWidget(PracticeMode mode) {
      return MaterialApp(
        home: ChangeNotifierProvider<MidiState>.value(
          value: midiState,
          child: PracticePage(initialMode: mode),
        ),
      );
    }

    group("Basic Widget Creation", () {
      testWidgets("should create PracticePage without errors", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        expect(find.byType(PracticePage), findsOneWidget);
      });

      testWidgets("should display practice settings", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));

        expect(find.text("Practice Settings"), findsOneWidget);
        expect(find.text("Practice Mode"), findsOneWidget);
        expect(find.text("Key"), findsOneWidget);
      });

      testWidgets("should show scale type dropdown for scales mode", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));

        expect(find.text("Scale Type"), findsOneWidget);
      });

      testWidgets("should not show scale type dropdown for chords mode", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.chords));

        expect(find.text("Scale Type"), findsNothing);
      });

      testWidgets("should display start and reset buttons", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));

        expect(find.text("Start"), findsOneWidget);
        expect(find.text("Reset"), findsOneWidget);
      });
    });

    group("Practice Mode Selection", () {
      testWidgets("should initialize with correct practice mode", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.chords));
        await tester.pumpAndSettle();

        // Should show chords selected in dropdown
        expect(find.text("Chords"), findsWidgets);
      });

      testWidgets("should change practice mode when dropdown is changed", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Find and tap the practice mode dropdown
        final practiceDropdown = find.ancestor(
          of: find.text("Scales"),
          matching: find.byType(DropdownButtonFormField<PracticeMode>),
        );

        await tester.tap(practiceDropdown);
        await tester.pumpAndSettle();

        // Select chords mode
        await tester.tap(find.text("Chords").last);
        await tester.pumpAndSettle();

        // Scale type dropdown should disappear
        expect(find.text("Scale Type"), findsNothing);
      });
    });

    group("Key Selection", () {
      testWidgets("should display key dropdown with default key", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Find the key dropdown
        final keyDropdown = find.byType(DropdownButtonFormField<music.Key>);
        expect(keyDropdown, findsOneWidget);

        // Should show the default key (C)
        expect(find.text("C"), findsOneWidget);
      });

      testWidgets("should change key when dropdown is changed", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Find the key dropdown and tap it
        final keyDropdown = find.byType(DropdownButtonFormField<music.Key>);
        await tester.tap(keyDropdown);
        await tester.pumpAndSettle();

        // Tap on D key option if available
        final dOption = find.text("D").last;
        if (dOption.evaluate().isNotEmpty) {
          await tester.tap(dOption);
          await tester.pumpAndSettle();

          // Should now display D as selected
          expect(find.text("D"), findsOneWidget);
        }
      });
    });

    group("Scale Type Selection", () {
      testWidgets("should display all available scale types", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Find and tap the scale type dropdown
        final scaleDropdown = find.ancestor(
          of: find.text("Major (Ionian)"),
          matching: find.byType(DropdownButtonFormField<music.ScaleType>),
        );

        await tester.tap(scaleDropdown);
        await tester.pumpAndSettle();

        // Should show all church modes
        expect(find.text("Major (Ionian)"), findsWidgets);
        expect(find.text("Natural Minor"), findsOneWidget);
        expect(find.text("Dorian"), findsOneWidget);
        expect(find.text("Phrygian"), findsOneWidget);
        expect(find.text("Lydian"), findsOneWidget);
        expect(find.text("Mixolydian"), findsOneWidget);
        expect(find.text("Aeolian"), findsOneWidget);
        expect(find.text("Locrian"), findsOneWidget);
      });
    });

    group("Practice Controls", () {
      testWidgets("should enable start button when practice is not active", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Find start button by text
        final startButtonText = find.text("Start");
        expect(startButtonText, findsOneWidget);

        // Button should be enabled (tappable)
        await tester.tap(startButtonText);
        await tester.pumpAndSettle();
      });

      testWidgets("should always enable reset button", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Find reset button by text
        final resetButtonText = find.text("Reset");
        expect(resetButtonText, findsOneWidget);

        // Button should be enabled (tappable)
        await tester.tap(resetButtonText);
        await tester.pumpAndSettle();
      });

      testWidgets("should show progress when practice is started", (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Start practice
        await tester.tap(find.text("Start"));
        await tester.pumpAndSettle();

        // Should show progress indicator
        expect(
          find.text("Progress: 1/15"),
          findsOneWidget,
        ); // C Major scale has 15 notes in full sequence
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets(
        "should show chord progress when practice is started in chord mode",
        (tester) async {
          await tester.pumpWidget(createTestWidget(PracticeMode.chords));
          await tester.pumpAndSettle();

          // Start practice
          await tester.tap(find.text("Start"));
          await tester.pumpAndSettle();

          // Should show chord progress
          expect(
            find.text("Chord 1/28"),
            findsOneWidget,
          ); // 7 chords × 4 positions each (root, 1st, 2nd, 1st)
          expect(find.text("C"), findsWidgets); // Current chord name
          expect(find.byType(LinearProgressIndicator), findsOneWidget);
        },
      );
    });

    group("Piano Integration", () {
      testWidgets("should display interactive piano", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Should have piano widget within consumer (there are multiple)
        expect(find.byType(Consumer<MidiState>), findsWidgets);
      });
    });

    group("Navigation", () {
      testWidgets("should display correct title", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        expect(find.text("Piano Practice"), findsOneWidget);
      });
    });

    group("Error Handling", () {
      testWidgets("should handle null initial mode gracefully", (tester) async {
        // Test with default mode when no initial mode specified
        final widget = MaterialApp(
          home: ChangeNotifierProvider<MidiState>.value(
            value: midiState,
            child: const PracticePage(), // No initial mode specified
          ),
        );

        await tester.pumpWidget(widget);
        expect(find.byType(PracticePage), findsOneWidget);
      });
    });

    group("State Management", () {
      testWidgets("should maintain state when settings change", (tester) async {
        await tester.pumpWidget(createTestWidget(PracticeMode.scales));
        await tester.pumpAndSettle();

        // Start practice
        await tester.tap(find.text("Start"));
        await tester.pumpAndSettle();

        // Change key - should reset practice
        final keyDropdown = find.ancestor(
          of: find.text("C"),
          matching: find.byType(DropdownButtonFormField<music.Key>),
        );

        await tester.tap(keyDropdown);
        await tester.pumpAndSettle();

        await tester.tap(find.text("G"));
        await tester.pumpAndSettle();

        // Practice should be reset (no progress shown)
        expect(find.text("Progress:"), findsNothing);
      });
    });
  });

  group("Music Theory Integration Tests", () {
    testWidgets(
      "should generate correct chord progression for different keys",
      (tester) async {
        final midiState = MidiState();

        final widget = MaterialApp(
          home: ChangeNotifierProvider<MidiState>.value(
            value: midiState,
            child: const PracticePage(initialMode: PracticeMode.chords),
          ),
        );

        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Test C Major progression
        await tester.tap(find.text("Start"));
        await tester.pumpAndSettle();

        expect(find.text("C"), findsWidgets); // Should start with C Major

        // Change to G Major
        final keyDropdown = find.ancestor(
          of: find.text("C"),
          matching: find.byType(DropdownButtonFormField<music.Key>),
        );

        await tester.tap(keyDropdown);
        await tester.pumpAndSettle();

        await tester.tap(find.text("G"));
        await tester.pumpAndSettle();

        // Start G Major progression
        await tester.tap(find.text("Start"));
        await tester.pumpAndSettle();

        expect(find.text("G"), findsWidgets); // Should start with G Major

        midiState.dispose();
      },
    );
  });
}
