w# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Package Management
**IMPORTANT**: Always use Flutter CLI commands for package management, never edit pubspec.yaml manually:

```bash
# Add dependencies
flutter pub add package_name
flutter pub add --dev package_name  # dev dependencies
flutter pub add package_name:^1.0.0  # specific version

# Remove dependencies  
flutter pub remove package_name

# Update dependencies
flutter pub get        # after manual changes
flutter pub upgrade    # upgrade to latest compatible
flutter pub outdated   # check for updates
```

### Development Workflow
```bash
# Run app
flutter run
flutter run -d device_id  # specific device
flutter run --release     # release mode

# Code quality (REQUIRED before commits)
flutter analyze     # static analysis
dart format .       # format code
dart fix --apply    # auto-fix issues

# Testing (MANDATORY for all changes)
flutter test                    # all tests
flutter test test/file_test.dart # specific test
flutter test --coverage        # with coverage

# Coverage Analysis (REQUIRED)
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # View coverage report

# Pre-commit checklist
# 1. Tests pass: flutter test
# 2. Coverage ≥80%: flutter test --coverage  
# 3. No analyzer issues: flutter analyze
# 4. Code formatted: dart format .

# Building
flutter build apk    # Android
flutter build ios    # iOS  
flutter build web    # Web
flutter build macos  # macOS
```

## Architecture Overview

Piano Fitness is a Flutter app focused on piano practice with MIDI integration. The app has been refactored into a modular structure separating piano interaction from MIDI configuration.

### Core Architecture Pattern

**Separation of Concerns**: The app uses a page-based architecture where each major function is isolated:

- **PlayPage** (`lib/pages/play_page.dart`) - Main interface focused on piano interaction
- **MidiSettingsPage** (`lib/pages/midi_settings_page.dart`) - Dedicated MIDI device configuration  
- **DeviceControllerPage** (`lib/pages/device_controller_page.dart`) - Individual MIDI device control

### Navigation Flow
1. App opens to PlayPage (piano-focused interface)
2. Settings gear icon → MidiSettingsPage (MIDI configuration)
3. Connected device → DeviceControllerPage (device-specific controls)

### Key Dependencies
- **flutter_midi_command** (^0.5.1) - MIDI device communication and Bluetooth handling
- **piano** (^1.0.4) - Interactive piano keyboard UI component
- **cupertino_icons** (^1.0.8) - iOS-style icons

### MIDI Integration Patterns

The app handles complex MIDI workflows across multiple pages:

**Device Discovery & Connection** (MidiSettingsPage):
- Bluetooth permission handling with user dialogs
- Device scanning with timeout and error handling  
- Connection state management with retry mechanisms
- Comprehensive error states (simulator limitations, Bluetooth off, permissions)

**Real-time MIDI Processing** (All pages with MIDI):
- StreamSubscription pattern for MIDI data
- Message filtering (ignores beat clock 0xF8, active sense 0xFE)
- Note/CC/Program/Pitch bend message parsing
- Proper resource disposal in dispose() methods

**Virtual MIDI Output**:
- NoteOnMessage/NoteOffMessage with fallback to raw MIDI bytes
- Channel selection (0-15, displayed as 1-16)
- Velocity and timing control

### State Management Strategy

Uses Flutter's built-in StatefulWidget pattern:
- Local state for UI interactions and MIDI data
- StreamSubscriptions for real-time MIDI events
- setState() for UI updates from MIDI callbacks
- Proper subscription cleanup in dispose() methods

### Error Handling Patterns

**MIDI Connection Errors**:
- Graceful fallback when Bluetooth unavailable
- User-friendly error messages with troubleshooting tips  
- Retry mechanisms with reset functionality
- Platform-specific guidance (simulator vs device)

**Development Considerations**:
- Debug logging with `if (kDebugMode)` guards
- Exception handling around MIDI operations
- Timeout handling for Bluetooth operations

### Code Organization

```
lib/
├── main.dart              # App entry point, routes to PlayPage
├── pages/                 # Full-page components
│   ├── play_page.dart     # Main piano interface
│   ├── midi_settings_page.dart  # MIDI configuration
│   └── device_controller_page.dart  # Device controls
```

**Import Conventions** (from copilot-instructions.md):
1. Dart core libraries first
2. Flutter framework libraries  
3. Third-party packages
4. Local imports last

### Testing Strategy

The codebase follows Flutter testing patterns with **mandatory test coverage requirements**:

#### **Test Coverage Requirements**
- **New Features**: Must have ≥80% test coverage for all new code
- **Bug Fixes**: Must include regression tests to prevent re-occurrence  
- **Refactoring**: Must maintain or improve existing test coverage
- **MIDI Functionality**: Requires comprehensive unit tests due to complexity

#### **Testing Workflow** (MANDATORY)
1. **Before Development**: Check current coverage baseline
   ```bash
   flutter test --coverage
   ```

2. **During Development**: Write tests alongside code
   - Unit tests for business logic (models, utilities)
   - Widget tests for UI components  
   - Integration tests for MIDI workflows

3. **After Development**: Verify coverage meets requirements
   ```bash
   flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html  # Review coverage report
   ```

4. **Coverage Verification**: Ensure all critical paths are tested
   - Core MIDI operations (note on/off, device connection)
   - State management changes (MidiState, UI updates)
   - Error handling and edge cases
   - User interaction flows

#### **Test Organization**
- Widget tests for UI components
- Unit tests for business logic (MidiState, data models)
- Mock external dependencies (MIDI devices, Bluetooth)
- Test error scenarios and edge cases
- Integration tests for complete workflows

#### **Current Test Coverage**
- **MidiState**: 79% coverage (45/57 lines) ✅
- **Target**: 80%+ for all new/modified code
- **Critical Areas**: MIDI message handling, state management, UI integration

### MIDI Platform Considerations

**Simulator Limitations**: MIDI/Bluetooth functionality requires physical devices
**Permission Handling**: Proactive Bluetooth permission requests with explanatory dialogs
**Cross-platform**: Supports iOS, Android, desktop platforms with flutter_midi_command

### Development Notes

- MIDI operations can block UI - handle asynchronously
- Resource cleanup critical for MIDI streams and connections
- Use const constructors for performance optimization
- Debug mode logging essential for MIDI troubleshooting