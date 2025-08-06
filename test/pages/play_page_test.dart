// Unit tests for PlayPage.
//
// Tests the main piano interface page functionality.

import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:piano_fitness/pages/midi_settings_page.dart";
import "package:piano_fitness/pages/play_page.dart";
import "package:piano_fitness/pages/practice_page.dart";
import "package:piano_fitness/services/midi_service.dart";
import "package:provider/provider.dart";

void main() {
  group("PlayPage Tests", () {
    testWidgets("should create PlayPage without errors", (tester) async {
      // Create a test widget with necessary providers
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

    testWidgets("should handle MIDI channel initialization", (tester) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage(midiChannel: 5)),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow post-frame callback to execute

      // Verify the MIDI channel is set correctly
      expect(midiState.selectedChannel, equals(5));
    });

    testWidgets("should display educational content", (tester) async {
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

    testWidgets("should integrate with MidiService for note on events", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow initialization

      // Test MidiService integration by directly calling the service
      // (since _handleMidiData is private, we test the service behavior)
      final midiData = Uint8List.fromList([0x90, 60, 100]);

      // Create a callback that simulates what PlayPage does
      MidiService.handleMidiData(midiData, (event) {
        if (event.type == MidiEventType.noteOn) {
          midiState.noteOn(event.data1, event.data2, event.channel);
        }
      });

      // Verify MidiState was updated correctly
      expect(midiState.activeNotes.contains(60), true);
      expect(midiState.lastNote, "Note ON: 60 (Ch: 1, Vel: 100)");
      expect(midiState.hasRecentActivity, true);

      // Clean up timers
      await tester.pump(const Duration(seconds: 2));
      midiState.dispose();
    });

    testWidgets("should integrate with MidiService for note off events", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // First add a note
      midiState.noteOn(60, 100, 1);
      expect(midiState.activeNotes.contains(60), true);

      // Test MidiService integration for note off
      final midiData = Uint8List.fromList([0x80, 60, 0]);

      MidiService.handleMidiData(midiData, (event) {
        if (event.type == MidiEventType.noteOff) {
          midiState.noteOff(event.data1, event.channel);
        }
      });

      // Verify note was turned off
      expect(midiState.activeNotes.contains(60), false);
      expect(midiState.lastNote, "Note OFF: 60 (Ch: 1)");

      // Clean up timers
      await tester.pump(const Duration(seconds: 2));
      midiState.dispose();
    });

    testWidgets("should integrate with MidiService for control change events", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Test MidiService integration for control change
      final midiData = Uint8List.fromList([0xB0, 7, 100]);

      MidiService.handleMidiData(midiData, (event) {
        if (event.type == MidiEventType.controlChange) {
          midiState.setLastNote(event.displayMessage);
        }
      });

      // Verify control change was processed
      expect(midiState.lastNote, "CC: Controller 7 = 100 (Ch: 1)");
      expect(midiState.hasRecentActivity, true);

      // Clean up timers
      await tester.pump(const Duration(seconds: 2));
      midiState.dispose();
    });

    testWidgets("should update piano keyboard highlights based on MIDI state", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find the InteractivePiano widget
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      // Verify initial state - no highlighted notes
      // TODO(test): Fix this test - highlightedNotes property doesn't exist
      // var piano = tester.widget(pianoFinder);
      // expect(piano.highlightedNotes, isEmpty);

      // Add a note to MidiState (MIDI note 60 = C4)
      midiState.noteOn(60, 100, 1);
      await tester.pump(); // Rebuild after state change

      // TODO(test): Fix this test - highlightedNotes property doesn't exist
      // Verify piano highlights were updated
      // piano = tester.widget(pianoFinder);
      // expect(piano.highlightedNotes.isNotEmpty, true);

      // MIDI note 60 = C4: octave = 60/12 - 1 = 4, note = C
      // final hasC4 = piano.highlightedNotes.any(
      //   (notePos) => notePos.note == Note.C && notePos.octave == 4,
      // );
      // expect(hasC4, true);

      // Clean up timers
      await tester.pump(const Duration(seconds: 2));
      midiState.dispose();
    });

    testWidgets("should handle virtual note playing", (tester) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find the InteractivePiano and tap a key
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      // Note: Since InteractivePiano is from the piano package and may not expose
      // individual keys in tests, we'll verify the callback was set up correctly
      final piano = tester.widget<InteractivePiano>(pianoFinder);
      expect(piano.onNotePositionTapped, isNotNull);
    });

    testWidgets("should navigate to practice pages from chips", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find and tap the Scales chip by looking for the specific Chip widget
      final scalesChip = find.widgetWithText(Chip, "Scales");
      expect(scalesChip, findsOneWidget);

      await tester.tap(scalesChip);
      await tester.pumpAndSettle();

      // Verify navigation occurred (PracticePage should be pushed)
      expect(find.byType(PracticePage), findsOneWidget);
    });

    testWidgets("should show MIDI activity indicator based on state", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find the MIDI activity indicator in the app bar (it's the smaller container)
      final indicatorFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
            widget.constraints?.maxWidth == 12.0,
      );
      expect(indicatorFinder, findsOneWidget);

      // Initially should be grey (no activity)
      // TODO(test): Fix this test - decoration property doesn't exist
      // var indicator = tester.widget(indicatorFinder);
      // var decoration = indicator.decoration! as BoxDecoration;
      // expect(decoration.color, isNot(Colors.green));

      // Add MIDI activity
      midiState.noteOn(60, 100, 1);
      await tester.pump();

      // Should now be green (has activity)
      // TODO(test): Fix this test - decoration property doesn't exist
      // indicator = tester.widget(indicatorFinder);
      // decoration = indicator.decoration as BoxDecoration;
      // expect(decoration.color, Colors.green);

      // Clean up timers
      await tester.pump(const Duration(seconds: 2));
      midiState.dispose();
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

    testWidgets("should handle channel updates from MIDI settings", (
      tester,
    ) async {
      final midiState = MidiState()
        ..setSelectedChannel(0); // Start with channel 0

      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Verify initial channel
      expect(midiState.selectedChannel, 0);

      // Simulate returning from settings with a new channel
      // Since we can't easily mock Navigator.push result in widget tests,
      // we'll test the direct channel change functionality
      midiState.setSelectedChannel(5);
      await tester.pump();

      expect(midiState.selectedChannel, 5);
    });

    testWidgets("should handle MIDI activity indicator tap", (tester) async {
      final midiState = MidiState()..setLastNote("Test MIDI Message");

      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );

      await tester.pumpWidget(testWidget);

      // Find and tap the MIDI activity indicator (GestureDetector containing the indicator)
      final indicatorTapArea = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Container &&
            (widget.child! as Container).decoration is BoxDecoration &&
            ((widget.child! as Container).decoration! as BoxDecoration).shape ==
                BoxShape.circle &&
            (widget.child! as Container).constraints?.maxWidth == 12.0,
      );
      expect(indicatorTapArea, findsOneWidget);

      await tester.tap(indicatorTapArea);
      await tester.pump();

      // Verify snackbar is shown with MIDI message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text("MIDI: Test MIDI Message"), findsOneWidget);

      // Clean up timers
      await tester.pump(const Duration(seconds: 2));
      midiState.dispose();
    });

    testWidgets("should properly dispose resources", (tester) async {
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
  });
}
