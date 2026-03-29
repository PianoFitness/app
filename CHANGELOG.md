# Changelog

All notable changes to Piano Fitness will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Practice History Page**: New "History" tab in the bottom navigation bar displays completed exercises in reverse-chronological order. Each entry shows the practice mode, exercise parameters (key, scale type, chord type, etc.), hand selection, and completion timestamp. Includes loading, empty-state, and error-state handling.
- **Last-Practiced Time on Profile Chooser**: Profile cards now display a relative "last practiced" time (e.g. "3 days ago") so you can see at a glance which profiles are active.
- **Exercise History Recording**: Practice completions are now persisted to a local database. Each finished exercise is saved with the exercise configuration, profile ID, and timestamp, enabling the history page and future analytics.

### Changed

### Fixed

- **Practice Config Snapshot**: Fixed a race condition in `PracticePageViewModel` where the exercise configuration could mutate across an async boundary before being saved, causing incorrect history entries to be recorded.
- **Exercise History Index on Fresh Install**: The database `onCreate` handler now creates the composite index required by the exercise history table, fixing a missing-index bug that only affected new installs (not upgrades).
- **Last-Practiced Date Stamping**: `UserProfile.lastPracticeDate` is now correctly updated when an exercise is completed.

- **Dominant Cadence Seventh Chord Voice Leading**: Fixed voice leading for V7→Imaj7 progressions where chords were jumping octaves instead of resolving smoothly. Created new `VoiceLeadingUtils` domain service with weighted octave search algorithm that prioritizes common tone preservation (1000x penalty weight) while minimizing total voice movement. The algorithm searches multiple octave candidates (searchRange=2) to find optimal voice leading despite auto-bump logic in chord generation. Comprehensive property-based tests validate voice leading invariants across all 12 keys × 4 inversion pairs.
- **Voice Leading Algorithm Bug**: Fixed `calculateOptimalOctaveForResolution` to prioritize number of preserved common tones over total movement distance. Previous implementation minimized total penalty score, allowing tied preserved common tone counts to be decided solely by non-common tone proximity, violating voice leading principles. Type-safe `MidiNote` refactoring helped reveal this algorithmic flaw. Added `maxCommonToneJump` parameter to validation logic to accept reasonable common tone movement when perfect preservation is geometrically impossible due to ascending-order voicing constraints.

### Improved

- **Documentation Steward Agent**: Added a VS Code Copilot agent that interviews developers and produces feature specifications and ADRs following project conventions, reducing documentation friction.
- **PR Preparation Agent**: Added a VS Code Copilot agent that runs all quality gates and generates a ready-to-paste PR description, streamlining the pre-merge review process.
- **Type Safety for MIDI Notes**: Replaced `List<int>` with type-safe `MidiNote` value object throughout voice leading and chord generation code. Provides compile-time safety, explicit pitch class and octave semantics, and distance calculation utilities. The stronger typing revealed genuine bugs in voice leading algorithm that were previously hidden. Comprehensive test coverage maintained at 100% (1090/1090 tests passing).

## [0.5.0] - 2025-12-12

### Added

- **Dominant Cadence (V→I) Practice**: New cadence exercise mode in the Practice Hub teaching smooth harmonic resolution. Generates approach chord (V) and target chord (I) pairs across all inversions with musically correct voice leading — the common tone (scale degree 5) is held stationary at the same MIDI pitch, the leading tone resolves up by a half-step to tonic, and the supertonic resolves up by a whole-step to the mediant. Available in two modes: triad mode (3 pairs, 6 steps — V 1st inv → I Root, V Root → I 2nd inv, V 2nd inv → I 1st inv) and seventh-chord mode (V7 → Imaj7, 4 symmetric inversion pairs, 8 steps). Works across all 12 major keys.
- **PianoNoteBridge**: New application-layer utility class (`lib/application/utils/piano_note_bridge.dart`) housing the three piano-widget bridge methods (`noteToNotePosition`, `convertNotePositionToMidi`, `midiNumberToNotePosition`). Enforces Clean Architecture by keeping Flutter package dependencies out of the domain layer.
- **User Profile Management**: Multi-profile support with profile creation, editing, deletion, and profile-specific practice history tracking (#44)
- **Drift Database Persistence**: Type-safe local database with schema migrations, automated testing, and ADR documentation (#41)
- **Specifications Framework**: Comprehensive specification documentation system with templates for metronome and practice sessions (#42)
- **Architecture Decision Records**: 24 ADRs documenting Clean Architecture, MVVM, Repository Pattern, dependency injection strategy, and SOLID principles (#40)
- **Auto-Progress Through Circle of Fifths**: Practice exercises can now automatically progress through all 12 keys following the circle of fifths when you complete each exercise (#38)
- **Seventh Chord Support**: Added comprehensive seventh chord support with all inversions in practice settings (#35)
- **Flutter Prunekit Integration**: Added dead code detection tooling for automated code quality analysis (#36)

### Changed

- **Clean Architecture Refactor**: Reorganized codebase into domain/application/presentation layers with clear separation of concerns (#39)
- **Dependency Injection with Provider**: Implemented constructor-based dependency injection across all ViewModels and services for improved testability (#40)
- **Dependency Updates**: Updated transitive dependency `watcher` from 1.1.4 to 1.2.0

### Improved

- **Voice Leading Correctness**: Fixed dominant cadence triad pair definitions so all three V→I pairs are the correct "rotations" of identical voice motions (common tone held, leading tone +1 st, supertonic +2 st) across all 12 major keys. Eliminates octave jumps in common tones that could occur with incorrect inversion pairings.
- **Property-Based Testing**: Replaced brittle hardcoded MIDI snapshot tests for dominant cadence with a parameterised `_checkVoiceLeading` helper that directly verifies musical invariants (stationary common tones, step-wise non-common motion) across all 12 keys × 3 pairs (36 assertions in a single test).
- **Layer Boundary Enforcement**: Removed `package:piano` Flutter package dependency from the domain layer. Bridge methods moved to `PianoNoteBridge` in the application layer; all 8 callers (features, presentation, application, test) updated accordingly.
- **Pre-commit Hook Reliability**: Switched `dart-analyze` hook from `flutter analyze` to `dart analyze`. Ensures consistent behavior in git hook shell environments where the Dart SDK binary is on PATH but the Flutter wrapper script may resolve to an unexpected version.
- **VSCode Configuration**: Enhanced markdown linting rules and Documentation Steward agent with interview-driven specification workflow (#43)
- **Code Quality and Testing**: Comprehensive test coverage improvements, mock repository patterns, and SOLID principles enforcement (#40)
- **Practice Architecture**: Refactored PracticeExercise model using Strategy pattern with modular exercise strategies (#33, #34)
- **UI Consistency**: Introduced centralized UI constants across all features for improved layout consistency (#34)
- **Code Quality**: Cleaned up dead code, modularized components, and removed unused MIDI controls

## [0.4.0] - 2025-12-12

### Added

- **Hand Selection Feature**: New hand selection functionality for practice exercises with left hand, right hand, and both hands options
  - SegmentedButton UI for intuitive hand selection in practice settings
  - Support for scales, arpeggios, chords, and chord progressions with independent hand practice
  - Intelligent octave management preventing negative MIDI notes with left hand octave offset
  - Interleaved note patterns for scales/arpeggios (sequential practice) and concatenated patterns for chords (simultaneous playing)
  - Comprehensive test coverage with 80%+ coverage for all new functionality
- **Comprehensive Accessibility Framework**: Complete accessibility infrastructure with semantic labels, screen reader support, and WCAG compliance
- **SemanticColors Extension**: New theming system for consistent semantic color usage across all components
- **Piano Key Utilities**: New utility functions for piano key identification and interaction handling
- **Accessibility Documentation**: Comprehensive documentation including implementation reports and architectural guidelines

### Improved

- **Hand Selection Code Quality**: Eliminated magic numbers with `MusicalConstants`, added octave validation assertions, and defensive bounds checking for note pairs
- **Test Infrastructure**: Streamlined test documentation and improved test patterns with key-based selectors following project guidelines
- **Development Tooling**: Refactored simulator scripts for better reliability and maintainability
- **Makefile Commands**: Added simulator override support (`make IPAD_SIM="iPad mini" run-ipad`)
- **Error Handling**: Better device detection and fallback behavior for simulator management
- **iOS Runtime Check**: Added script to verify and guide iOS simulator runtime installation
- **Accessibility Infrastructure**: Comprehensive accessibility framework with `PianoAccessibilityUtils`, `MusicalAnnouncementsService`, and context-aware semantic labeling
- **Screen Reader Support**: Full screen reader compatibility with live region announcements for piano interactions, MIDI status changes, and practice progress
- **Semantic Navigation**: Enhanced keyboard navigation with proper semantic labels, hints, and container structure across all pages
- **Universal Design**: Theme-based color implementation ensuring proper contrast ratios and consistent visual accessibility standards
- **Widget Testing**: Enhanced test coverage with key-based selectors and improved widget testing reliability
- **Code Quality**: Comprehensive refactoring with consistent theming, improved error handling, and better separation of concerns
- **User Interface**: Enhanced visual consistency across all pages with semantic color usage and improved dark mode support

## [0.3.0] - 2025-08-25

### Added

- **Notification System**: Complete notification feature with daily practice reminders and customizable scheduling
- **Repertoire Mode**: New dedicated repertoire practice page with timer functionality and audio feedback
- **Chords by Type Practice**: Enhanced chord practice with chord type selection (major, minor, diminished, augmented) and inversions
- **Dark Theme Support**: Full dark mode implementation with adaptive color schemes
- **Audio Feedback System**: High-quality bell sound for timer completion and practice milestones
- **Comprehensive Design Guidelines**: Added detailed design system documentation for consistent UI/UX
- **Advanced Testing Framework**: Enhanced test coverage with key-based navigation and robust selector checking
- **URL Launcher Integration**: Support for external links across all platforms (iOS, macOS, Windows, Linux)

### Enhanced

- **Accessibility Improvements**: Added semantic keys and labels throughout the app for better screen reader support
- **Navigation Enhancement**: Improved main navigation with MIDI and notification settings integration
- **Practice Hub Expansion**: Added chord type practice modes with comprehensive configuration options
- **Test Infrastructure**: Implemented key-based testing approach for improved reliability and maintainability
- **Permission Handling**: Enhanced notification permissions for Android 12+ and cross-platform compatibility
- **Code Quality**: Extensive refactoring with improved error handling and logging systems

### Fixed

- **Notification Scheduling**: Resolved issues with daily reminder time handling and past time scheduling
- **Chord Display Logic**: Improved chord type string retrieval and display consistency
- **Permission Dialog**: Enhanced notification permission handling with proper user feedback
- **Test Reliability**: Updated all tests to use stable key-based selection instead of text-based selectors
- **Performance Optimization**: Streamlined notification service and reduced unnecessary rebuilds

### Technical Improvements

- **Architecture Enhancement**: Better separation of concerns with improved MVVM implementation
- **Plugin Integration**: Enhanced flutter_local_notifications with proper platform configuration
- **Build System**: Updated macOS deployment target to 10.15 and iOS to 13.0
- **Dependencies**: Added audioplayers and url_launcher for expanded functionality
- **Code Documentation**: Comprehensive documentation updates and development guidelines

## [0.2.0] - 2025-08-17

### Added

- **Auto-start practice sessions**: Practice now begins automatically when any MIDI note is played, eliminating the need for manual start button
- **Comprehensive scale and chord reference system**: Interactive reference page with all major and minor scales, triads, and chord inversions
- **Chord progression practice**: Support for practicing chord progressions with proper voice leading
- **Enhanced musical key support**: Full flat key support (Db, Gb, Ab, Bb, Eb) with proper enharmonic notation
- **Improved accessibility**: Practice status indicator includes live region announcements for screen readers
- **MVVM architecture**: Centralized MIDI connection service for better data management across all pages
- **Development tooling**: Automated code quality checks with lefthook git hooks
- **Comprehensive testing**: Enhanced test coverage for all major components
- **JSON serialization**: Support for PracticeMode enum serialization for data persistence

### Changed

- **Practice flow optimization**: Removed manual start button - practice starts automatically on MIDI input
- **Reference display**: Scales and chords now display in a single octave for improved learning focus
- **MIDI state management**: Implemented per-page local MIDI state for better isolation and performance
- **Key naming consistency**: Standardized musical key display names with flat notation as primary
- **Code organization**: Improved project structure with better separation of concerns
- **Virtual piano handling**: Enhanced note-off timer management with unique keys
- **Progress indicators**: Added accessibility labels for better screen reader support

### Fixed

- **Toast message positioning**: Resolved crashes caused by floating SnackBar being positioned off-screen
- **Performance optimization**: Eliminated redundant UI rebuilds and notification calls
- **MIDI timing accuracy**: Improved virtual piano note handling with proper timer management
- **Reference display activation**: Fixed chord and scale highlighting during page initialization
- **Practice session safety**: Added null checks to prevent crashes when session is inactive
- **Chord validation**: Updated to use containsAll for improved note matching accuracy
- **Test reliability**: Removed unnecessary delays in async test setup and teardown

### Removed

- **Manual start button**: No longer needed with auto-start functionality
- **Deprecated API parameters**: Cleaned up unused callback parameters from widgets
- **Obsolete workflow files**: Removed unused CI/CD configuration files

## [0.1.0] - 2025-08-10

### Initial Release

- Basic practice functionality
- MIDI device connection and note detection
- Scale, chord, and arpeggio practice modes
- Piano keyboard visualization with note highlighting
- Practice progress tracking and completion feedback

## Release Links

[Unreleased]: https://github.com/PianoFitness/app/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/PianoFitness/app/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/PianoFitness/app/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/PianoFitness/app/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/PianoFitness/app/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/PianoFitness/app/releases/tag/v0.1.0
