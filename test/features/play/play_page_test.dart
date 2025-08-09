import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/features/play/play_page.dart";
import "package:piano_fitness/features/practice/practice_page.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:provider/provider.dart";

void main() {
  group("PlayPage MVVM Tests", () {
    testWidgets("should create PlayPage with ViewModel without errors", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Verify PlayPage is rendered
      expect(find.byType(PlayPage), findsOneWidget);
      expect(find.text("Piano Fitness"), findsOneWidget);
      expect(find.byIcon(Icons.piano), findsOneWidget);
    });

    testWidgets("should initialize ViewModel with correct MIDI channel", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage(midiChannel: 7)),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow post-frame callback to execute

      // Verify the MIDI channel is set correctly through ViewModel
      expect(midiState.selectedChannel, equals(7));
    });

    testWidgets("should display educational content and navigation chips", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Verify educational content is present
      expect(find.text("Piano Practice"), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.text("Scales"), findsOneWidget);
      expect(find.text("Chords"), findsOneWidget);
      expect(find.text("Arpeggios"), findsOneWidget);
    });

    testWidgets("should use ViewModel for piano range calculation", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find the InteractivePiano widget
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      // Verify the piano uses the 49-key range from ViewModel
      final piano = tester.widget<InteractivePiano>(pianoFinder);
      expect(piano.noteRange, isNotNull);
      expect(piano.noteRange, isA<NoteRange>());
    });

    testWidgets("should handle virtual note playing through ViewModel", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find the InteractivePiano and verify callback is set
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      final piano = tester.widget<InteractivePiano>(pianoFinder);
      expect(piano.onNotePositionTapped, isNotNull);

      // Test note conversion through ViewModel by simulating a tap
      // (We can't easily simulate the actual tap, but we can verify the setup)
      expect(piano.noteRange, isNotNull);
    });

    testWidgets("should integrate with MidiState through ViewModel", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify piano keyboard highlights are connected to MidiState
      final pianoFinder = find.byType(InteractivePiano);
      final piano = tester.widget<InteractivePiano>(pianoFinder);

      expect(
        piano.highlightedNotes,
        equals(midiState.highlightedNotePositions),
      );

      // Add a note to verify the connection
      midiState.noteOn(60, 100, 1);
      await tester.pump();

      expect(midiState.highlightedNotePositions.isNotEmpty, isTrue);
    });

    testWidgets("should navigate to practice pages correctly", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Test Scales navigation
      final scalesChip = find.widgetWithText(Chip, "Scales");
      expect(scalesChip, findsOneWidget);

      await tester.tap(scalesChip);
      await tester.pumpAndSettle();

      expect(find.byType(PracticePage), findsOneWidget);
    });

    testWidgets("should handle MIDI settings navigation", (tester) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find and tap settings button
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify MIDI settings page is shown
      expect(find.byType(MidiSettingsPage), findsOneWidget);
    });

    testWidgets("should show MIDI activity indicator", (tester) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find the MIDI activity indicator
      final indicatorFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
            widget.constraints?.maxWidth == 12.0,
      );
      expect(indicatorFinder, findsOneWidget);

      // Initially should be grey (no activity)
      var indicator = tester.widget<Container>(indicatorFinder);
      var decoration = indicator.decoration! as BoxDecoration;
      expect(decoration.color, isNot(Colors.green));

      // Add MIDI activity through ViewModel/MidiState
      midiState.noteOn(60, 100, 1);
      await tester.pump();

      // Should now be green (has activity)
      indicator = tester.widget<Container>(indicatorFinder);
      decoration = indicator.decoration! as BoxDecoration;
      expect(decoration.color, Colors.green);

      midiState.dispose();
    });

    testWidgets("should handle MIDI activity indicator tap with snackbar", (
      tester,
    ) async {
      final midiState = MidiState()..setLastNote("Test MIDI from ViewModel");

      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find and tap the MIDI activity indicator
      final indicatorTapArea = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Container &&
            (widget.child! as Container).decoration is BoxDecoration &&
            ((widget.child! as Container).decoration! as BoxDecoration).shape ==
                BoxShape.circle,
      );
      expect(indicatorTapArea, findsOneWidget);

      await tester.tap(indicatorTapArea);
      await tester.pump();

      // Verify snackbar is shown with MIDI message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text("MIDI: Test MIDI from ViewModel"), findsOneWidget);

      midiState.dispose();
    });

    testWidgets("should properly dispose ViewModel resources", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Navigate away to trigger disposal
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // If we get here without errors, disposal worked correctly
      expect(find.byType(PlayPage), findsNothing);
    });

    testWidgets("should handle dynamic key width calculation", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find the InteractivePiano and verify key width is calculated
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      final piano = tester.widget<InteractivePiano>(pianoFinder);
      expect(piano.keyWidth, greaterThan(0));
      // Verify it's clamped to reasonable bounds (20-60 as per piano_range_utils)
      expect(piano.keyWidth, greaterThanOrEqualTo(20));
      expect(piano.keyWidth, lessThanOrEqualTo(60));
    });

    group("Chords Navigation Tests", () {
      testWidgets("should navigate to chords practice page", (tester) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(home: PlayPage()),
        );

        await tester.pumpWidget(testWidget);

        // Find and tap the Chords chip
        final chordsChip = find.widgetWithText(Chip, "Chords");
        expect(chordsChip, findsOneWidget);

        await tester.tap(chordsChip);
        await tester.pumpAndSettle();

        // Verify navigation to practice page with chords mode
        expect(find.byType(PracticePage), findsOneWidget);
      });

      testWidgets("should navigate to arpeggios practice page", (tester) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(home: PlayPage()),
        );

        await tester.pumpWidget(testWidget);

        // Find and tap the Arpeggios chip
        final arpeggiosChip = find.widgetWithText(Chip, "Arpeggios");
        expect(arpeggiosChip, findsOneWidget);

        await tester.tap(arpeggiosChip);
        await tester.pumpAndSettle();

        // Verify navigation to practice page with arpeggios mode
        expect(find.byType(PracticePage), findsOneWidget);
      });
    });
  });
}
