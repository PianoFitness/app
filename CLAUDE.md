
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Directory and File Overview

### Features Directory (`lib/features/`)

- **device_controller/**
  - `device_controller_page.dart`: UI for MIDI device management and connection
  - `device_controller_view_model.dart`: Handles device selection, connection logic, and state
- **midi_settings/**
  - `midi_settings_page.dart`: UI for MIDI channel and device settings
  - `midi_settings_view_model.dart`: Manages MIDI settings state and user actions
- **play/**
  - `play_page.dart`: Free play piano interface and visualization
  - `play_page_view_model.dart`: Handles note events and play mode state
- **practice/**
  - `practice_hub_page.dart`: Entry point for practice modes and session selection
  - `practice_page.dart`: Main practice session UI
  - `practice_page_view_model.dart`: Manages practice session state and progress
- **reference/**
  - `reference_page.dart`: Scale and chord reference UI
  - `reference_page_view_model.dart`: Handles reference selection and highlighted notes

### Shared Directory (`lib/shared/`)

- **models/**
  - `chord_progression_type.dart`: Defines chord progression types for practice/reference
  - `midi_state.dart`: MIDI note/channel state model (used by ViewModels)
  - `practice_mode.dart`: Practice mode definitions and enums
  - `practice_session.dart`: Practice session data and progress tracking
- **services/**
  - `midi_connection_service.dart`: Handles MIDI device connection and communication
  - `midi_service.dart`: MIDI message handling and abstraction
- **utils/**
  - `arpeggios.dart`: Arpeggio generation and note utilities
  - `chord_inversion_utils.dart`: Chord inversion logic and helpers
  - `chords.dart`: Chord construction and MIDI note mapping
  - `note_utils.dart`: Note conversion, mapping, and display helpers
  - `piano_range_utils.dart`: Piano key range calculations and helpers
  - `scales.dart`: Scale generation, intervals, and key logic
  - `virtual_piano_utils.dart`: Utilities for virtual piano interaction and note playback
- **widgets/**
  - `main_navigation.dart`: Main navigation bar and routing
  - `midi_controls.dart`: MIDI control widgets (channel, device, etc.)
  - `midi_status_indicator.dart`: Displays MIDI connection status
  - `practice_progress_display.dart`: Shows practice progress and feedback
  - `practice_settings_panel.dart`: Practice session settings UI

### General Guideline

Pages and ViewModels should contain minimal business logic. Business logic and core algorithms should generally be implemented in shared utilities and models under `lib/shared/`. This ensures maintainability, testability, and code reuse across features.

## Development Commands

### Building and Running

```bash
# Build for macOS (primary development target)
flutter build macos --debug
flutter build macos --release

# Build for iOS 
flutter build ios --debug
flutter build ios --release

# Build for web
flutter build web

# Run the app (development)
flutter run

# Run on specific platform
flutter run -d macos
flutter run -d chrome
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/reference/reference_page_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests with specific name pattern
flutter test --name "should display all keys"
```

### Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Fix auto-fixable issues
dart fix --apply

# Check for text-based selectors in test files
./scripts/check-test-selectors.sh

# Check specific test files for text-based selectors
./scripts/check-test-selectors.sh test/features/reference/reference_page_test.dart

# Run commit validation (used by git hooks)
dart scripts/validate_commit_msg.dart "your commit message"
```

### Git Hooks (Lefthook)

```bash
# Install git hooks (run once after cloning)
lefthook install

# Git hooks automatically run:
# - Pre-commit: dart fix, format, analyze
# - Pre-push: flutter test
# - Commit-msg: validate conventional commits
```

## Architecture Overview

### Application Structure

Piano Fitness is a Flutter app for piano practice with MIDI integration, following a feature-based MVVM architecture:

- **lib/main.dart**: App entry point; initializes app and navigation
- **lib/features/**: Feature modules with page/view_model pairs
- **lib/shared/**: Reusable components, models, services, and utilities

### Key Architectural Patterns

#### MVVM with Provider

Each feature follows MVVM pattern:

- **View**: Stateful widget handling UI and user interactions
- **ViewModel**: ChangeNotifier managing business logic and state
- **Model**: Data classes and state management (MidiState, etc.)

Example structure:

```text
features/reference/
├── reference_page.dart          # View layer
└── reference_page_view_model.dart   # ViewModel layer
```

#### Navigation Structure

Bottom navigation with three main sections:

1. **Free Play** (`features/play/`): Open piano interaction
2. **Practice** (`features/practice/`): Structured practice sessions
3. **Reference** (`features/reference/`): Scale and chord reference

#### MIDI Integration

MIDI handling is managed locally within each page via page-scoped ViewModels/controllers:

- **MidiState**: Local state for active notes, channel selection (instantiated per page/ViewModel)
- **MidiConnectionService**: Device connection and data handling
- **VirtualPianoUtils**: Note playback and interaction

### Core Data Flow

1. **MIDI Input**: Hardware → MidiConnectionService → MidiState → UI updates
2. **Virtual Notes**: UI interaction → ViewModel → VirtualPianoUtils → MidiState
3. **Reference Mode**: Selection changes → ViewModel → MidiState.setHighlightedNotes() → Piano visualization

### Musical Theory Implementation

#### Scales (`domain/services/music_theory/scales.dart`)

- Comprehensive scale system with intervals and note generation
- Support for major, minor, and modal scales
- Key enum with enharmonic display names (flat notation primary)

#### Chords (`domain/services/music_theory/chord_builder.dart`)

- Triad system with major, minor, diminished, augmented types
- Inversion support (root, first, second)
- MIDI note generation with octave management

#### Note Utilities (`domain/services/music_theory/note_utils.dart`)

- Conversion between MusicalNote enum, MIDI numbers, and piano positions
- Integration with piano package for InteractivePiano widget

### State Management Strategy

#### Local MIDI State (Per-Page ViewModel)

- Each page or feature module manages its own `MidiState` via a dedicated ViewModel/controller
- MIDI device connection, note events, and channel selection are isolated to the page context
- UI updates and note highlighting are driven by the local MidiState instance

#### Other Local State (ChangeNotifier ViewModels)

- Feature-specific state management
- Business logic separation from UI
- Notification-based UI updates

### Piano Visualization

- Uses `piano` package for InteractivePiano widget
- 49-key standard range for consistent layout
- Dynamic key width calculation based on screen size
- Note highlighting through MidiState integration

## Testing Strategy

### Test Structure

- **Unit Tests**: ViewModels and utility classes
- **Widget Tests**: Page UI components and interactions  
- **Integration Tests**: Cross-feature functionality and navigation
- **Shared Mocks**: Centralized MIDI plugin mocking (`test/shared/midi_mocks.dart`)

### Key Testing Patterns

- Set up MIDI mocks for tests
- Use ChangeNotifierProvider for widget tests

## Code Quality and Architecture Principles

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
- **Implement abstractions for extensibility**: Instead of adding new payment types to a switch statement, implement PaymentMethod interface

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

**Dependency Inversion**

- Depend on abstractions (interfaces) not concrete implementations
- Use dependency injection for services and external dependencies
- Keep business logic separate from UI components

### Common Code Smells to Avoid

**General Software Development**

- **God Classes**: Classes with >300 lines or too many responsibilities
- **Long Parameter Lists**: Methods/constructors with >5 parameters
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
- Create reusable widgets in `/presentation/shared/widgets/` for cross-feature use
- Create feature-specific widgets in `/features/<feature>/widgets/` for local use
- Each widget should have a single, clear responsibility

**Widget Organization Structure**

```text
features/practice/
├── practice_page.dart              # Main page widget
├── practice_page_view_model.dart   # ViewModel
└── widgets/                        # Feature-specific widgets
    ├── scale_settings_panel.dart
    ├── arpeggio_settings_panel.dart
    └── practice_status_indicator.dart

presentation/shared/widgets/        # Reusable across features
├── base_settings_panel.dart
├── musical_key_selector.dart
└── note_selector_dropdown.dart
```

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

**State Management**

- Minimize the scope of `setState()` calls
- Use `AnimatedBuilder` for targeted updates
- Prefer local state over global state when possible
- Dispose of streams, controllers, and listeners properly

## Code Style and Conventions

### Naming and Organization

- Feature-based directory structure
- Snake_case for files, PascalCase for classes  
- Double quotes for strings (analysis_options.yaml enforced)
- Comprehensive documentation with /// comments

### Import Organization

```dart
// Standard library imports
import "dart:async";

// Flutter framework imports  
import "package:flutter/material.dart";

// External package imports
import "package:provider/provider.dart";

// Internal imports (relative paths)
import "package:piano_fitness/domain/models/practice/exercise.dart";
```

### State Management Conventions

- ViewModels extend ChangeNotifier
- Dispose pattern for resource cleanup
- Null-safe state handling
- Listener notification only on actual changes

### Musical Context

- Use enharmonic flat notation as primary (D♭ not C#)
- MIDI note numbering: C4 = 60 (middle C)
- Octave range 3-5 for reference mode visualization
- Chord inversions maintain same pitch classes across octaves

## Development Notes

### MIDI Integration Specifics

- Uses flutter_midi_command plugin for cross-platform MIDI
- Custom MidiConnectionService handles device management
- Real-time note detection with velocity and timing
- Virtual note playback through platform-specific MIDI output

### Performance Considerations

- Piano widget rendering optimized with dynamic key sizing
- MIDI data processing minimizes UI thread blocking
- Test mocks prevent actual MIDI device requirements
- Efficient state updates through targeted listener notifications

### Build Targets

- Primary development: macOS (no Android tooling installed)
- Supported platforms: macOS, iOS, web
- Flutter >= 3.22.0, Dart >= 3.8.1

## Development Workflow

1. **Feature Development**: Create feature directory with page/viewmodel pair
2. **Widget Composition**: Break large widgets into smaller, focused components
3. **Testing**: Write comprehensive unit, widget, and integration tests
4. **Code Quality**: Automatic formatting, linting via git hooks
5. **Architecture Review**: Check for SRP violations and code smells before committing
6. **MIDI Integration**: Use MidiState for note visualization and interaction
7. **Musical Theory**: Leverage existing scale/chord utilities for consistency

### Code Review Checklist

**Before Committing Changes**

- [ ] No constructors with >8 parameters (SRP violation indicator)
- [ ] No build methods with >100 lines (God Widget indicator)  
- [ ] No classes with >300 lines (God Class indicator)
- [ ] Widgets only handle UI rendering (no networking, navigation, or business logic)
- [ ] Services are injected into widgets rather than created inside build methods
- [ ] Complex conditional logic is extracted into separate components or abstractions
- [ ] New features added via interfaces/abstractions, not if-else modifications
- [ ] Complex widgets are broken into smaller, focused components
- [ ] Reusable widgets are properly organized in `/presentation/shared/widgets/` or `/features/<feature>/widgets/`
- [ ] All resources are properly disposed in dispose() methods
- [ ] ViewModels call notifyListeners() after state changes
- [ ] Tests pass and cover new functionality

**Build and Quality Requirements**

- Always build the app with macOS, iOS, or web targets. We don't have the Android tooling installed, so can't compile APK.
- Always run the analysis and lint checks on code changes and fix any errors, otherwise we can't commit the changes.
- Use `flutter analyze` to catch potential issues before committing
- Consider refactoring if any code smells are detected
