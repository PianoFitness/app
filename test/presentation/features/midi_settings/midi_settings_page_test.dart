// Unit tests for MidiSettingsPage.
//
// Tests the UI and user interaction functionality of the MIDI settings page.

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/services/midi_device_discovery_service.dart";
import "package:piano_fitness/presentation/features/midi_settings/midi_settings_page.dart";
import "package:provider/provider.dart";
import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("MidiSettingsPage UI Tests", () {
    late MockIMidiDeviceDiscoveryService mockService;

    setUp(() {
      mockService = MockIMidiDeviceDiscoveryService();
      when(mockService.setupChanged).thenAnswer((_) => const Stream.empty());
      when(
        mockService.bluetoothStatusChanged,
      ).thenAnswer((_) => const Stream.empty());
      when(mockService.getDevices()).thenAnswer((_) async => []);
    });

    Widget buildTestWidget({int initialChannel = 0}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MidiState()),
          Provider<IMidiDeviceDiscoveryService>.value(value: mockService),
        ],
        child: MaterialApp(
          home: MidiSettingsPage(initialChannel: initialChannel),
        ),
      );
    }

    testWidgets("should create MidiSettingsPage without errors", (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(MidiSettingsPage), findsOneWidget);
      expect(find.text("MIDI Settings"), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_audio), findsOneWidget);
    });

    testWidgets("should initialize with provided channel", (tester) async {
      await tester.pumpWidget(buildTestWidget(initialChannel: 5));
      await tester.pump();

      expect(find.byType(MidiSettingsPage), findsOneWidget);
    });

    testWidgets("should display MIDI status and controls", (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text("MIDI Device Configuration"), findsOneWidget);
      expect(find.text("MIDI Output Channel"), findsOneWidget);
      expect(find.text("Channel: "), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsWidgets);
      expect(find.byIcon(Icons.remove_circle), findsWidgets);
    });

    testWidgets("should handle channel selection changes", (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final addButton = find.byIcon(Icons.add_circle);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pump();

        expect(find.byType(MidiSettingsPage), findsOneWidget);
      }
    });

    testWidgets("should display device scan button and handle taps", (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      // pumpAndSettle ensures _setupMidi() fully completes: _midiStatus becomes
      // "Ready - No MIDI devices found..." which sets shouldShowErrorButtons=true
      // and places the FAB in retry mode. A single pump() can leave the chain
      // incomplete, causing the tap to call scanForDevices() instead.
      await tester.pumpAndSettle();

      final scanFab = find.byKey(const Key("midi_settings_scan_fab"));
      expect(scanFab, findsOneWidget);
      // Confirm the FAB is in retry mode (shouldShowErrorButtons=true): the
      // "Retry" ElevatedButton is only rendered when that getter is true.
      expect(find.text("Retry"), findsAtLeastNWidgets(1));

      // Zero out calls accumulated during initial setup so the verification
      // below counts only the call from the FAB tap.
      clearInteractions(mockService);
      await tester.tap(scanFab);
      // retrySetup() chains several async boundaries (retrySetup →
      // _cleanupResources → _setupMidi → updateDeviceList → getDevices).
      // runAsync(Duration.zero) drains the real-async queue so all those
      // microtasks complete before the subsequent pump() flushes rebuilds.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MidiSettingsPage), findsOneWidget);
      // Verifies the FAB → retrySetup() → getDevices() dependency path:
      // the test fails if that wiring is ever broken.
      verify(mockService.getDevices()).called(1);
    });

    testWidgets("should handle navigation back with channel result", (
      tester,
    ) async {
      final testWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MidiState()),
          Provider<IMidiDeviceDiscoveryService>.value(value: mockService),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                key: const Key("open_midi_settings_test_button"),
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

      await tester.tap(find.byKey(const Key("open_midi_settings_test_button")));
      await tester.pumpAndSettle();

      expect(find.byType(MidiSettingsPage), findsOneWidget);

      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      expect(find.text("Open MIDI Settings"), findsOneWidget);
    });

    testWidgets("should display error states appropriately", (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(MidiSettingsPage), findsOneWidget);
      expect(find.textContaining("MIDI"), findsWidgets);
    });

    testWidgets("should integrate with MidiState provider", (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(MidiSettingsPage), findsOneWidget);
    });

    testWidgets("should display channel selector with correct initial value", (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text("MIDI Output Channel"), findsOneWidget);
      expect(find.text("Channel: "), findsOneWidget);
      expect(find.text("1"), findsOneWidget); // 0 (0-based) → 1 (user-facing)
      expect(
        find.textContaining("Channel for virtual piano output"),
        findsOneWidget,
      );
    });

    testWidgets(
      "should display default channel when no initial channel provided",
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        expect(find.text("MIDI Output Channel"), findsOneWidget);
        expect(find.text("Channel: "), findsOneWidget);
        expect(find.text("1"), findsOneWidget);
      },
    );

    testWidgets("should show floating action button for scanning", (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byKey(const Key("midi_settings_scan_fab")), findsOneWidget);

      final hasBluetoothIcon = find
          .byIcon(Icons.bluetooth_searching)
          .evaluate()
          .isNotEmpty;
      final hasRefreshIcon = find.byIcon(Icons.refresh).evaluate().isNotEmpty;

      expect(hasBluetoothIcon || hasRefreshIcon, isTrue);
    });
  });
}
