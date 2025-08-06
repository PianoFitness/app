// Widget integration tests for Piano Fitness app.
//
// Tests the integration between MidiState and UI components using Provider.

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:provider/provider.dart";

void main() {
  group("Widget Integration Tests", () {
    testWidgets("MidiState should be provided to widget tree", (
      WidgetTester tester,
    ) async {
      // Create a simple test widget that uses MidiState
      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => MidiState(),
        child: MaterialApp(
          home: Consumer<MidiState>(
            builder: (context, midiState, child) {
              return Scaffold(
                body: Text("Channel: ${midiState.selectedChannel}"),
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);

      // Verify MidiState is accessible
      expect(find.text("Channel: 0"), findsOneWidget);
    });

    testWidgets("MidiState changes should update UI", (
      WidgetTester tester,
    ) async {
      late MidiState midiState;

      final Widget testWidget = ChangeNotifierProvider(
        create: (context) => midiState = MidiState(),
        child: MaterialApp(
          home: Consumer<MidiState>(
            builder: (context, state, child) {
              return Scaffold(
                body: Column(
                  children: [
                    Text("Channel: ${state.selectedChannel}"),
                    Text("Active Notes: ${state.activeNotes.length}"),
                    Text("Last Note: ${state.lastNote}"),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);

      // Initial state
      expect(find.text("Channel: 0"), findsOneWidget);
      expect(find.text("Active Notes: 0"), findsOneWidget);

      // Change channel
      midiState.setSelectedChannel(5);
      await tester.pump();
      expect(find.text("Channel: 5"), findsOneWidget);

      // Add a note
      midiState.noteOn(60, 127, 1);
      await tester.pump();
      expect(find.text("Active Notes: 1"), findsOneWidget);
      expect(
        find.text("Last Note: Note ON: 60 (Ch: 1, Vel: 127)"),
        findsOneWidget,
      );
    });
  });
}
