# AGENTS.md

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
flutter test                           # all tests
flutter test test/shared/models/       # shared model tests  
flutter test test/features/play/       # play feature tests
flutter test test/features/practice/   # practice feature tests
flutter test test/shared/models/midi_state_test.dart              # specific model test
flutter test test/features/play/play_page_test.dart               # specific page test
flutter test test/features/practice/practice_page_view_model_test.dart # specific ViewModel test
flutter test test/widget_integration_test.dart # integration tests
flutter test --coverage               # with coverage

# Coverage Analysis (REQUIRED)
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # View coverage report
# Note: genhtml (lcov) must be installed locally (e.g., `brew install lcov` or your OS equivalent).

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

Piano Fitness is a Flutter app focused on piano practice with MIDI integration. The app follows **MVVM (Model-View-ViewModel) architecture** with feature-based organization and a shared code layer for common functionality.

### Core Architecture Pattern

**MVVM with Clean Architecture**: The app uses a modern feature-based MVVM architecture where each major function is organized into self-contained modules:

- **PlayPage** (`lib/features/play/`) - Main interface focused on piano interaction
- **PracticePage** (`lib/features/practice/`) - Guided practice exercises with real-time feedback
- **MidiSettingsPage** (`lib/features/midi_settings/`) - MIDI device configuration and connection management
- **DeviceControllerPage** (`lib/features/device_controller/`) - Individual MIDI device testing and control

Each feature follows the MVVM pattern:

- **View** (Page): Pure UI layer, handles user interactions and displays data
- **ViewModel**: Business logic layer, manages state and coordinates between View and shared services
- **Model**: Data structures and business rules (in shared layer)

### Navigation Flow

1. App opens to PlayPage (piano-focused interface)  
2. Settings gear icon → MidiSettingsPage (MIDI configuration)
3. Connected device → DeviceControllerPage (device-specific controls)
4. Practice mode buttons → PracticePage (guided exercises)

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

Uses **MVVM with ChangeNotifier and Provider pattern**:

- **ViewModels**: Extend ChangeNotifier for business logic and state management
- **Provider**: Dependency injection for ViewModels and shared services
- **MidiState**: Global shared state for real-time MIDI data using ChangeNotifier
- **Local UI State**: StatefulWidget for view-specific UI state
- **StreamSubscriptions**: Real-time MIDI events handled in ViewModels
- **Resource Management**: Proper subscription cleanup in ViewModel dispose() methods

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

Piano Fitness follows a **feature-based MVVM architecture** with a shared layer for common functionality. This organization provides clear separation of concerns, excellent testability, and maintainable code structure.

```text
lib/
├── main.dart                       # App entry point and Provider configuration
├── features/                       # Feature-based MVVM modules
│   ├── device_controller/          # MIDI device testing and control
│   │   ├── device_controller_page.dart      # UI layer (View)
│   │   └── device_controller_view_model.dart # Business logic (ViewModel)
│   ├── midi_settings/              # MIDI device configuration
│   │   ├── midi_settings_page.dart          # UI layer (View)
│   │   └── midi_settings_view_model.dart    # Business logic (ViewModel)
│   ├── play/                       # Main piano interface
│   │   ├── play_page.dart                   # UI layer (View)
│   │   └── play_page_view_model.dart        # Business logic (ViewModel)
│   └── practice/                   # Guided practice exercises
│       ├── practice_page.dart               # UI layer (View)
│       └── practice_page_view_model.dart    # Business logic (ViewModel)
└── shared/                         # Common code shared across features
    ├── models/                     # Data models and business entities
    │   ├── midi_state.dart         # Global MIDI state (ChangeNotifier)
    │   └── practice_session.dart   # Practice exercise coordination
    ├── services/                   # Business logic and external integrations
    │   └── midi_service.dart       # Centralized MIDI message parsing
    ├── utils/                      # Helper functions and music theory
    │   ├── note_utils.dart         # Note conversion utilities
    │   ├── scales.dart             # Scale definitions and generation
    │   ├── chords.dart             # Chord theory and progressions
    │   ├── arpeggios.dart          # Arpeggio pattern generation
    │   ├── piano_range_utils.dart  # Dynamic keyboard range calculation
    │   └── virtual_piano_utils.dart # Virtual piano playback utilities
    └── widgets/                    # Reusable UI components
        ├── midi_status_indicator.dart    # MIDI activity indicator
        ├── practice_progress_display.dart # Practice progress visualization
        └── practice_settings_panel.dart  # Practice configuration panel
```

#### **File Purpose and Logic Placement Guide**

**main.dart** - Application Bootstrap

- App initialization, theme configuration, Provider setup
- Routes to PlayPage as home screen  
- Global ChangeNotifier providers (MidiState)

**features/** - Feature-Based MVVM Modules
Each feature follows the same MVVM pattern with clear separation:

**features/play/** - Main Piano Interface

- **play_page.dart**: UI layer for piano interaction
  - Educational content, navigation to other features
  - Interactive piano with virtual note playing
  - 20% screen height for piano (4:1 flex ratio with content)
- **play_page_view_model.dart**: Business logic for play functionality
  - MIDI data processing, virtual piano playback
  - Note conversion and piano range calculations

**features/practice/** - Guided Practice Exercises  

- **practice_page.dart**: UI layer for practice sessions
  - Practice settings panel, progress display, dynamic piano range
  - Exercise completion feedback and real-time highlighting
- **practice_page_view_model.dart**: Business logic for practice functionality
  - Practice session management, MIDI integration
  - Dynamic piano range calculation centered on exercises

**features/midi_settings/** - MIDI Device Configuration

- **midi_settings_page.dart**: UI layer for MIDI setup
  - Device scanning, connection management, error handling
  - Bluetooth permission handling with user dialogs
- **midi_settings_view_model.dart**: Business logic for MIDI operations
  - Device discovery, connection state management
  - MIDI channel selection and device communication

**features/device_controller/** - MIDI Device Testing

- **device_controller_page.dart**: UI layer for device control
  - MIDI message monitoring, interactive controls
  - Real-time message display and device diagnostics
- **device_controller_view_model.dart**: Business logic for device control
  - MIDI message sending/receiving, device state management
  - Advanced MIDI operations and diagnostics

**shared/** - Common Code Layer
All code shared across features, organized by responsibility:

**shared/models/** - Data Models and Business Entities

- **midi_state.dart**: Global MIDI state using ChangeNotifier pattern
  - Real-time MIDI input tracking, channel selection, activity indicators
  - Used by all ViewModels requiring MIDI functionality
- **practice_session.dart**: Practice exercise coordination
  - Exercise state, progress tracking, mode-specific logic
  - Bridges MIDI input with music theory utilities

**domain/services/** - Pure Business Logic (No External Dependencies)

- **midi/midi_service.dart**: MIDI protocol parsing and event handling
  - Converts raw MIDI bytes to structured MidiEvent objects
  - Handles all MIDI message types with validation and filtering
  - Use this for any MIDI protocol-level functionality

**application/services/** - Infrastructure and Platform Integrations

- **midi/midi_connection_service.dart**: MIDI device lifecycle management
  - Wraps flutter_midi_command plugin for device discovery and connection
  - Singleton pattern for centralized MIDI connection state
- **notifications/notification_service.dart**: Local notification management
  - Wraps flutter_local_notifications plugin for scheduling and display
  - Platform-specific setup for iOS, Android, macOS
- **notifications/notification_manager.dart**: Notification settings persistence
  - Uses SharedPreferences for storing notification preferences
  - Manages NotificationSettings data model

**shared/utils/** - Music Theory and Helper Functions

- **note_utils.dart**: Core note conversion utilities
  - MIDI ↔ Note name ↔ Piano position conversions
  - Use for any note-related transformations
- **scales.dart**: Musical scale definitions and sequence generation
  - 8 scale types, all 12 keys, MIDI sequence generation
  - Add new scale types here, not in features
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

**shared/widgets/** - Reusable UI Components

- **midi_status_indicator.dart**: MIDI activity status display
  - Color-coded indicators, recent message display
- **practice_progress_display.dart**: Practice session visualization
  - Mode-specific progress bars and information
- **practice_settings_panel.dart**: Practice configuration interface
  - Mode selection, parameter controls, validation

#### **Architecture Principles for New Code**

**MVVM Pattern Compliance**:

1. **View (Page)**: Keep pages focused purely on UI and user interaction
   - Handle user inputs and delegate to ViewModel
   - Use AnimatedBuilder/Consumer to react to ViewModel changes
   - No business logic in pages - only UI state management
   - Move complex calculations to ViewModel or shared utilities

2. **ViewModel**: Business logic layer extending ChangeNotifier
   - Handle all feature-specific business logic
   - Coordinate between View and shared services/models
   - Manage feature-specific state and notify View of changes
   - Process MIDI data, manage practice sessions, device operations
   - Proper resource cleanup in dispose() method

3. **Shared Layer**: Common functionality across features
   - **Models**: Data structures and global state (MidiState, PracticeSession)
   - **Services**: External integrations and protocol handling (MIDI)
   - **Utils**: Pure functions and music theory (no state)
   - **Widgets**: Reusable UI components

**Development Guidelines**:
4. **Music Theory**: Always extend existing domain/services/music_theory/ classes

- Don't duplicate note conversion logic
- Use existing scale/chord/arpeggio definitions  
- Add new music theory to domain services, not features

5. **MIDI Handling**: Centralize through domain/services/midi/midi_service.dart
   - Don't parse MIDI messages directly in ViewModels
   - Use existing MidiEvent structures
   - Add new message types to the domain service layer

6. **State Management**: Use MVVM with Provider pattern
   - **Global State**: shared/models/midi_state.dart (ChangeNotifier)
   - **Feature State**: ViewModel extends ChangeNotifier
   - **UI State**: StatefulWidget for view-specific UI state only
   - **Business State**: Models like PracticeSession in shared layer

7. **Testing**: Mirror lib/ structure in test/
   - Unit tests for shared/utils/, domain/services/, application/services/, and ViewModels  
   - Widget tests for feature pages and shared/widgets/
   - Integration tests for cross-feature functionality

**Import Conventions**:

1. Dart core libraries first (`dart:async`, `dart:math`)
2. Flutter framework libraries (`package:flutter/material.dart`)
3. Third-party packages (`package:piano/piano.dart`)
4. Local imports in order:
   - Feature imports: `package:piano_fitness/features/...`
   - Domain imports: `package:piano_fitness/domain/...`
   - Application imports: `package:piano_fitness/application/...`
   - Shared imports: `package:piano_fitness/shared/...`

**Import Examples**:

```dart
// ViewModel importing shared utilities
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";

// Page importing its ViewModel and shared widgets
import "package:piano_fitness/features/practice/practice_page_view_model.dart";
import "package:piano_fitness/shared/widgets/practice_settings_panel.dart";
```

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

```text
test/
├── features/                        # Feature-based MVVM tests
│   ├── device_controller/           # Device controller feature tests
│   │   ├── device_controller_page_test.dart      # UI tests
│   │   └── device_controller_view_model_test.dart # Business logic tests
│   ├── midi_settings/               # MIDI settings feature tests
│   │   ├── midi_settings_page_test.dart          # UI tests
│   │   └── midi_settings_view_model_test.dart    # Business logic tests
│   ├── play/                        # Play feature tests
│   │   ├── play_page_test.dart                   # UI tests (370+ lines)
│   │   └── play_page_view_model_test.dart        # Business logic tests
│   └── practice/                    # Practice feature tests
│       ├── practice_page_test.dart               # UI tests (275+ lines)
│       └── practice_page_view_model_test.dart    # Business logic tests (321+ lines)
├── shared/                          # Shared code tests
│   ├── models/                      # Data model unit tests
│   │   └── midi_state_test.dart    # MIDI state management (79% coverage)
│   ├── services/                    # Service layer unit tests
│   │   └── midi_service_test.dart  # MIDI message parsing and validation
│   ├── utils/                       # Music theory and utility tests
│   │   ├── note_utils_test.dart    # Note conversion functions
│   │   ├── scales_test.dart        # Scale theory (550+ lines)
│   │   ├── chords_test.dart        # Chord theory (625+ lines)
│   │   ├── arpeggios_test.dart     # Arpeggio generation
│   │   ├── chord_progression_test.dart      # Chord progression logic
│   │   ├── chord_inversion_flow_test.dart   # Chord inversion patterns
│   │   └── piano_range_utils_test.dart      # Piano range calculations
│   └── widgets/                     # Shared widget tests
│       └── practice_settings_panel_test.dart
├── widget_integration_test.dart     # Cross-feature integration
└── widget_test.dart                # Main app structure
```

**Test Categories and Coverage**:

**Unit Tests** - Business Logic Verification

- **ViewModel Tests**: Business logic for each feature
  - Practice: 321+ lines of comprehensive ViewModel tests
  - Play: MIDI processing and piano interaction tests  
  - MIDI Settings: Device management and connection tests
  - Device Controller: MIDI device control and diagnostics tests
- **Shared Models**: State management (MidiState: 79% coverage, target: 80%+)
- **Shared Services**: MIDI protocol handling with security validation
- **Shared Utils**: Comprehensive music theory testing
  - 144 chord combinations (12 notes × 4 types × 3 inversions)
  - 96 scale combinations (12 keys × 8 modes)
  - Mathematical precision validation for music theory

**Widget Tests** - UI Component Integration  

- **Feature Pages**: Complete page functionality with MVVM integration
  - UI rendering, user interaction, ViewModel integration
  - Navigation, state management, reactive UI updates
- **Shared Widgets**: Reusable components across features
- Mock strategies for hardware dependencies and ViewModels

**Integration Tests** - System Workflow Validation

- Cross-feature communication
- Real-time MIDI data flow
- Provider pattern and MVVM integration

**Common Test Commands**:

```bash
# Development workflow - MVVM features
flutter test test/features/practice/practice_page_view_model_test.dart  # ViewModel logic
flutter test test/features/practice/practice_page_test.dart             # UI tests
flutter test test/shared/models/midi_state_test.dart                    # Shared state

# Feature testing
flutter test test/features/play/       # All play feature tests
flutter test test/features/practice/   # All practice feature tests
flutter test test/shared/             # All shared code tests

# Coverage verification
flutter test --coverage              # Check coverage meets 80% requirement
```

- Test error scenarios and edge cases
- Integration tests for complete workflows

#### **Current Test Coverage**

- **MidiState**: target ≥80% coverage (verify via coverage report) ✅
- **Practice Feature**: ViewModel tests should maintain ≥80% coverage
- **Play Feature**: Maintain complete MVVM coverage as code evolves
- **Target**: 80%+ for all new/modified code
- **Critical Areas**: MIDI message handling, ViewModel business logic, UI integration

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
final dynamicKeyWidth = availableWidth / 29; // 29 white keys (C..C over 4 octaves)
keyWidth: dynamicKeyWidth.clamp(20.0, 60.0) // Reasonable limits
```

**49-Key Range Implementation**:

**PlayPage** - Fixed Range (MVVM):

- **Range**: C2 to C6 (exactly 49 keys spanning 4 octaves)
- **Purpose**: Consistent layout for general piano interaction
- **Implementation**:
  - **ViewModel**: `lib/features/play/play_page_view_model.dart` - `getFixed49KeyRange()`
  - **View**: `lib/features/play/play_page.dart` - Uses ViewModel for range calculation

**PracticePage** - Dynamic Centering (MVVM):

- **Range**: Calculated to center around current exercise
- **Algorithm**:
  1. Find min/max notes in exercise sequence
  2. Calculate center point of exercise range
  3. Create 49-key range centered on exercise
  4. Shift range if needed to include all exercise notes
  5. Clamp to reasonable piano range (A0 to C8)
- **Purpose**: Eliminates horizontal scrolling for all practice exercises
- **Implementation**:
  - **ViewModel**: `lib/features/practice/practice_page_view_model.dart` - `calculatePracticeRange()`
  - **View**: `lib/features/practice/practice_page.dart` - Uses ViewModel for dynamic range
  - **Shared Utility**: `lib/shared/utils/piano_range_utils.dart` - Range calculation logic

#### **Piano Range Calculation Logic**

**Exercise-Centered Algorithm** (PracticePage):

1. Find the minimum and maximum notes in the current exercise
2. Calculate center point of the exercise range  
3. Create 49-key range (24 semitones on each side of center)
4. Shift range if needed to ensure all exercise notes are visible
5. Clamp final range to reasonable piano bounds (A0..C8)

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
