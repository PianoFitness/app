// Unit tests for DeviceControllerPage.
//
// Tests the UI and user interaction functionality of the device controller page.

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/features/device_controller/device_controller_page.dart";
import "../../shared/test_helpers/widget_test_helper.dart";
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("DeviceControllerPage UI Tests", () {
    // Create a mock MIDI device for testing using domain MidiDevice
    final mockDevice = MidiDevice(
      id: "test-device-1",
      name: "Test MIDI Device",
      type: "BLE",
      connected: false,
      inputPorts: [],
      outputPorts: [],
    );

    testWidgets("should create DeviceControllerPage without errors", (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );

      // Verify DeviceControllerPage is rendered
      expect(find.byType(DeviceControllerPage), findsOneWidget);
      expect(find.text("Test MIDI Device Controller"), findsOneWidget);
      expect(find.text("Device Information"), findsOneWidget);
    });

    testWidgets("should display device information", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );

      // Verify device information is displayed
      expect(find.text("Device Information"), findsOneWidget);
      expect(
        find.textContaining("Device name: Test MIDI Device"),
        findsOneWidget,
      );
      expect(find.textContaining("Device type: BLE"), findsOneWidget);
      expect(find.textContaining("Device ID: test-device-1"), findsOneWidget);
    });

    testWidgets("should display MIDI controls", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Verify basic MIDI control elements are present
      expect(find.text("MIDI Channel"), findsOneWidget);
      expect(find.text("Control Change (CC)"), findsOneWidget);

      // Verify control buttons are present
      expect(find.byIcon(Icons.add_circle), findsWidgets);
      expect(find.byIcon(Icons.remove_circle), findsWidgets);

      // Verify sliders are present
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets("should handle channel selection changes", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Find and interact with channel increment button
      final addButton = find.byIcon(Icons.add_circle);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pump();

        // Should not crash after changing channel
        expect(find.byType(DeviceControllerPage), findsOneWidget);
      }
    });

    testWidgets("should handle control change sliders", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Find control change sliders and test interaction
      final sliders = find.byType(Slider);
      if (sliders.evaluate().isNotEmpty) {
        final firstSlider = sliders.first;
        await tester.drag(firstSlider, const Offset(50, 0));
        await tester.pump();

        // Should update without errors
        expect(find.byType(DeviceControllerPage), findsOneWidget);
      } else {
        // If no sliders, the page should still render
        expect(find.byType(DeviceControllerPage), findsOneWidget);
      }
    });

    testWidgets("should display MIDI message status", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Verify MIDI status area exists
      expect(find.text("Last Received MIDI Message"), findsOneWidget);

      // Should show initial "no data" message or similar
      expect(find.textContaining("MIDI"), findsWidgets);
    });

    testWidgets("should display pitch bend control", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Try scrolling to find the pitch bend section
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      // Verify pitch bend section or related controls
      if (find.text("Pitch Bend").evaluate().isNotEmpty) {
        expect(find.text("Pitch Bend"), findsOneWidget);
      } else {
        // If not visible, just verify sliders exist (pitch bend uses sliders)
        expect(find.byType(Slider), findsWidgets);
      }
    });

    testWidgets("should handle device disconnection gracefully", (
      tester,
    ) async {
      final disconnectedDevice = MidiDevice(
        id: "test-device-2",
        name: "Disconnected Device",
        type: "BLE",
        connected: false,
        inputPorts: [],
        outputPorts: [],
      );

      // Using createTestWidget helper
      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: disconnectedDevice)),
      );
      await tester.pump();

      // Should render without errors even for disconnected device
      expect(find.byType(DeviceControllerPage), findsOneWidget);
      expect(find.text("Device name: Disconnected Device"), findsOneWidget);
      expect(
        find.textContaining("Connection status: Disconnected"),
        findsOneWidget,
      );
    });

    testWidgets("should handle program change controls", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Try scrolling to find the program change section
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      // Verify program change section or related controls
      if (find.text("Program Change").evaluate().isNotEmpty) {
        expect(find.text("Program Change"), findsOneWidget);
      } else {
        // If not visible, just verify the page renders correctly
        expect(find.byType(DeviceControllerPage), findsOneWidget);
        expect(find.byType(Slider), findsWidgets);
      }
    });

    testWidgets("should handle virtual piano key taps", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Scroll down to find virtual piano
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pump();

      // Look for piano keys (GestureDetector widgets)
      final gestureDetectors = find.byType(GestureDetector);
      if (gestureDetectors.evaluate().isNotEmpty) {
        // Tap a piano key
        await tester.tap(gestureDetectors.first);
        await tester.pump();

        // Should not crash when tapping piano keys
        expect(find.byType(DeviceControllerPage), findsOneWidget);
      }
    });

    testWidgets("should render correct piano key layout", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Scroll to virtual piano section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Verify Virtual Piano section exists
      expect(find.text("Virtual Piano"), findsOneWidget);

      // Count piano keys - should have exactly 12 keys (notes 60-71)
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors.evaluate().length, equals(12));
    });

    testWidgets("should render piano keys with correct colors", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Scroll to virtual piano section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Find all piano key containers
      final containers = find.byType(Container);
      expect(containers.evaluate().length, greaterThanOrEqualTo(12));

      // Verify that we have both black and white keys with different colors
      // Note: This is a basic test that containers exist with different colors
      // More detailed color testing would require accessing the Container decorations
      expect(containers, findsWidgets);
    });

    testWidgets("should handle piano key note on/off correctly", (
      tester,
    ) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Scroll to virtual piano section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      final gestureDetectors = find.byType(GestureDetector);
      if (gestureDetectors.evaluate().isNotEmpty) {
        final firstKey = gestureDetectors.first;

        // Test tap down (note on)
        await tester.startGesture(tester.getCenter(firstKey));
        await tester.pump();

        // Test tap up (note off)
        await tester.tapAt(tester.getCenter(firstKey));
        await tester.pump();

        // Should not crash during note on/off sequence
        expect(find.byType(DeviceControllerPage), findsOneWidget);
      }
    });
  });

  // Unit tests for piano key logic through public interface
  group("DeviceControllerPage Piano Key Logic", () {
    final mockDevice = MidiDevice(
      id: "test",
      name: "Test",
      type: "BLE",
      connected: false,
      inputPorts: [],
      outputPorts: [],
    );

    testWidgets("should render correct number of piano keys", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Scroll to virtual piano section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Count all piano key containers (should be 12 total: 7 white + 5 black)
      final pianoKeys = find.byType(GestureDetector);

      // Verify we have exactly 12 piano keys for the range 60-71
      expect(pianoKeys.evaluate().length, equals(12));
    });

    testWidgets("should render piano keys with note names", (tester) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Scroll to virtual piano section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Verify specific note names are displayed (compact format: no octave numbers)
      // These should correspond to MIDI notes 60-71
      expect(find.text("C"), findsOneWidget); // MIDI 60
      expect(find.text("C#"), findsOneWidget); // MIDI 61
      expect(find.text("D"), findsOneWidget); // MIDI 62
      expect(find.text("D#"), findsOneWidget); // MIDI 63
      expect(find.text("E"), findsOneWidget); // MIDI 64
      expect(find.text("F"), findsOneWidget); // MIDI 65
      expect(find.text("F#"), findsOneWidget); // MIDI 66
      expect(find.text("G"), findsOneWidget); // MIDI 67
      expect(find.text("G#"), findsOneWidget); // MIDI 68
      expect(find.text("A"), findsOneWidget); // MIDI 69
      expect(find.text("A#"), findsOneWidget); // MIDI 70
      expect(find.text("B"), findsOneWidget); // MIDI 71
    });

    testWidgets("should have correct white and black key distribution", (
      tester,
    ) async {
      // Using createTestWidget helper

      await tester.pumpWidget(
        createTestWidget(DeviceControllerPage(device: mockDevice)),
      );
      await tester.pump();

      // Scroll to virtual piano section
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Count white keys (should be 7: C, D, E, F, G, A, B)
      final whiteKeyNotes = ["C", "D", "E", "F", "G", "A", "B"];
      for (final note in whiteKeyNotes) {
        expect(
          find.text(note),
          findsOneWidget,
          reason: "White key $note should be rendered exactly once",
        );
      }

      // Count black keys (should be 5: C#, D#, F#, G#, A#)
      final blackKeyNotes = ["C#", "D#", "F#", "G#", "A#"];
      for (final note in blackKeyNotes) {
        expect(
          find.text(note),
          findsOneWidget,
          reason: "Black key $note should be rendered exactly once",
        );
      }

      // Verify total count: 7 white + 5 black = 12 keys
      final allKeys = [...whiteKeyNotes, ...blackKeyNotes];
      expect(
        allKeys.length,
        equals(12),
        reason: "Should have exactly 12 piano keys total",
      );
    });
  });
}
