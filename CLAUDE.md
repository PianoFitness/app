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
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

#### Scales (`shared/utils/scales.dart`)
- Comprehensive scale system with intervals and note generation
- Support for major, minor, and modal scales
- Key enum with enharmonic display names (flat notation primary)

#### Chords (`shared/utils/chords.dart`)
- Triad system with major, minor, diminished, augmented types
- Inversion support (root, first, second)
- MIDI note generation with octave management

#### Note Utilities (`shared/utils/note_utils.dart`)
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
import "package:piano_fitness/shared/models/midi_state.dart";
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
- Flutter 3.8.1+ with null safety

## Development Workflow

1. **Feature Development**: Create feature directory with page/viewmodel pair
2. **Testing**: Write comprehensive unit, widget, and integration tests
3. **Code Quality**: Automatic formatting, linting via git hooks
4. **MIDI Integration**: Use MidiState for note visualization and interaction
5. **Musical Theory**: Leverage existing scale/chord utilities for consistency
- Always build the app with macOS, iOS, or web targets. We don't have the Android tooling installed, so can't compile APK.
- Always run the analysis and lint checks on code changes and fix any errors, otherwise we can't commit the changes.