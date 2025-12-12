# Changelog

All notable changes to Piano Fitness will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/PianoFitness/app/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/PianoFitness/app/compare/v0.3.0...v0.4.0

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

[0.3.0]: https://github.com/PianoFitness/app/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/PianoFitness/app/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/PianoFitness/app/releases/tag/v0.1.0

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
