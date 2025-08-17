# Test Infrastructure Documentation

This document describes the shared testing utilities and patterns used across the Piano Fitness test suite.

## Shared Test Utilities

### MIDI Mocking (`test/shared/midi_mocks.dart`)

Provides centralized mocking for the `flutter_midi_command` plugin to prevent code duplication and ensure consistent behavior across all test files.

#### Usage

```dart
import "../../shared/midi_mocks.dart";

void main() {
  setUpAll(() {
    MidiMocks.setUp();  // Sets up all MIDI plugin mocks
  });

  tearDownAll(() {
    MidiMocks.tearDown();  // Cleans up resources
  });

  // Your tests here...
}
```

#### What it mocks

- **Method Channel**: `plugins.invisiblewrench.com/flutter_midi_command`
  - Device management: `getDevices`, `devices`, `connectToDevice`, `disconnectDevice`
  - Data transmission: `sendData`
  - Device scanning: `scanForDevices`, `startScanning`, `stopScanning`, etc.
  - Bluetooth operations: `startBluetoothCentral`, `waitUntilBluetoothIsInitialized`, etc.
  - Lifecycle: `teardown`

- **Event Channels**: `plugins.invisiblewrench.com/flutter_midi_command/rx_channel`
  - Stream operations: `listen`, `cancel`

#### Test Utilities

The `MidiMocks` class also provides utilities for simulating MIDI events in tests:

```dart
// Simulate MIDI setup changes
MidiMocks.simulateMidiSetupChange("setup_data");

// Simulate Bluetooth state changes  
MidiMocks.simulateBluetoothStateChange(BluetoothState.connected);

// Simulate receiving MIDI data
MidiMocks.simulateMidiDataReceived(MidiPacket(/* data */));
```

## Test Patterns

### Timer-based Widget Tests

For tests involving timers (e.g., auto-advancing UI elements), use `tester.runAsync()`:

```dart
testWidgets('timer-based test', (tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(MyTimerWidget());
    // Timer operations happen here
    await tester.pump(Duration(seconds: 1));
    // Assertions
  });
});
```

### Behavior-focused Testing

Focus on testing meaningful user behavior rather than implementation details:

```dart
// ❌ Brittle - tests implementation details
expect(find.byWidgetPredicate((w) => w is Column && w.children.length == 2), findsOneWidget);

// ✅ Good - tests behavior
await tester.tap(find.byIcon(Icons.play));
expect(viewModel.isPlaying, isTrue);
```

### ViewModel Testing

- Always test state changes and business logic
- Mock external dependencies (MIDI, file system, etc.)
- Test error handling and edge cases
- Verify proper resource cleanup

```dart
test('should handle error states gracefully', () async {
  // Arrange
  final viewModel = MyViewModel();
  
  // Act & Assert
  expect(() => viewModel.invalidOperation(), throwsA(isA<Exception>()));
  expect(viewModel.hasError, isTrue);
});
```

## Test Coverage Guidelines

- **Minimum Coverage**: 70% overall, 80% for new/modified code
- **Focus Areas**: Business logic, state management, user interactions
- **Exclude**: Generated code, simple getters/setters, trivial UI widgets

## File Organization

```text
test/
├── shared/           # Shared utilities
│   └── midi_mocks.dart
├── features/         # Feature-specific tests
│   ├── play/
│   ├── practice/
│   └── midi_settings/
└── widget_test.dart  # Main widget integration tests
```

## Best Practices

1. **Use shared mocks** to avoid duplication
2. **Test behavior, not implementation** details
3. **Isolate external dependencies** completely
4. **Clean up resources** properly in tearDown methods
5. **Use descriptive test names** that explain the scenario
6. **Group related tests** logically
7. **Prefer unit tests** over widget tests for business logic
8. **Use widget tests** for user interaction flows

## Troubleshooting

### Common Issues

1. **MissingPluginException**: Ensure `MidiMocks.setUp()` is called in `setUpAll()`
2. **Pending Timers**: Use `tester.runAsync()` for timer-based operations
3. **Widget Not Found**: Check if widgets are rendered with `tester.pump()`
4. **State Not Updated**: Ensure `notifyListeners()` is called in ViewModels

### Debug Tips

```dart
// Print widget tree for debugging
debugDumpApp();

// Print render tree
debugDumpRenderTree();

// Check if widget exists before interaction
expect(find.byType(MyWidget), findsOneWidget);
```
