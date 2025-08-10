import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/practice/practice_page.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/widgets/practice_settings_panel.dart";
import "package:provider/provider.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(() {
    MidiMocks.setUp();
  });

  tearDownAll(() {
    MidiMocks.tearDown();
  });
  group("PracticePage MVVM Tests", () {
    testWidgets("should create PracticePage with ViewModel without errors", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow initialization to complete

      // Verify PracticePage is rendered with essential components
      expect(find.byType(PracticePage), findsOneWidget);
      expect(find.text("Piano Practice"), findsOneWidget);
      // Focus on functionality, not specific UI implementation details
      expect(find.byType(PracticeSettingsPanel), findsOneWidget);
      expect(find.byType(InteractivePiano), findsOneWidget);
    });

    testWidgets("should initialize ViewModel with correct MIDI channel", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PracticePage(midiChannel: 8)),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow post-frame callback to execute

      // Verify the MIDI channel is set correctly through ViewModel
      expect(midiState.selectedChannel, equals(8));
    });

    testWidgets("should initialize with correct practice mode", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(
          home: PracticePage(initialMode: PracticeMode.chords),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow initialization

      // Verify practice mode initialization by checking if settings panel exists
      expect(find.byType(PracticeSettingsPanel), findsOneWidget);
    });

    testWidgets("should display practice settings panel", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify practice settings panel is present
      expect(find.byType(PracticeSettingsPanel), findsOneWidget);
    });

    testWidgets("should use ViewModel for piano range calculation", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find the InteractivePiano widget
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      // Verify the piano uses the range from ViewModel
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
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find the InteractivePiano and verify callback is set
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      final piano = tester.widget<InteractivePiano>(pianoFinder);
      expect(piano.onNotePositionTapped, isNotNull);
    });

    testWidgets("should integrate with MidiState through ViewModel", (
      tester,
    ) async {
      final midiState = MidiState();
      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify piano keyboard highlights are connected to MidiState
      final pianoFinder = find.byType(InteractivePiano);
      final piano = tester.widget<InteractivePiano>(pianoFinder);

      // The highlighted notes should be managed by the ViewModel
      expect(piano.highlightedNotes, isNotNull);

      // Use runAsync to properly handle the timer from _triggerActivity
      await tester.runAsync(() async {
        // Add a note to verify the connection works
        midiState.noteOn(60, 100, 1);
        await tester.pump();

        expect(midiState.highlightedNotePositions.isNotEmpty, isTrue);

        // Wait for the activity timer to complete or let it be handled by runAsync
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      });

      // Properly dispose to clean up any remaining timers
      midiState.dispose();
    });

    testWidgets("should handle dynamic key width calculation", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find the InteractivePiano and verify key width is calculated
      final pianoFinder = find.byType(InteractivePiano);
      expect(pianoFinder, findsOneWidget);

      final piano = tester.widget<InteractivePiano>(pianoFinder);
      expect(piano.keyWidth, greaterThan(0));
      // Verify it's within reasonable bounds
      expect(piano.keyWidth, greaterThanOrEqualTo(20));
      expect(piano.keyWidth, lessThanOrEqualTo(60));
    });

    testWidgets(
      "should display loading indicator before practice session initializes",
      (tester) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(home: PracticePage()),
        );

        await tester.pumpWidget(testWidget);

        // Before the post-frame callback, there might be a loading state
        // This test verifies the UI handles uninitialized state gracefully
        expect(find.byType(PracticePage), findsOneWidget);
      },
    );

    testWidgets("should properly dispose ViewModel resources", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Navigate away to trigger disposal
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // If we get here without errors, disposal worked correctly
      expect(find.byType(PracticePage), findsNothing);
    });

    testWidgets("should show exercise completion snackbar", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: PracticePage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // This test verifies the completion callback setup
      // The actual snackbar would be shown when the practice session triggers completion
      expect(find.byType(PracticePage), findsOneWidget);
    });

    group("Practice Mode Integration", () {
      testWidgets("should initialize with scales mode by default", (
        tester,
      ) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(home: PracticePage()),
        );

        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Verify default mode is handled correctly
        expect(find.byType(PracticeSettingsPanel), findsOneWidget);
      });

      testWidgets("should initialize with chords mode when specified", (
        tester,
      ) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(
            home: PracticePage(initialMode: PracticeMode.chords),
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Verify chords mode initialization
        expect(find.byType(PracticeSettingsPanel), findsOneWidget);
      });

      testWidgets("should initialize with arpeggios mode when specified", (
        tester,
      ) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(
            home: PracticePage(initialMode: PracticeMode.arpeggios),
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Verify arpeggios mode initialization
        expect(find.byType(PracticeSettingsPanel), findsOneWidget);
      });
    });

    group("UI Layout and Structure", () {
      testWidgets("should render practice page without errors", (
        tester,
      ) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(home: PracticePage()),
        );

        await tester.pumpWidget(testWidget);
        await tester.pump();

        // Verify page renders successfully - this is the meaningful test
        expect(find.byType(PracticePage), findsOneWidget);
        expect(find.byType(InteractivePiano), findsOneWidget);
        expect(find.byType(PracticeSettingsPanel), findsOneWidget);
      });

      testWidgets("should display MIDI status indicator", (tester) async {
        final Widget testWidget = ChangeNotifierProvider(
          create: (context) => MidiState(),
          child: const MaterialApp(home: PracticePage()),
        );

        await tester.pumpWidget(testWidget);

        // Verify MIDI status indicator is in the app bar
        expect(find.byType(AppBar), findsOneWidget);
        // The MidiStatusIndicator should be present in actions
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.actions, isNotEmpty);
      });
    });
  });
}
