# Testing Guidelines for Piano Fitness

This document provides comprehensive testing best practices and conventions for Flutter/Dart development in the Piano Fitness project.

## Table of Contents

- [Project Testing Structure](#project-testing-structure)
- [Key-Based UI Element Selection](#key-based-ui-element-selection)
- [Test Types and Organization](#test-types-and-organization)
- [MIDI Mocking Strategy](#midi-mocking-strategy)
- [Widget Testing Patterns](#widget-testing-patterns)
- [Integration Testing Best Practices](#integration-testing-best-practices)
- [State Management Testing](#state-management-testing)
- [Test Naming Conventions](#test-naming-conventions)
- [Common Test Utilities](#common-test-utilities)

## Project Testing Structure

The Piano Fitness test suite follows a feature-based structure that mirrors the main codebase:

```text
test/
├── GUIDELINES.md                   # This file
├── shared/
│   ├── midi_mocks.dart            # Centralized MIDI mocking
│   ├── models/                    # Model unit tests
│   ├── services/                  # Service unit tests
│   └── utils/                     # Utility unit tests
├── features/
│   ├── device_controller/         # Feature-specific tests
│   ├── midi_settings/
│   ├── play/
│   ├── practice/
│   ├── reference/
│   └── notifications/
├── widget_test.dart               # Basic widget tests
└── widget_integration_test.dart   # Cross-feature integration tests
```

## Key-Based UI Element Selection

**Always use semantic `Key()` widgets for reliable test element selection instead of text-based finders.**

### Benefits of Key-Based Selection

1. **Robustness**: Tests won't break when UI text changes
2. **Precision**: Exact targeting of specific UI elements  
3. **Internationalization**: Keys decouple UI text from tests and support localized strings
4. **Performance**: Key-based finders are more efficient than text searches
5. **Maintainability**: Clear intent in test code about what element is being tested

---

**Note:** Keys are used for widget identity and testing—they do not affect assistive technologies or screen readers. For accessibility concerns, use the [Semantics API](https://api.flutter.dev/flutter/widgets/Semantics-class.html) and refer to Flutter's accessibility documentation.

### Key Naming Conventions

Use descriptive, hierarchical key names that indicate the feature, component, and element:

```dart
// Mode selection
Key("reference_mode_selector")         // Container
Key("scales_mode_button")             // Individual button
Key("chord_types_mode_button")        // Individual button

// Feature-specific selections
Key("scales_key_selection")           // Container
Key("scales_key_c")                   // Individual key
Key("chords_root_selection")          // Container  
Key("chords_root_fSharp")            // Individual root note

// Interactive elements
Key("reference_piano")                // Piano widget
Key("practice_start_button")          // Action buttons
```

### Usage Examples

```dart
// Correct: Use keys for reliable element targeting
await tester.tap(find.byKey(const Key("chord_types_mode_button")));
await tester.tap(find.byKey(const Key("chords_root_fSharp")));

// Avoid: Text-based finders are brittle
await tester.tap(find.text("Chord Types"));  // Breaks if text changes
```

### Implementation in Widgets

Add semantic keys to interactive and testable UI elements:

```dart
SegmentedButton(
  key: const Key("reference_mode_selector"),
  // ... other properties
)

FilterChip(
  key: Key("scales_key_${key.name}"),
  label: Text(key.displayName),
  // ... other properties
)
```

## Test Types and Organization

### Unit Tests

Test individual classes, functions, and business logic in isolation:

```dart
// Example: Testing utility functions
test("should create C Major chord correctly", () {
  final chord = ChordDefinitions.getChord(
    MusicalNote.c,
    ChordType.major,
    ChordInversion.root,
  );

  expect(chord.rootNote, equals(MusicalNote.c));
  expect(chord.type, equals(ChordType.major));
  expect(chord.notes, equals([MusicalNote.c, MusicalNote.e, MusicalNote.g]));
});
```

### Widget Tests

Test individual UI components and their interactions:

```dart
testWidgets("should display reference page with initial content", (tester) async {
  await tester.pumpWidget(createTestWidget());
  await tester.pumpAndSettle();

  // Use key-based finders
  expect(find.byKey(const Key("reference_mode_selector")), findsOneWidget);
  expect(find.byKey(const Key("scales_mode_button")), findsOneWidget);
});
```

### Integration Tests

Test cross-feature functionality and navigation flows:

```dart
testWidgets("should maintain reference page state when switching tabs", (tester) async {
  await tester.pumpWidget(createTestApp());
  await tester.pumpAndSettle();

  // Navigate and interact using keys
  await tester.tap(find.text("Reference"));
  await tester.tap(find.byKey(const Key("chord_types_mode_button")));
  await tester.tap(find.byKey(const Key("chords_root_fSharp")));
  
  // Test state persistence
  await tester.tap(find.text("Practice"));
  await tester.tap(find.text("Reference"));
  
  // Verify state is maintained
  final selectedChip = tester.widget<FilterChip>(
    find.widgetWithText(FilterChip, "G♭"),
  );
  expect(selectedChip.selected, isTrue);
});
```

## MIDI Mocking Strategy

### Centralized MIDI Mocks

All MIDI functionality is mocked through the centralized `test/shared/midi_mocks.dart` module:

```dart
void main() {
  setUpAll(MidiMocks.setUp);      // Initialize mocks once per test suite
  tearDownAll(MidiMocks.tearDown); // Clean up resources

  group("Your Test Group", () {
    // Your tests here
  });
}
```

### Mock Capabilities

The MIDI mocking system provides:

- Device enumeration and connection simulation
- MIDI data packet simulation
- Bluetooth state management
- Stream controller access for event simulation

### Simulating MIDI Events

```dart
// Simulate MIDI data reception
MidiMocks.simulateMidiDataReceived(MidiPacket([0x90, 60, 127]));

// Simulate Bluetooth state changes
MidiMocks.simulateBluetoothStateChange(BluetoothState.poweredOn);
```

## Widget Testing Patterns

### Test Widget Creation

Create helper methods for consistent widget setup:

```dart
late MidiState midiState;

setUp(() {
  midiState = MidiState();
});

tearDown(() {
  midiState.dispose();
});

Widget createTestWidget() {
  return MaterialApp(
    home: ChangeNotifierProvider<MidiState>.value(
      value: midiState,
      child: const ReferencePage(),
    ),
  );
}
```

### State Provider Testing

Always provide necessary state providers in test widgets:

```dart
Widget createTestApp() {
  return MaterialApp(
    home: ChangeNotifierProvider<MidiState>.value(
      value: midiState,
      child: const MainNavigation(),
    ),
  );
}
```

### Pump and Settle Pattern

Use consistent pumping patterns for UI updates:

```dart
await tester.pumpWidget(createTestWidget());
await tester.pumpAndSettle(); // Wait for all animations and async operations

// After interactions
await tester.tap(find.byKey(const Key("some_button")));
await tester.pumpAndSettle(); // Wait for state changes
```

## Integration Testing Best Practices

### Navigation Testing

Test navigation flows using the main navigation structure:

```dart
testWidgets("should navigate between pages correctly", (tester) async {
  await tester.pumpWidget(createTestApp());
  await tester.pumpAndSettle();

  // Test navigation to reference page
  await tester.tap(find.text("Reference"));
  await tester.pumpAndSettle();

  // Verify app bar and content
  final appBarTitleFinder = find.descendant(
    of: find.byType(AppBar),
    matching: find.text("Reference"),
  );
  expect(appBarTitleFinder, findsOneWidget);
});
```

### State Persistence Testing

Verify that feature state persists across navigation:

```dart
testWidgets("should maintain state across navigation", (tester) async {
  // Set up state
  await tester.tap(find.byKey(const Key("some_setting")));
  
  // Navigate away and back
  await tester.tap(find.text("Other Tab"));
  await tester.tap(find.text("Original Tab"));
  
  // Verify state persistence
  expect(find.byKey(const Key("some_setting")), findsOneWidget);
});
```

## State Management Testing

### ChangeNotifier Testing

Test ViewModels that extend ChangeNotifier:

```dart
test("should notify listeners when state changes", () {
  final viewModel = ReferencePageViewModel();
  bool notified = false;
  
  viewModel.addListener(() {
    notified = true;
  });

  viewModel.updateSomeState();
  
  expect(notified, isTrue);
  
  viewModel.dispose();
});
```

### MidiState Testing

Test MIDI state interactions:

```dart
test("should update highlighted notes correctly", () {
  final midiState = MidiState();
  final notes = [MusicalNote.c, MusicalNote.e, MusicalNote.g];
  
  midiState.setHighlightedNotes(notes);
  
  expect(midiState.highlightedNotes, equals(notes));
  
  midiState.dispose();
});
```

## Test Naming Conventions

### Test Group Names

Use descriptive, hierarchical group names:

```dart
group("ReferencePage Widget Tests", () {
  group("Mode Selection", () {
    test("should switch between scales and chords mode", () {
      // Test implementation
    });
  });
  
  group("Scale Selection", () {
    test("should display all scale types", () {
      // Test implementation
    });
  });
});
```

### Test Method Names

Use clear, behavior-focused test names:

```dart
// Good: Describes behavior and expectation
testWidgets("should display reference page with initial content", (tester) async {});
testWidgets("should maintain state when switching tabs", (tester) async {});

// Avoid: Implementation-focused names
testWidgets("ReferencePage builds correctly", (tester) async {}); // Too generic
```

### File Naming

Follow consistent naming patterns:

- `*_test.dart` - Unit and widget tests
- `*_integration_test.dart` - Integration tests
- `*_view_model_test.dart` - ViewModel-specific tests

## Common Test Utilities

### Finder Utilities

Create reusable finders for common patterns:

```dart
// Key-based finders
Finder findByKey(String key) => find.byKey(Key(key));
Finder findButtonByKey(String key) => find.ancestor(
  of: find.byKey(Key(key)),
  matching: find.byType(ElevatedButton),
);

// Widget-specific finders
Finder findFilterChip(String text) => find.widgetWithText(FilterChip, text);
```

### Assertion Helpers

Create reusable assertions for complex UI states:

```dart
void expectChipSelected(WidgetTester tester, String chipText, bool selected) {
  final chip = tester.widget<FilterChip>(findFilterChip(chipText));
  expect(chip.selected, equals(selected));
}
```

### Mock Data Generators

Create helpers for generating test data:

```dart
MidiPacket createTestNoteOn(int note, int velocity) {
  return MidiPacket([0x90, note, velocity]);
}

List<MusicalNote> createMajorScaleNotes(MusicalNote root) {
  return ScaleDefinitions.getScale(root, ScaleType.major).notes;
}
```

## Testing Checklist

Before committing tests, verify:

- [ ] All interactive UI elements have semantic `Key()` widgets
- [ ] MIDI functionality uses centralized `MidiMocks`
- [ ] Widget tests use `createTestWidget()` helper pattern
- [ ] Integration tests use `createTestApp()` with proper providers
- [ ] State changes use `pumpAndSettle()` for stability
- [ ] Test names clearly describe behavior and expectations
- [ ] Resource cleanup in `tearDown()` methods
- [ ] No hardcoded text-based finders for interactive elements
- [ ] Complex assertions extracted into helper methods
- [ ] Tests cover both positive and negative scenarios

## Performance Considerations

- Use `const` constructors for keys: `const Key("my_key")`
- Prefer `findsOneWidget` over `findsWidgets` when expecting single results
- Use `pumpAndSettle()` judiciously - only when async operations are expected
- Clean up resources in `tearDown()` to prevent memory leaks
- Group related tests to share setup/teardown overhead

## Migration from Text-Based Finders

When updating existing tests to use keys:

1. Identify UI elements that need reliable targeting
2. Add semantic keys to widgets in implementation
3. Replace `find.text()` calls with `find.byKey()` calls
4. Update test assertions to use key-based expectations
5. Verify tests pass with both old and new text content

### Bottom Navigation Best Practices

Bottom navigation items and app bar actions should expose stable keys for testing:

- **App bar actions**: Use semantic keys like `Key("midi_settings_button")`, `Key("notification_settings_button")`
- **Bottom navigation tabs**: Wrap icons in Semantics widgets with unique keys like `Key("nav_tab_practice")`
- **Navigation tests**: Create helper functions for key-based navigation

```dart
// Good: Individual tab keys in MainNavigation
BottomNavigationBarItem(
  icon: Semantics(
    key: const Key("nav_tab_practice"),
    button: true,
    child: const Icon(Icons.school),
  ),
  label: "Practice",
),

// Good: Key-based navigation helper
Future<void> navigateToTab(WidgetTester tester, Key tabKey) async {
  final tabFinder = find.byKey(tabKey);
  await tester.tap(tabFinder);
  await tester.pumpAndSettle();
}

// Good: Using the helper
await navigateToTab(tester, const Key("nav_tab_reference"));

// Avoid: Text-based navigation
await tester.tap(find.text("Reference")); // Brittle to text changes
```

This migration improves test robustness and supports internationalization efforts.
