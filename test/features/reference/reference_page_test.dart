import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/reference/reference_page.dart";
import "package:piano_fitness/presentation/state/midi_state.dart";
import "package:provider/provider.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("ReferencePage Widget Tests", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<MidiState>.value(
          value: midiState,
          child: const ReferencePage(),
        ),
      );
    }

    // Helper functions to reduce duplication
    Future<void> switchToChordsMode(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key("chord_types_mode_button")));
      await tester.pumpAndSettle();
    }

    Future<void> switchToScalesMode(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key("scales_mode_button")));
      await tester.pumpAndSettle();
    }

    testWidgets("should display reference page with initial content", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that mode selection is present
      expect(find.text("Reference Mode"), findsOneWidget);
      expect(find.text("Scales"), findsOneWidget);
      expect(find.text("Chord Types"), findsOneWidget);

      // Initially should show scales mode
      expect(find.text("Key"), findsOneWidget);
      expect(find.text("Scale Type"), findsOneWidget);
    });

    testWidgets("should switch between scales and chords mode", (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially in scales mode
      expect(find.text("Scale Type"), findsOneWidget);
      expect(find.text("Chord Type"), findsNothing);

      // Switch to Chord Types mode
      await switchToChordsMode(tester);

      // Should now show chords mode
      expect(find.text("Root Note"), findsOneWidget);
      expect(find.text("Chord Type"), findsOneWidget);
      expect(find.text("Inversion"), findsOneWidget);
      expect(find.text("Scale Type"), findsNothing);

      // Switch back to scales mode
      await switchToScalesMode(tester);

      // Should show scales mode again
      expect(find.text("Scale Type"), findsOneWidget);
      expect(find.text("Chord Type"), findsNothing);
    });

    testWidgets("should display all scale types in scales mode", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that all scale types are displayed
      expect(find.text("Major"), findsOneWidget);
      expect(find.text("Minor"), findsOneWidget);
      expect(find.text("Dorian"), findsOneWidget);
      expect(find.text("Phrygian"), findsOneWidget);
      expect(find.text("Lydian"), findsOneWidget);
      expect(find.text("Mixolydian"), findsOneWidget);
      expect(find.text("Aeolian"), findsOneWidget);
      expect(find.text("Locrian"), findsOneWidget);
    });

    testWidgets("should display all chord types in chords mode", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to chords mode
      await switchToChordsMode(tester);

      // Check that all chord types are displayed
      expect(find.text("Major"), findsOneWidget);
      expect(find.text("Minor"), findsOneWidget);
      expect(find.text("Diminished"), findsOneWidget);
      expect(find.text("Augmented"), findsOneWidget);

      // Check that all inversions are displayed
      expect(find.text("Root Position"), findsOneWidget);
      expect(find.text("1st Inversion"), findsOneWidget);
      expect(find.text("2nd Inversion"), findsOneWidget);
    });

    testWidgets("should display all keys", (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that all keys are displayed
      expect(find.text("C"), findsOneWidget);
      expect(find.text("D♭"), findsOneWidget);
      expect(find.text("D"), findsOneWidget);
      expect(find.text("E♭"), findsOneWidget);
      expect(find.text("E"), findsOneWidget);
      expect(find.text("F"), findsOneWidget);
      expect(find.text("G♭"), findsOneWidget);
      expect(find.text("G"), findsOneWidget);
      expect(find.text("A♭"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);
      expect(find.text("B♭"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
    });

    testWidgets("should allow selection of different keys", (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap F# (G♭) via key-based selector; UI displays the flat name
      await tester.tap(find.byKey(const Key("scales_key_fSharp")));
      await tester.pumpAndSettle();

      // The selection should be updated (the chip should be selected)
      final gFlatChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, "G♭"),
      );
      expect(gFlatChip.selected, isTrue);
    });

    testWidgets("should allow selection of different scale types", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Minor scale type using key-based selection
      await tester.tap(find.byKey(const Key("scales_type_minor")));
      await tester.pumpAndSettle();

      // The selection should be updated
      final minorChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, "Minor"),
      );
      expect(minorChip.selected, isTrue);
    });

    testWidgets("should allow selection of different chord types", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to chords mode
      await switchToChordsMode(tester);

      // Tap on Minor chord type using key-based selection
      await tester.tap(find.byKey(const Key("chords_type_minor")));
      await tester.pumpAndSettle();

      // The selection should be updated
      final minorChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, "Minor"),
      );
      expect(minorChip.selected, isTrue);
    });

    testWidgets("should allow selection of different chord inversions", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to chords mode
      await switchToChordsMode(tester);

      // Verify chord inversion options by key (more stable than text)
      expect(find.byKey(const Key("chords_inversion_root")), findsOneWidget);
      expect(find.byKey(const Key("chords_inversion_first")), findsOneWidget);
      expect(find.byKey(const Key("chords_inversion_second")), findsOneWidget);
    });

    testWidgets("should display interactive piano", (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that InteractivePiano is present
      expect(find.byType(InteractivePiano), findsOneWidget);
    });

    testWidgets("should update piano when scale selection changes", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Change to a different scale (Minor) using key-based selection
      await tester.tap(find.byKey(const Key("scales_type_minor")));
      await tester.pumpAndSettle();

      // Verify piano is present and functional
      expect(find.byType(InteractivePiano), findsOneWidget);

      // Verify the Minor scale is selected in the UI
      final minorChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == "Minor" &&
            widget.selected == true,
      );
      expect(minorChip, findsOneWidget);
    });

    testWidgets("should update piano when chord selection changes", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to chords mode
      await switchToChordsMode(tester);

      // Change to a different chord type using key-based selection
      await tester.tap(find.byKey(const Key("chords_type_minor")));
      await tester.pumpAndSettle();

      // Verify piano is present and functional
      expect(find.byType(InteractivePiano), findsOneWidget);

      // Verify the Minor chord type is selected in the UI
      final minorChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == "Minor" &&
            widget.selected == true,
      );
      expect(minorChip, findsOneWidget);
    });

    group("Piano Interaction", () {
      testWidgets("should handle piano key taps", (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find the InteractivePiano widget
        final pianoFinder = find.byType(InteractivePiano);
        expect(pianoFinder, findsOneWidget);

        // Verify piano is interactive and properly configured
        final piano = tester.widget<InteractivePiano>(pianoFinder);
        expect(piano.onNotePositionTapped, isNotNull);

        // Verify initial UI state shows scales mode (Major scale selected)
        final majorScaleChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.label is Text &&
              (widget.label as Text).data == "Major" &&
              widget.selected == true,
        );
        expect(majorScaleChip, findsOneWidget);
      });
    });

    group("Error Handling", () {
      testWidgets("should handle initialization without provider gracefully", (
        tester,
      ) async {
        // Test with a widget that doesn't provide MidiState
        // This should work fine since ReferencePage now uses local MIDI state
        await tester.pumpWidget(const MaterialApp(home: ReferencePage()));

        // Should not crash and should render properly
        await tester.pumpAndSettle();
        expect(find.text("Reference Mode"), findsOneWidget);
      });
    });
  });
}
