# Piano Fitness - Copilot Instructions

## Project Overview

Piano Fitness is a Flutter application designed to help users improve their piano playing skills through interactive exercises and real-time feedback. The app integrates MIDI functionality and visual piano interfaces.

## Technology Stack

- **Framework**: Flutter (Dart SDK ^3.8.1)
- **MIDI Integration**: flutter_midi_command
- **Piano UI**: piano package
- **State Management**: Built-in Flutter state management (StatefulWidget)
- **Platform Support**: iOS, Android, macOS, Windows, Linux, Web

## Code Conventions

### File Structure

- `lib/` - Main application code
- `docs/` - Project documentation and specifications
- `test/` - Unit and widget tests
- Platform-specific folders: `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`

### Naming Conventions

- **Files**: Use snake_case (e.g., `piano_keyboard_component.dart`)
- **Classes**: Use PascalCase (e.g., `PianoKeyboard`, `MidiController`)
- **Variables/Methods**: Use camelCase (e.g., `currentNote`, `playSound()`)
- **Constants**: Use SCREAMING_SNAKE_CASE (e.g., `MAX_NOTES`)

### Import Organization

```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:math';

// 2. Flutter framework libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:piano/piano.dart';

// 4. Local imports
import 'models/note.dart';
import 'widgets/piano_keyboard.dart';
```

## Package Management Commands

### ⚠️ IMPORTANT: Always use Flutter commands for package management

**DO NOT** manually edit `pubspec.yaml` for adding/removing dependencies. Use these commands instead:

### Adding Packages

```bash
# Add a regular dependency
flutter pub add package_name

# Add a development dependency
flutter pub add --dev package_name

# Add a specific version
flutter pub add package_name:^1.0.0

# Examples for this project:
flutter pub add piano
flutter pub add --dev mockito
```

### Removing Packages

```bash
# Remove a dependency
flutter pub remove package_name

# Example:
flutter pub remove unused_package
```

### Updating Packages

```bash
# Get dependencies (after manual pubspec changes)
flutter pub get

# Upgrade to latest compatible versions
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Upgrade to latest major versions (breaking changes possible)
flutter pub upgrade --major-versions
```

### Dependency Analysis

```bash
# Show dependency tree
flutter pub deps

# Analyze package dependencies
flutter pub deps --json
```

## Common Development Commands

### Running the App

```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d device_id

# Run in release mode
flutter run --release

# Hot reload is automatic in debug mode (press 'r' or save files)
```

### Testing

```bash
# Run all tests
flutter test

# Run tests by category
flutter test test/models/       # All model unit tests
flutter test test/pages/        # All page widget tests

# Run specific test files
flutter test test/models/midi_state_test.dart # MidiState unit tests
flutter test test/pages/play_page_test.dart   # PlayPage widget tests
flutter test test/widget_integration_test.dart # Integration tests

# Run tests with coverage (REQUIRED for all changes)
flutter test --coverage

# Generate and view HTML coverage report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Fix auto-fixable issues
dart fix --apply
```

### Building

```bash
# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Build for web
flutter build web

# Build for desktop (macOS example)
flutter build macos
```

## Project-Specific Guidelines

### MIDI Integration

- Use `flutter_midi_command` for MIDI device communication
- Handle MIDI permissions properly for each platform
- Implement proper error handling for MIDI connection failures

### Piano UI Components

- Use the `piano` package for consistent piano keyboard interfaces
- Implement touch and click handlers for piano keys
- Consider accessibility features for piano interactions

### State Management

- Use StatefulWidget for local component state
- Consider Provider or Riverpod for complex state management as the app grows
- Keep state close to where it's used

### Performance Considerations

- Optimize MIDI message handling to avoid UI blocking
- Use const constructors where possible
- Implement proper disposal of resources (streams, controllers)

### Error Handling

```dart
// Example error handling pattern
try {
  await midiDevice.connect();
} catch (e) {
  if (kDebugMode) {
    print('MIDI connection failed: $e');
  }
  // Show user-friendly error message
  showErrorDialog(context, 'Failed to connect to MIDI device');
}
```

## Testing Guidelines

### 🚨 **MANDATORY TEST COVERAGE REQUIREMENTS**

#### **Coverage Standards**

- **New Features**: ≥80% test coverage required
- **Bug Fixes**: Must include regression tests
- **Refactoring**: Must maintain existing coverage levels
- **MIDI Components**: Require comprehensive testing due to complexity

#### **Pre-Development Checklist**

1. **Check Baseline Coverage**:

   ```bash
   flutter test --coverage
   # Note current coverage levels for comparison
   ```

2. **Identify Test Requirements**:
   - Unit tests for business logic (models, state management)
   - Widget tests for UI components
   - Integration tests for user workflows
   - Mock external dependencies (MIDI devices, Bluetooth)

#### **Development Workflow**

1. **Write Tests First** (TDD approach recommended)
2. **Implement Feature** with tests in mind
3. **Verify Coverage** meets requirements:
   ```bash
   flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

#### **Test Categories**

**Unit Tests** - Test business logic in isolation:

- `MidiState` operations (note on/off, channel selection)
- MIDI message parsing and validation
- Data model transformations
- Utility functions and calculations

**Widget Tests** - Test UI components:

- Piano keyboard interactions
- MIDI settings UI
- State-driven UI updates
- Error state displays

**Integration Tests** - Test complete workflows:

- MIDI device connection flow
- Note playing with visual feedback
- Settings persistence and retrieval

#### **Critical Testing Areas**

**MIDI Functionality** (High Priority):

```dart
// Example: Test MIDI state management
testWidgets('MidiState should handle note on/off correctly', (tester) async {
  final midiState = MidiState();
  midiState.noteOn(60, 127, 1);
  expect(midiState.activeNotes.contains(60), true);
  midiState.noteOff(60, 1);
  expect(midiState.activeNotes.contains(60), false);
});
```

**Error Handling** (Required):

- MIDI connection failures
- Invalid note ranges
- Bluetooth permission denials
- Device disconnection scenarios

**Edge Cases** (Required):

- Rapid note on/off events
- Multiple simultaneous notes
- Channel switching during playback
- Memory cleanup and disposal

#### **Test Organization**

Tests mirror the source code structure for easy navigation and maintenance:

```
test/
├── models/
│   └── midi_state_test.dart         # Tests lib/models/midi_state.dart
├── pages/
│   ├── play_page_test.dart          # Tests lib/pages/play_page.dart
│   ├── midi_settings_page_test.dart # Tests lib/pages/midi_settings_page.dart
│   └── device_controller_page_test.dart # Tests lib/pages/device_controller_page.dart
├── widget_integration_test.dart     # Cross-component integration tests
└── widget_test.dart                 # Main app structure tests
```

**Guidelines**:

- Place tests in `test/` directory following source structure
- Mirror source file structure: `lib/models/midi_state.dart` → `test/models/midi_state_test.dart`
- Group related tests with descriptive names
- Use `setUp()` and `tearDown()` for test isolation
- Run specific test categories: `flutter test test/models/` or `flutter test test/pages/`

#### **Developer Test Workflow**

**When modifying existing code**:

1. Find related tests: `lib/models/midi_state.dart` → `test/models/midi_state_test.dart`
2. Run existing tests: `flutter test test/models/midi_state_test.dart`
3. Update tests for new functionality
4. Verify coverage: `flutter test --coverage`

**When adding new files**:

1. Create corresponding test file in matching directory structure
2. Write tests following existing patterns (see `test/models/midi_state_test.dart`)
3. Ensure ≥80% coverage for new code

#### **Mocking Guidelines**

```dart
// Mock MIDI devices for testing
class MockMidiDevice extends Mock implements MidiDevice {}

// Mock Bluetooth functionality
class MockBluetoothManager extends Mock implements BluetoothManager {}
```

#### **Coverage Verification**

- Review HTML coverage report before submitting changes
- Ensure all new code paths are tested
- Pay special attention to error handling branches
- Document any intentionally untested code with reasons

### 🎯 **Current Coverage Status**

- **MidiState**: 79% (Target: 80%+) ✅
- **Overall Project**: Baseline established
- **Goal**: Maintain 80%+ coverage for all new features

## Documentation

- Update README.md for user-facing changes
- Update docs/specifications/ for architectural changes
- Add inline documentation for complex algorithms
- Use dartdoc comments for public APIs

## Git Workflow

### **Automated Code Quality with Lefthook**

This project uses [lefthook](https://github.com/evilmartians/lefthook) for automated code quality checks via git hooks.

**Installation** (one-time setup):

```bash
# Install lefthook globally
brew install lefthook  # macOS
# or
npm install -g lefthook  # Cross-platform

# Install hooks in the project
cd app
lefthook install
```

**Automated Checks**:

- **Pre-commit**: Automatically formats code and runs `flutter analyze`
- **Pre-push**: Runs full test suite before pushing
- **Commit-msg**: (Optional) Validates conventional commit format

**Manual Commands**:

```bash
# Run all pre-commit checks manually
lefthook run pre-commit

# Run specific checks
dart format .
flutter analyze
flutter test
```

### **Pre-Commit Requirements**

1. **Run Tests**: `flutter test --coverage`
2. **Verify Coverage**: Meets 80% threshold for new/modified code
3. **Code Quality**: `flutter analyze` passes without errors
4. **Formatting**: `dart format .` applied

**Note**: Steps 3-4 are automatically handled by lefthook pre-commit hooks.

### **Commit Guidelines**

- Use descriptive commit messages
- Create feature branches for new functionality
- Keep commits focused and atomic
- **Include tests with ALL changes** (not optional)

### **Pull Request Checklist**

- [ ] Tests written and passing
- [ ] Coverage requirements met (≥80% for new code)
- [ ] No analyzer warnings
- [ ] Code formatted consistently
- [ ] Documentation updated if needed

## Questions or Issues?

- Check existing documentation in `docs/specifications/`
- Review Flutter and Dart documentation
- Test changes thoroughly on multiple platforms
- Consider performance implications of MIDI operations
