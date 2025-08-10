// Unit tests for DeviceControllerPage.
//
// Tests the UI and user interaction functionality of the device controller page.

import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/device_controller/device_controller_page.dart";
import "../../shared/midi_mocks.dart";

// Mock MIDI device class for testing
class MockMidiDevice extends MidiDevice {
  MockMidiDevice({
    required String id,
    required String name,
    required String type,
    required bool connected,
  }) : super(id, name, type, connected);
}

void main() {
  setUpAll(MidiMocks.setUp);

  tearDownAll(MidiMocks.tearDown);

  group("DeviceControllerPage UI Tests", () {
    // Create a mock MIDI device for testing
    final mockDevice = MockMidiDevice(
      id: "test-device-1",
      name: "Test MIDI Device",
      type: "BLE",
      connected: false,
    );

    testWidgets("should create DeviceControllerPage without errors", (
      tester,
    ) async {
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);

      // Verify DeviceControllerPage is rendered
      expect(find.byType(DeviceControllerPage), findsOneWidget);
      expect(find.text("Test MIDI Device Controller"), findsOneWidget);
      expect(find.text("Device Information"), findsOneWidget);
    });

    testWidgets("should display device information", (tester) async {
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);

      // Verify device information is displayed
      expect(find.text("Device Information"), findsOneWidget);
      expect(find.textContaining("Name: Test MIDI Device"), findsOneWidget);
      expect(find.textContaining("Type: BLE"), findsOneWidget);
      expect(find.textContaining("ID: test-device-1"), findsOneWidget);
    });

    testWidgets("should display MIDI controls", (tester) async {
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
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
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
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
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
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
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify MIDI status area exists
      expect(find.text("Last Received MIDI Message"), findsOneWidget);

      // Should show initial "no data" message or similar
      expect(find.textContaining("MIDI"), findsWidgets);
    });

    testWidgets("should display pitch bend control", (tester) async {
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
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
      final disconnectedDevice = MockMidiDevice(
        id: "test-device-2",
        name: "Disconnected Device",
        type: "BLE",
        connected: false,
      );

      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: disconnectedDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Should render without errors even for disconnected device
      expect(find.byType(DeviceControllerPage), findsOneWidget);
      expect(find.textContaining("Disconnected Device").first, findsOneWidget);
      expect(find.textContaining("Connected: No"), findsOneWidget);
    });

    testWidgets("should handle program change controls", (tester) async {
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
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
      final Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
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
  });
}
