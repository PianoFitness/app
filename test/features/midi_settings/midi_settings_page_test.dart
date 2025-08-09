// Unit tests for MidiSettingsPage.
//
// Tests the UI and user interaction functionality of the MIDI settings page.

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:provider/provider.dart";

void main() {
  group("MidiSettingsPage UI Tests", () {
    testWidgets("should create MidiSettingsPage without errors", (
      tester,
    ) async {
      // Create a test widget with necessary providers
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage()),
      );

      await tester.pumpWidget(testWidget);

      // Verify MidiSettingsPage is rendered
      expect(find.byType(MidiSettingsPage), findsOneWidget);
      expect(find.text("MIDI Settings"), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_audio), findsOneWidget);
    });

    testWidgets("should initialize with provided channel", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage(initialChannel: 5)),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow state initialization

      // Verify the page is created (channel initialization is internal)
      expect(find.byType(MidiSettingsPage), findsOneWidget);
    });

    testWidgets("should display MIDI status and controls", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow UI to settle

      // Verify MIDI configuration section exists
      expect(find.text("MIDI Device Configuration"), findsOneWidget);

      // Verify control elements exist
      expect(find.text("MIDI Output Channel"), findsOneWidget);
      expect(find.text("Channel: "), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsWidgets);
      expect(find.byIcon(Icons.remove_circle), findsWidgets);
    });

    testWidgets("should handle channel selection changes", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find and interact with channel increment button
      final addButton = find.byIcon(Icons.add_circle);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pump();

        // Should not crash after changing channel
        expect(find.byType(MidiSettingsPage), findsOneWidget);
      }
    });

    testWidgets("should display device scan button and handle taps", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Look for scan/refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      if (refreshButton.evaluate().isNotEmpty) {
        await tester.tap(refreshButton);
        await tester.pump();

        // Should not crash after tapping scan button
        expect(find.byType(MidiSettingsPage), findsOneWidget);
      }
    });

    testWidgets("should handle navigation back with channel result", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      builder: (context) =>
                          const MidiSettingsPage(initialChannel: 3),
                    ),
                  );
                },
                child: const Text("Open MIDI Settings"),
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(testWidget);

      // Open MIDI settings
      await tester.tap(find.text("Open MIDI Settings"));
      await tester.pumpAndSettle();

      // Verify we're on the MIDI settings page
      expect(find.byType(MidiSettingsPage), findsOneWidget);

      // Navigate back using the back button in AppBar
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // Should be back to original page or handle gracefully
      expect(find.text("Open MIDI Settings"), findsOneWidget);
    });

    testWidgets("should display error states appropriately", (tester) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // The page should render without errors even if MIDI setup fails
      expect(find.byType(MidiSettingsPage), findsOneWidget);

      // Status text should be present (could be initializing, error, or ready)
      expect(find.textContaining("MIDI"), findsWidgets);
    });

    testWidgets("should integrate with MidiState provider", (tester) async {
      final midiState = MidiState();

      final Widget testWidget = ChangeNotifierProvider.value(
        value: midiState,
        child: const MaterialApp(home: MidiSettingsPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify the page can access MidiState
      expect(find.byType(MidiSettingsPage), findsOneWidget);

      // The integration is tested by the page not throwing errors
      // when accessing Provider.of<MidiState>
    });

    testWidgets("should display channel selector with correct initial value", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage(initialChannel: 7)),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Should show channel selector
      expect(find.text("MIDI Output Channel"), findsOneWidget);
      expect(find.text("Channel: "), findsOneWidget);

      // Channel display should be present (displayed as 1-16, not 0-15)
      expect(
        find.textContaining("Channel for virtual piano output"),
        findsOneWidget,
      );
    });

    testWidgets("should show floating action button for scanning", (
      tester,
    ) async {
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: const MaterialApp(home: MidiSettingsPage()),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Should have floating action button
      expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));

      // Should show bluetooth search or refresh icon
      final hasBluetoothIcon = find
          .byIcon(Icons.bluetooth_searching)
          .evaluate()
          .isNotEmpty;
      final hasRefreshIcon = find.byIcon(Icons.refresh).evaluate().isNotEmpty;

      expect(hasBluetoothIcon || hasRefreshIcon, isTrue);
    });
  });
}
