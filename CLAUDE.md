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
flutter test test/models/       # all model tests
flutter test test/pages/        # all page tests
flutter test test/models/midi_state_test.dart # specific model test
flutter test test/pages/play_page_test.dart   # specific page test
flutter test test/widget_integration_test.dart # integration tests
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

Piano Fitness follows a modular architecture with clear separation of concerns. Understanding the file organization is crucial for maintaining clean code and placing new logic in appropriate locations.

```
lib/
├── main.dart                    # App entry point and global configuration
├── models/                      # Data models and state management
│   ├── midi_state.dart         # Global MIDI input state (Provider pattern)
│   └── practice_session.dart   # Practice exercise orchestration
├── pages/                       # Full-page UI components
│   ├── play_page.dart          # Main piano interface (home screen)
│   ├── practice_page.dart      # Guided practice exercises
│   ├── midi_settings_page.dart # MIDI device configuration
│   └── device_controller_page.dart # Individual device control
├── services/                    # Business logic and external integrations
│   └── midi_service.dart       # Centralized MIDI message parsing
├── utils/                       # Helper functions and music theory
│   ├── note_utils.dart         # Note conversion utilities
│   ├── scales.dart             # Scale definitions and generation
│   ├── chords.dart             # Chord theory and progressions
│   ├── arpeggios.dart          # Arpeggio pattern generation
│   ├── piano_range_utils.dart  # Dynamic keyboard range calculation
│   └── virtual_piano_utils.dart # Virtual piano playback utilities
└── widgets/                     # Reusable UI components
    ├── midi_status_indicator.dart    # MIDI activity indicator
    ├── practice_progress_display.dart # Practice progress visualization
    └── practice_settings_panel.dart  # Practice configuration panel
```

#### **File Purpose and Logic Placement Guide**

**main.dart** - Application Bootstrap
- App initialization, theme configuration, Provider setup
- Routes to PlayPage as home screen
- Global state management configuration

**models/** - Data and State Management
- **midi_state.dart**: Global MIDI state using ChangeNotifier pattern
  - Real-time MIDI input tracking, channel selection, activity indicators
  - Used by all pages requiring MIDI functionality
- **practice_session.dart**: Practice exercise coordination
  - Exercise state, progress tracking, mode-specific logic
  - Bridges MIDI input with music theory utilities

**pages/** - User Interface Screens
- **play_page.dart**: Main piano interface with 49-key layout
  - Educational content, virtual piano interaction, MIDI activity display
  - 20% screen height for piano (4:1 flex ratio with content)
- **practice_page.dart**: Structured practice with real-time feedback
  - Dynamic piano range centered on exercises, progress tracking
  - Integration with PracticeSession model
- **midi_settings_page.dart**: Device discovery and configuration
  - Bluetooth scanning, connection management, error handling
- **device_controller_page.dart**: Advanced device testing and control
  - MIDI message monitoring, interactive controls, device diagnostics

**services/** - Business Logic Layer
- **midi_service.dart**: MIDI message parsing and event handling
  - Converts raw MIDI bytes to structured MidiEvent objects
  - Handles all MIDI message types with validation and filtering
  - Use this for any MIDI protocol-level functionality

**utils/** - Music Theory and Helper Functions
- **note_utils.dart**: Core note conversion utilities
  - MIDI ↔ Note name ↔ Piano position conversions
  - Use for any note-related transformations
- **scales.dart**: Musical scale definitions and sequence generation
  - 8 scale types, all 12 keys, MIDI sequence generation
  - Add new scale types here, not in pages
- **chords.dart**: Chord theory implementation and progressions
  - Chord types, inversions, smooth voice leading
  - Extend for new chord functionality
- **arpeggios.dart**: Arpeggio pattern definitions
  - Major/minor/7th arpeggios, octave range support
  - Add new arpeggio types here
- **piano_range_utils.dart**: Dynamic keyboard range calculation
  - 49-key layout optimization, exercise-centered ranges
  - Modify for new keyboard layout algorithms
- **virtual_piano_utils.dart**: Virtual piano note playback
  - MIDI output for virtual piano interaction
  - Timing management, resource cleanup

**widgets/** - Reusable UI Components
- **midi_status_indicator.dart**: MIDI activity status display
  - Color-coded indicators, recent message display
- **practice_progress_display.dart**: Practice session visualization
  - Mode-specific progress bars and information
- **practice_settings_panel.dart**: Practice configuration interface
  - Mode selection, parameter controls, validation

#### **Architecture Principles for New Code**

1. **Page Logic**: Keep pages focused on UI and user interaction
   - Move complex calculations to utils/
   - Move data processing to services/
   - Move reusable components to widgets/

2. **Music Theory**: Always extend existing utils/ classes
   - Don't duplicate note conversion logic
   - Use existing scale/chord/arpeggio definitions
   - Add new music theory to appropriate util files

3. **MIDI Handling**: Centralize through services/midi_service.dart
   - Don't parse MIDI messages directly in pages
   - Use existing MidiEvent structures
   - Add new message types to the service layer

4. **State Management**: Use Provider pattern consistently
   - Global MIDI state in models/midi_state.dart
   - Local UI state in page StatefulWidgets
   - Exercise state in models/practice_session.dart

5. **Testing**: Mirror lib/ structure in test/
   - Unit tests for utils/ and services/
   - Widget tests for pages/ and widgets/
   - Integration tests for cross-component functionality

**Import Conventions**:
1. Dart core libraries first (`dart:async`, `dart:math`)
2. Flutter framework libraries (`package:flutter/material.dart`)
3. Third-party packages (`package:piano/piano.dart`)
4. Local imports last (`package:piano_fitness/...`)

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
Tests mirror the lib/ structure exactly for easy navigation and maintenance:

```
test/
├── models/                          # Data model unit tests
│   └── midi_state_test.dart        # MIDI state management (79% coverage)
├── pages/                           # Page widget tests  
│   ├── play_page_test.dart         # Main piano interface (370+ lines)
│   ├── practice_page_test.dart     # Practice exercises (340+ lines)
│   ├── midi_settings_page_test.dart # MIDI device configuration
│   └── device_controller_page_test.dart # Individual device control
├── services/                        # Service layer unit tests
│   └── midi_service_test.dart      # MIDI message parsing and validation
├── utils/                          # Music theory and utility tests
│   ├── note_utils_test.dart        # Note conversion functions
│   ├── scales_test.dart            # Scale theory (550+ lines)
│   ├── chords_test.dart            # Chord theory (625+ lines)
│   ├── arpeggios_test.dart         # Arpeggio generation
│   ├── chord_progression_test.dart  # Chord progression logic
│   ├── chord_inversion_flow_test.dart # Chord inversion patterns
│   └── piano_range_utils_test.dart  # Piano range calculations
├── widget_integration_test.dart     # Cross-component integration
└── widget_test.dart                # Main app structure
```

**Test Categories and Coverage**:

**Unit Tests** - Business Logic Verification
- **models/**: State management (MidiState: 79% coverage target: 80%+)
- **services/**: MIDI protocol handling with security validation
- **utils/**: Comprehensive music theory testing
  - 144 chord combinations (12 notes × 4 types × 3 inversions)
  - 96 scale combinations (12 keys × 8 modes)
  - Mathematical precision validation for music theory

**Widget Tests** - UI Component Integration
- **pages/**: Complete page functionality with MIDI integration
- Navigation, state management, user interaction testing
- Mock strategies for hardware dependencies

**Integration Tests** - System Workflow Validation
- Cross-component communication
- Real-time MIDI data flow
- Provider pattern integration

**Common Test Commands**:
```bash
# Development workflow
flutter test test/models/midi_state_test.dart  # Work on MidiState
flutter test test/pages/play_page_test.dart    # Work on PlayPage

# Category testing
flutter test test/models/     # All business logic tests
flutter test test/pages/      # All UI component tests

# Coverage verification
flutter test --coverage      # Check coverage meets 80% requirement
```
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

### Piano Keyboard Layout Implementation

The app features optimized 49-key piano layouts across both PlayPage and PracticePage with consistent 20% screen height allocation for better key proportions on iPad.

#### **Current Layout Specifications**

**Screen Height Distribution**:
- Content Area: 80% (flex: 4) - Settings, educational content, practice controls
- Piano Keyboard: 20% (flex: 1) - Interactive 49-key piano with proper aspect ratio

**Key Width Calculation**:
```dart
// Dynamic width based on screen size
final screenWidth = MediaQuery.of(context).size.width;
final availableWidth = screenWidth - 32; // Account for padding
final dynamicKeyWidth = availableWidth / 29; // 28 white keys + buffer
keyWidth: dynamicKeyWidth.clamp(20.0, 60.0) // Reasonable limits
```

**49-Key Range Implementation**:

**PlayPage** - Fixed Range:
- **Range**: C2 to C6 (exactly 49 keys spanning 4 octaves)
- **Purpose**: Consistent layout for general piano interaction
- **Code Location**: `lib/pages/play_page.dart` lines 387-391

**PracticePage** - Dynamic Centering:
- **Range**: Calculated to center around current exercise
- **Algorithm**: 
  1. Find min/max notes in exercise sequence
  2. Calculate center point of exercise range
  3. Create 49-key range centered on exercise
  4. Shift range if needed to include all exercise notes
  5. Clamp to reasonable piano range (A0 to C8)
- **Purpose**: Eliminates horizontal scrolling for all practice exercises
- **Code Location**: `lib/pages/practice_page.dart` lines 246-297

#### **Piano Range Calculation Logic**

**Exercise-Centered Algorithm** (PracticePage):
```dart
// Find exercise range
final minNote = exerciseNotes.reduce((a, b) => a < b ? a : b);
final maxNote = exerciseNotes.reduce((a, b) => a > b ? a : b);
final centerNote = (minNote + maxNote) ~/ 2;

// Create 49-key range (24 semitones on each side)
const rangeHalfWidth = 24;
var startNote = centerNote - rangeHalfWidth;
var endNote = centerNote + rangeHalfWidth;

// Ensure all exercise notes are visible
if (minNote < startNote) {
  final shift = startNote - minNote;
  startNote -= shift;
  endNote -= shift;
}
```

**Benefits**:
- No horizontal scrolling required for any practice exercise
- Optimal key proportions with 20% screen height
- Responsive design adapts to all screen sizes
- Consistent user experience across pages

#### **Integration with Music Theory**

The piano layouts integrate seamlessly with music theory utilities:

- **Scales**: Typically span 1-2 octaves starting from octave 4 (middle C)
- **Chords**: Use octave 4 with smart progression logic to avoid excessive range
- **Arpeggios**: Support 1-2 octave patterns based on user selection

All practice exercises are designed to fit within the 49-key constraint while maintaining musical integrity and proper voice leading.

### Development Notes

- MIDI operations can block UI - handle asynchronously
- Resource cleanup critical for MIDI streams and connections
- Use const constructors for performance optimization
- Debug mode logging essential for MIDI troubleshooting
- Piano layout changes should maintain 49-key constraint for consistency
- Exercise sequences should be validated to fit within 4-octave ranges