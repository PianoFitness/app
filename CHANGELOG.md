# Changelog

All notable changes to Piano Fitness will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **Reference display**: Scales and chords now display in single octave for improved learning focus
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
