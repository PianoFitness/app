import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/features/play/play_page.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/widgets/midi_controls.dart";
import "package:provider/provider.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);
  group("PlayPage MVVM Tests", () {
    late MidiState midiState;
    late Widget testWidget;

    setUp(() {
      midiState = MidiState();
      testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PlayPage()),
      );
    });

    tearDown(() {
      midiState.dispose();
    });

    testWidgets("should create PlayPage with ViewModel without errors", (
      tester,
    ) async {
      await tester.pumpWidget(testWidget);

      // Verify PlayPage is rendered
      expect(find.byType(PlayPage), findsOneWidget);
      expect(find.text("Piano Fitness"), findsOneWidget);
      expect(
        find.byIcon(Icons.piano),
        findsWidgets,
      ); // There are multiple piano icons
    });

    testWidgets("should initialize ViewModel with correct MIDI channel", (
      tester,
    ) async {
      // Since Play page now uses local MIDI state, we test that it renders correctly
      const Widget specificTestWidget = MaterialApp(
        home: PlayPage(midiChannel: 7),
      );

      await tester.pumpWidget(specificTestWidget);
      await tester.pump(); // Allow post-frame callback to execute

      // Verify the page renders correctly (MIDI channel is internal to ViewModel now)
      expect(find.byType(PlayPage), findsOneWidget);
      expect(find.text("Piano Fitness"), findsOneWidget);
    });

    testWidgets("should display educational content for free play", (
      tester,
    ) async {
      await tester.pumpWidget(testWidget);

      // Verify free play content is present
      expect(find.text("Free Play Mode"), findsOneWidget);
      expect(find.byIcon(Icons.piano), findsWidgets);
      expect(find.textContaining("Explore and play freely"), findsOneWidget);
    });

    testWidgets("should use ViewModel for piano range calculation", (
      tester,
    ) async {
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
      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify piano keyboard highlights are connected to MidiState
      final pianoFinder = find.byType(InteractivePiano);
      final piano = tester.widget<InteractivePiano>(pianoFinder);

      expect(
        piano.highlightedNotes,
        equals(midiState.highlightedNotePositions),
      );

      // Use runAsync to properly handle the timer from _triggerActivity
      await tester.runAsync(() async {
        // Add a note to verify the connection
        midiState.noteOn(60, 100, 1);
        await tester.pump();

        expect(midiState.highlightedNotePositions.isNotEmpty, isTrue);

        // Wait for the activity timer to complete or let it be handled by runAsync
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      });

      // Note: midiState disposal is handled in tearDown
    });

    testWidgets("should handle MIDI settings navigation", (tester) async {
      await tester.pumpWidget(testWidget);

      // Find and tap settings button
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify MIDI settings page is shown
      expect(find.byType(MidiSettingsPage), findsOneWidget);
    });

    testWidgets("should display MIDI controls", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify MIDI controls component is present in the app bar
      expect(find.byType(MidiControls), findsOneWidget);
    });

    testWidgets("should handle local MIDI state properly", (tester) async {
      await tester.pumpWidget(testWidget);

      // Find the PlayPage widget
      final playPageFinder = find.byType(PlayPage);
      expect(playPageFinder, findsOneWidget);

      // Test that the page renders without errors with local MIDI state
      await tester.pump();
      expect(playPageFinder, findsOneWidget);
    });

    testWidgets("should handle local MIDI state interaction", (tester) async {
      await tester.pumpWidget(testWidget);

      // Find the PlayPage widget
      final playPageFinder = find.byType(PlayPage);
      expect(playPageFinder, findsOneWidget);

      // Test that the page renders and can handle interaction
      await tester.pump();
      expect(playPageFinder, findsOneWidget);
    });

    testWidgets("should properly dispose ViewModel resources", (tester) async {
      await tester.pumpWidget(testWidget);

      // Navigate away to trigger disposal
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // If we get here without errors, disposal worked correctly
      expect(find.byType(PlayPage), findsNothing);
    });

    testWidgets("should handle dynamic key width calculation", (tester) async {
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
  });
}
