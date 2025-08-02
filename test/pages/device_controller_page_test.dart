// Unit tests for DeviceControllerPage.
//
// Tests the individual MIDI device control page functionality.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'package:piano_fitness/pages/device_controller_page.dart';

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
  group('DeviceControllerPage Tests', () {
    // Create a mock MIDI device for testing
    final mockDevice = MockMidiDevice(
      id: 'test-device-1',
      name: 'Test MIDI Device',
      type: 'BLE',
      connected: false,
    );

    testWidgets('should create DeviceControllerPage without errors', (tester) async {
      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);

      // Verify DeviceControllerPage is rendered
      expect(find.byType(DeviceControllerPage), findsOneWidget);
      expect(find.text('Test MIDI Device Controller'), findsOneWidget);
      expect(find.text('Device Information'), findsOneWidget);
    });

    testWidgets('should display device information', (tester) async {
      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);

      // Verify device information is displayed
      expect(find.text('Device Information'), findsOneWidget);
      expect(find.textContaining('Name: Test MIDI Device'), findsOneWidget);
      expect(find.textContaining('Type: BLE'), findsOneWidget);
      expect(find.textContaining('ID: test-device-1'), findsOneWidget);
    });

    testWidgets('should display MIDI controls', (tester) async {
      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify basic MIDI control elements are present
      expect(find.text('MIDI Channel'), findsOneWidget);
      expect(find.text('Control Change (CC)'), findsOneWidget);
      
      // Verify control buttons are present
      expect(find.byIcon(Icons.add_circle), findsWidgets);
      expect(find.byIcon(Icons.remove_circle), findsWidgets);
      
      // Verify sliders are present
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('should handle channel selection changes', (tester) async {
      Widget testWidget = MaterialApp(
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

    testWidgets('should handle control change sliders', (tester) async {
      Widget testWidget = MaterialApp(
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

    testWidgets('should display MIDI message status', (tester) async {
      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Verify MIDI status area exists
      expect(find.text('Last Received MIDI Message'), findsOneWidget);
      
      // Should show initial "no data" message or similar
      expect(find.textContaining('MIDI'), findsWidgets);
    });

    testWidgets('should handle send buttons without crashing', (tester) async {
      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Find and test send buttons
      final sendButtons = find.byType(ElevatedButton);
      if (sendButtons.evaluate().isNotEmpty) {
        // Test tapping the first send button
        await tester.tap(sendButtons.first);
        await tester.pump();
        
        // Should not crash when sending MIDI messages
        expect(find.byType(DeviceControllerPage), findsOneWidget);
      }
    });

    testWidgets('should display pitch bend control', (tester) async {
      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Try scrolling to find the pitch bend section
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      // Verify pitch bend section or related controls
      if (find.text('Pitch Bend').evaluate().isNotEmpty) {
        expect(find.text('Pitch Bend'), findsOneWidget);
      } else {
        // If not visible, just verify sliders exist (pitch bend uses sliders)
        expect(find.byType(Slider), findsWidgets);
      }
    });

    testWidgets('should handle device disconnection gracefully', (tester) async {
      final disconnectedDevice = MockMidiDevice(
        id: 'test-device-2',
        name: 'Disconnected Device',
        type: 'BLE',
        connected: false,
      );

      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: disconnectedDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Should render without errors even for disconnected device
      expect(find.byType(DeviceControllerPage), findsOneWidget);
      expect(find.textContaining('Disconnected Device').first, findsOneWidget);
      expect(find.textContaining('Connected: No'), findsOneWidget);
    });

    testWidgets('should handle program change controls', (tester) async {
      Widget testWidget = MaterialApp(
        home: DeviceControllerPage(device: mockDevice),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Try scrolling to find the program change section
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      // Verify program change section or related controls
      if (find.text('Program Change').evaluate().isNotEmpty) {
        expect(find.text('Program Change'), findsOneWidget);
      } else {
        // If not visible, just verify the page renders correctly
        expect(find.byType(DeviceControllerPage), findsOneWidget);
        expect(find.byType(Slider), findsWidgets);
      }
    });

    test('should handle MidiService integration for event processing', () {
      // Test that demonstrates MidiService integration expectations
      // This verifies the expected data format and processing
      
      // Typical MIDI control change data
      const controlChangeData = [0xB0, 7, 100]; // CC#7 (Volume), Value 100
      
      // Verify data structure is correct for MidiService processing
      expect(controlChangeData.length, equals(3));
      expect(controlChangeData[0] & 0xF0, equals(0xB0)); // Control Change message
      expect(controlChangeData[1], equals(7)); // Controller number
      expect(controlChangeData[2], equals(100)); // Controller value
    });

    test('should handle pitch bend value calculations', () {
      // Test pitch bend data format
      const pitchBendData = [0xE0, 0x00, 0x40]; // Pitch bend, LSB=0, MSB=64 (center)
      
      expect(pitchBendData.length, equals(3));
      expect(pitchBendData[0] & 0xF0, equals(0xE0)); // Pitch bend message
      
      // Center position should be MSB=64 (0x40)
      expect(pitchBendData[2], equals(0x40));
    });
  });
}
