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
flutter test test/domain/              # domain layer tests  
flutter test test/application/         # application layer tests
flutter test test/features/play/       # play feature tests
flutter test test/features/practice/   # practice feature tests
flutter test test/domain/services/music_theory/scales_test.dart  # specific service test
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

Piano Fitness is a Flutter app focused on piano practice with MIDI integration. The app follows **Clean Architecture** with MVVM pattern in the presentation layer.

**Architecture Decisions:** All major architectural decisions are documented as ADRs (Architecture Decision Records) in `docs/ADRs/`. See the [ADR README](docs/ADRs/README.md) for a complete index.

### Core Architecture Pattern

**Clean Architecture with MVVM**: The app uses a three-layer architecture with clear separation of concerns:

- **Domain Layer** (`lib/domain/`) - Pure business logic, models, and services
- **Application Layer** (`lib/application/`) - Service orchestration, repositories, state management
- **Presentation Layer** (`lib/features/`) - UI, ViewModels, feature-specific components

Each feature follows the MVVM pattern:

- **PlayPage** (`lib/features/play/`) - Main interface focused on piano interaction
- **PracticePage** (`lib/features/practice/`) - Guided practice exercises with real-time feedback
- **MidiSettingsPage** (`lib/features/midi_settings/`) - MIDI device configuration and connection management
- **DeviceControllerPage** (`lib/features/device_controller/`) - Individual MIDI device testing and control

- **View** (Page): Pure UI layer, handles user interactions and displays data
- **ViewModel**: Feature-specific business logic, manages state and coordinates between View and domain/application layers
- **Model**: Data structures and business rules (in domain layer)

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

### Dependency Injection Pattern (Phase 2 Complete ✅)

**Repository Interfaces** define contracts for external dependencies:

```dart
// domain/repositories/midi_repository.dart
abstract class IMidiRepository {
  Stream<MidiMessage> get messageStream;
  Future<void> connect();
  Future<void> disconnect();
  Future<void> sendMessage(MidiMessage message);
}
```

**ViewModels receive dependencies via constructor:**

```dart
class PlayPageViewModel extends ChangeNotifier {
  final IMidiRepository _midiRepository;
  
  PlayPageViewModel({required IMidiRepository midiRepository})
      : _midiRepository = midiRepository;
}
```

**Pages provide ViewModels using ChangeNotifierProvider:**

```dart
ChangeNotifierProvider(
  create: (context) => PlayPageViewModel(
    midiRepository: context.read<IMidiRepository>(),
  ),
  child: PlayPageContent(),
)
```

**Provider configuration in main.dart:**

```dart
MultiProvider(
  providers: [
    Provider<IMidiRepository>(create: (_) => MidiConnectionService.instance),
    ChangeNotifierProvider(create: (_) => MidiState()),
  ],
  child: MyApp(),
)
```

**Tests use mock repositories:**

```dart
final mockMidiRepository = MockMidiRepository();
final viewModel = PlayPageViewModel(midiRepository: mockMidiRepository);
```

See `test/shared/test_helpers/mock_repositories.dart` for available mocks.

**Benefits of DI:**
- ✅ Testability: Easy to mock dependencies in tests
- ✅ Flexibility: Swap implementations without changing ViewModels
- ✅ Clarity: Explicit dependencies visible in constructor
- ✅ Coverage: Enables 80%+ test coverage for ViewModels

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
├── domain/                         # Domain Layer (Pure Business Logic)
│   ├── models/                     # Domain entities and value objects
│   │   ├── music/                  # Musical concepts (chord types, progressions)
│   │   └── practice/               # Practice domain models (exercise, strategies)
│   ├── services/                   # Domain services and business logic
│   │   ├── music_theory/           # Music theory algorithms
│   │   │   ├── scales.dart         # Scale definitions and generation
│   │   │   ├── chord_builder.dart  # Chord construction logic
│   │   │   ├── arpeggios.dart      # Arpeggio pattern generation
│   │   │   └── note_utils.dart     # Note conversion utilities
│   │   └── midi/                   # MIDI protocol domain services
│   │       └── midi_service.dart   # MIDI message parsing and events
│   └── constants/                  # Domain-level constants
│       ├── musical_constants.dart  # Musical theory constants
│       └── practice_constants.dart # Practice-related constants
├── application/                    # Application Layer (Service Orchestration)
│   ├── services/                   # Infrastructure integrations
│   │   └── midi/                   # MIDI device management
│   │       └── midi_connection_service.dart # Device lifecycle and connection
│   ├── state/                      # Application-wide state management
│   │   ├── midi_state.dart         # MIDI state (ChangeNotifier)
│   │   └── practice_session.dart   # Practice session coordination
│   └── utils/                      # Application utilities
│       └── virtual_piano_utils.dart # Virtual piano playback
└── presentation/                   # Presentation Layer (UI & ViewModels)
    ├── shared/                     # Shared presentation components
    │   └── widgets/                # Reusable UI components
    │       ├── midi_status_indicator.dart    # MIDI activity indicator
    │       ├── practice_progress_display.dart # Practice visualization
    │       └── practice_settings_panel.dart  # Practice configuration
    └── utils/                      # Presentation utilities
        └── piano_range_utils.dart  # Dynamic keyboard range calculation
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

### Three-Layer Architecture

The codebase follows clean architecture principles with clear separation:

**domain/** - Domain Layer (Pure Business Logic)

Contains the core business logic independent of frameworks and external dependencies:

- **models/** - Domain entities and value objects
  - `music/` - Musical concepts (chord types, progressions, hand selection)
  - `practice/` - Practice domain models (exercise, practice mode, strategies)
- **services/music_theory/** - Music theory business logic
  - `scales.dart` - Scale definitions and generation
  - `chord_builder.dart` - Chord construction logic
  - `arpeggios.dart` - Arpeggio pattern generation
  - `note_utils.dart` - Note conversion utilities
  - `circle_of_fifths.dart` - Circle of fifths theory
  - `chord_inversion_utils.dart` - Chord inversion logic
- **constants/** - Domain-level constants
  - `musical_constants.dart` - Musical theory constants
  - `practice_constants.dart` - Practice-related constants

**application/** - Application Layer (Service Orchestration)

Coordinates between domain and infrastructure:

- **services/** - Infrastructure integrations

- **midi/midi_service.dart**: MIDI protocol parsing and event handling
  - Converts raw MIDI bytes to structured MidiEvent objects
  - Handles all MIDI message types with validation and filtering
  - Use this for any MIDI protocol-level functionality

  - `midi/` - MIDI device management
    - `midi_connection_service.dart` - Device lifecycle and connection
  - `notifications/` - Local notifications
    - `notification_service.dart` - Notification scheduling
    - `notification_manager.dart` - Settings persistence
- **state/** - Application-wide state (future: global MIDI state)

**presentation/** - Presentation Layer (UI & ViewModels)

UI components, ViewModels, and presentation logic:

- **features/** - Feature modules with MVVM pattern
  - Each feature contains pages, ViewModels, and feature-specific widgets
- **shared/widgets/** - Reusable UI components
  - `midi_status_indicator.dart` - MIDI activity display
  - `practice_progress_display.dart` - Practice visualization
  - `practice_settings_panel.dart` - Practice configuration
- **utils/** - Presentation utilities
  - `piano_key_utils.dart` - Piano key identification
  - `piano_range_utils.dart` - Dynamic keyboard range
  - `virtual_piano_utils.dart` - Virtual piano playback
- **constants/** - UI/presentation constants
  - `ui_constants.dart` - Spacing, sizing, opacity values
  - `typography_constants.dart` - Text styling constants

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

3. **Domain Layer**: Pure business logic and models
   - **Models**: Domain entities (chord types, exercise, practice mode)
   - **Services**: Music theory algorithms (scales, chords, arpeggios)
   - **Constants**: Domain-level constants
   - No dependencies on frameworks or external libraries

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
   - **Global State**: application/state/ (future refactor)
   - **Feature State**: ViewModel extends ChangeNotifier
   - **UI State**: StatefulWidget for view-specific UI state only
   - **Business Logic**: Domain services for pure business logic

7. **Testing**: Mirror lib/ structure in test/
   - Unit tests for domain/services/, application/services/, and ViewModels  
   - Widget tests for feature pages and presentation/shared/widgets/
   - Integration tests for cross-feature functionality

**Import Conventions**:

1. Dart core libraries first (`dart:async`, `dart:math`)
2. Flutter framework libraries (`package:flutter/material.dart`)
3. Third-party packages (`package:piano/piano.dart`)
4. Local imports in order:
   - Domain imports: `package:piano_fitness/domain/...`
   - Application imports: `package:piano_fitness/application/...`
   - Presentation imports: `package:piano_fitness/presentation/...`
   - Feature imports: `package:piano_fitness/features/...`

**Import Examples**:

```dart
// ViewModel importing domain services and application services
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart";
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";

// Page importing its ViewModel and presentation widgets
import "package:piano_fitness/features/practice/practice_page_view_model.dart";
import "package:piano_fitness/presentation/shared/widgets/practice_settings_panel.dart";
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

**Test Structure Mirrors Source Code**: Tests follow the exact same directory structure as `lib/` for easy navigation and maintenance.

**Naming Convention**: For each source file, create a corresponding test file with `_test.dart` suffix:
- `lib/features/play/play_page.dart` → `test/features/play/play_page_test.dart`
- `lib/domain/services/music_theory/scales.dart` → `test/domain/services/music_theory/scales_test.dart`
- `lib/application/state/midi_state.dart` → `test/application/state/midi_state_test.dart`

**Running Specific Test Categories**:
```bash
flutter test test/domain/              # All domain layer tests
flutter test test/application/         # All application layer tests
flutter test test/features/play/       # Play feature tests
flutter test test/features/practice/   # Practice feature tests
```

**Test Categories and Coverage**:

**Unit Tests** - Business Logic Verification

- **ViewModel Tests**: Business logic for each feature
  - Practice: 321+ lines of comprehensive ViewModel tests
  - Play: MIDI processing and piano interaction tests  
  - MIDI Settings: Device management and connection tests
  - Device Controller: MIDI device control and diagnostics tests
- **Domain Services**: Music theory algorithm tests (scales, chords, arpeggios)
  - 144 chord combinations (12 notes × 4 types × 3 inversions)
  - 96 scale combinations (12 keys × 8 modes)
  - Mathematical precision validation for music theory
- **Application State**: State management tests
  - MidiState: 79% coverage (target: 80%+)
  - PracticeSession: Exercise coordination and progress
- **Application Services**: MIDI connection and protocol handling with security validation

**Widget Tests** - UI Component Integration  

- **Feature Pages**: Complete page functionality with MVVM integration
  - UI rendering, user interaction, ViewModel integration
  - Navigation, state management, reactive UI updates
- **Presentation Widgets**: Reusable UI components across features
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
flutter test test/domain/services/music_theory/scales_test.dart        # Domain services

# Layer testing
flutter test test/domain/              # All domain layer tests
flutter test test/application/         # All application layer tests
flutter test test/features/play/       # Play feature tests
flutter test test/features/practice/   # Practice feature tests

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
  - **Presentation Utility**: `lib/presentation/utils/piano_range_utils.dart` - Range calculation logic

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

---

## 🏗️ Code Quality and Architecture Principles

### SOLID Principles Enforcement

**Single Responsibility Principle (SRP)**

- **One Reason to Change**: Each widget, class, and function should have only one reason to change
- **Flutter-Specific Rule**: Widgets ≠ Services ≠ Business Logic - always separate them
- **Layer Separation**: UI rendering, data fetching, and navigation should be in different classes
- **Constructor Warning**: Large constructors (>5-8 parameters) indicate SRP violations
- **Conditional Logic**: Complex conditional UI logic suggests need for component separation
- **Break widgets doing multiple responsibilities into focused components**

**Open/Closed Principle (OCP)**

- **Open for Extension, Closed for Modification**: Add new functionality without changing existing code
- **Avoid If-Else Chains**: Replace conditional logic with abstract classes or interfaces
- **Future-Proof Design**: Use abstractions so new features don't require modifying existing classes
- **Composition Over Inheritance**: Prefer composition for extending functionality
- **Interface-Based Extensions**: Use abstract base classes and interfaces for extensible designs
- **Implement abstractions for extensibility**: Instead of adding new types to a switch statement, implement interfaces

**Liskov Substitution Principle (LSP)**

- Subtypes must be substitutable for their base types without breaking functionality
- Don't override methods in ways that violate parent class expectations
- If behavior differs significantly, prefer composition over inheritance
- Avoid extending Flutter's built-in widgets (ElevatedButton, etc.) - use composition instead

**Interface Segregation Principle (ISP)**

- Split large interfaces into smaller, focused contracts
- Classes should only implement methods they actually need
- Prefer many small interfaces over one large interface
- Design role-based abstractions (e.g., CanValidateEmail, CanSaveData)

**Dependency Inversion Principle (DIP)**

- Depend on abstractions (interfaces) not concrete implementations
- Use dependency injection for services and external dependencies
- Keep business logic separate from UI components

### Common Code Smells to Avoid

**General Software Development**

- **God Classes**: Classes with >300 lines or too many responsibilities
- **Long Parameter Lists**: Methods/constructors with >5 parameters (use configuration objects)
- **Feature Envy**: Classes accessing data from other classes excessively
- **Primitive Obsession**: Using primitives instead of value objects
- **Shotgun Surgery**: Changes requiring modifications in many classes

**Dart/Flutter Specific**

- **God Widgets**: Widgets handling UI + networking + navigation + business logic
- **Massive Widgets**: Build methods with >100 lines of code
- **Mixed Responsibilities**: Widgets containing service calls, navigation logic, and UI rendering
- **Nested Ternary Operators**: Use proper conditional widgets instead
- **Stateful Widget Abuse**: Use StatefulWidget only when state is needed
- **Missing Keys**: Always provide keys for list items and conditional widgets
- **Ignoring Lifecycle**: Not disposing resources in dispose() methods
- **Widget Inheritance Abuse**: Extending built-in widgets instead of composition
- **Fat Interfaces**: Large abstract classes forcing unused method implementations
- **Broken Substitution**: Subclasses that can't replace parent without breaking code
- **If-Else Feature Addition**: Adding new features via conditional statements instead of abstractions

**MVVM Architecture Specific**

- **Fat ViewModels**: ViewModels with >200 lines or multiple concerns
- **UI Logic in Models**: Business models should not contain UI-specific code
- **Direct Model Access**: Views should interact only with ViewModels
- **Missing Notifications**: Forgetting to call notifyListeners() after state changes
- **Synchronous Heavy Operations**: Use async/await for long-running tasks

### Widget Composition Best Practices

**Prefer Composition Over Large Widgets**

- Break widgets into smaller, focused components when they exceed ~50-100 lines
- Create reusable widgets in `presentation/shared/widgets/` for cross-feature use
- Create feature-specific widgets in `features/<feature>/widgets/` for local use
- Each widget should have a single, clear responsibility

**Widget Decomposition Guidelines**

- **Single Purpose Widgets**: Each widget should have one clear responsibility (UI only)
- **Layer Separation**: Keep UI, data fetching, navigation, and business logic in separate classes
- **Service Injection**: Pass services to widgets rather than making network calls inside build methods
- **Extract Repeated Patterns**: Create reusable widgets for common UI patterns
- **Composition Over Size**: Use composition to build complex UIs from simple, focused parts
- **Avoid God Widgets**: Break widgets that handle multiple concerns (UI + API + navigation)
- **Interface Segregation**: Split large abstract classes into focused, role-based contracts
- **Extension via Abstraction**: Use interfaces/abstractions to add features without modifying existing code

### Flutter Performance Best Practices

**Widget Efficiency**

- Use `const` constructors wherever possible
- Implement proper `shouldRebuild` logic for expensive widgets
- Avoid creating widgets in build methods
- Use `Builder` widgets to limit rebuild scope

**State Management Performance**

- Minimize the scope of `setState()` calls
- Use `AnimatedBuilder` for targeted updates
- Prefer local state over global state when possible
- Dispose of streams, controllers, and listeners properly

---

## 📋 Development Workflow Checklist

### Before Committing Changes

**Code Quality**

- [ ] No constructors with >8 parameters (SRP violation indicator - use configuration objects)
- [ ] No build methods with >100 lines (God Widget indicator)
- [ ] No classes with >300 lines (God Class indicator)
- [ ] Widgets only handle UI rendering (no networking, navigation, or business logic)
- [ ] Services are injected into widgets rather than created inside build methods
- [ ] Complex conditional logic is extracted into separate components or abstractions
- [ ] New features added via interfaces/abstractions, not if-else modifications
- [ ] Complex widgets are broken into smaller, focused components
- [ ] Reusable widgets are properly organized in `presentation/shared/widgets/` or `features/<feature>/widgets/`

**Resource Management**

- [ ] All resources are properly disposed in dispose() methods
- [ ] Streams are canceled, controllers are disposed
- [ ] ViewModels call notifyListeners() after state changes
- [ ] No memory leaks from uncanceled listeners

**Testing Requirements**

- [ ] Tests pass: `flutter test`
- [ ] Coverage ≥80% for new/modified code: `flutter test --coverage`
- [ ] Tests cover new functionality with unit, widget, and integration tests
- [ ] Mock external dependencies appropriately

**Build and Quality Requirements**

- [ ] Code formatted: `dart format .` (or auto-formatted by lefthook)
- [ ] No analyzer issues: `flutter analyze`
- [ ] All auto-fixable issues resolved: `dart fix --apply`
- [ ] Build succeeds on target platforms (macOS, iOS, web - no Android tooling)

### Development Workflow Steps

1. **Feature Development**: Create feature directory with page/viewmodel pair following MVVM
2. **Widget Composition**: Break large widgets into smaller, focused components
3. **Domain Logic**: Implement business logic in domain services, not in ViewModels/pages
4. **Testing**: Write comprehensive unit, widget, and integration tests (≥80% coverage)
5. **Code Quality**: Automatic formatting, linting via git hooks (lefthook)
6. **Architecture Review**: Check for SRP violations and code smells before committing
7. **MIDI Integration**: Use centralized MIDI services and state management
8. **Musical Theory**: Leverage existing domain services for consistency

---

## 🛠️ Build Targets and Platform Support

### Primary Development Platforms

- **macOS**: Primary development platform (no Android tooling installed)
- **iOS**: Full support with Xcode integration
- **Web**: Browser-based deployment support
- **Linux/Windows**: Desktop platform support

### Build Commands

```bash
# macOS
flutter build macos --debug
flutter build macos --release

# iOS
flutter build ios --debug
flutter build ios --release

# Web
flutter build web

# Run on specific platform
flutter run -d macos
flutter run -d chrome
```

### Platform Requirements

- Flutter >= 3.22.0
- Dart >= 3.8.1
- Note: Cannot compile APK (no Android tooling installed)
- Piano layout changes should maintain 49-key constraint for consistency
- Exercise sequences should be validated to fit within 4-octave ranges
