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

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
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

- Write unit tests for business logic
- Write widget tests for UI components
- Mock external dependencies (MIDI devices, file system)
- Test error scenarios and edge cases

## Documentation

- Update README.md for user-facing changes
- Update docs/specifications/ for architectural changes
- Add inline documentation for complex algorithms
- Use dartdoc comments for public APIs

## Git Workflow

- Use descriptive commit messages
- Create feature branches for new functionality
- Keep commits focused and atomic
- Include tests with new features

## Questions or Issues?

- Check existing documentation in `docs/specifications/`
- Review Flutter and Dart documentation
- Test changes thoroughly on multiple platforms
- Consider performance implications of MIDI operations
