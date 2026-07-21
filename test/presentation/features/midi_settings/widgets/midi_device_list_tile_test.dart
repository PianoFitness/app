import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/presentation/features/midi_settings/widgets/midi_device_list_tile.dart";

void main() {
  group("MidiDeviceListTile Widget Tests", () {
    testWidgets("renders connected device tile and handles taps", (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      bool controllerOpened = false;

      final device = MidiDevice(
        id: "dev_1",
        name: "Yamaha P-125",
        type: "native",
        connected: true,
        inputPorts: [MidiPort(id: 1)],
        outputPorts: [MidiPort(id: 1)],


      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MidiDeviceListTile(
              device: device,
              deviceIcon: Icons.devices,
              onTap: () {
                tapped = true;
              },
              onOpenController: () {
                controllerOpened = true;
              },
            ),
          ),
        ),
      );

      expect(find.text("Yamaha P-125"), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);

      await tester.tap(find.byIcon(Icons.settings));
      expect(controllerOpened, isTrue);
    });

    testWidgets("renders disconnected device without settings button", (
      WidgetTester tester,
    ) async {
      final device = MidiDevice(
        id: "dev_2",
        name: "Roland FP-30X",
        type: "BLE",
        connected: false,
        inputPorts: [],
        outputPorts: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MidiDeviceListTile(
              device: device,
              deviceIcon: Icons.bluetooth,
              onTap: () {},
              onOpenController: () {},
            ),
          ),
        ),
      );

      expect(find.text("Roland FP-30X"), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsNothing);
    });
  });
}
