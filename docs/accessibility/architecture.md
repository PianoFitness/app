# Accessibility Architecture Documentation

## Overview

This document describes the modular accessibility architecture implemented in Piano Fitness to support scalable, maintainable accessibility features.

## Architecture Goals

- **Modularity**: Separate accessibility concerns into focused, reusable components
- **Consistency**: Centralized configuration ensures consistent terminology across the app
- **Maintainability**: Clear separation of concerns makes code easier to update and extend
- **Testability**: Isolated components can be unit tested independently
- **Scalability**: New accessibility features can be added without affecting existing code

## Directory Structure

```text
lib/shared/accessibility/
├── accessibility.dart           # Main export file for easy imports
├── config/
│   └── accessibility_labels.dart    # Centralized labels and messages
├── services/
│   ├── piano_semantics_service.dart      # Piano-specific accessibility logic
│   ├── musical_announcements_service.dart # Live announcements for screen readers
│   └── midi_accessibility_service.dart   # MIDI device accessibility features
├── widgets/
│   └── accessible_widgets.dart          # Reusable accessible UI components
└── mixins/
    └── accessibility_mixins.dart        # Common accessibility patterns
```

## Components

### Configuration (config/)

**accessibility_labels.dart**

- Centralized source of truth for all accessibility strings
- Organized by feature area (piano, MIDI, timer, UI)
- Supports future localization efforts
- Reduces duplication and ensures consistency

```dart
// Usage example
AccessibilityLabels.piano.keyboardLabel(PianoMode.practice)
AccessibilityLabels.midiDeviceConnected("Digital Piano")
```

### Services (services/)

**piano_semantics_service.dart**

- Handles piano-specific accessibility features
- Creates semantic wrappers for piano widgets
- Manages note highlighting announcements
- Provides context-aware semantic descriptions

**musical_announcements_service.dart**

- Manages live region announcements
- Provides real-time feedback to screen readers
- Handles note playing, chord announcements, and status updates
- Supports both context-aware and simple announcement methods

**midi_accessibility_service.dart**

- Specialized accessibility for MIDI device interactions
- Handles device connection status announcements
- Provides semantic markup for MIDI controls
- Manages MIDI-specific error reporting

### Widgets (widgets/)

**accessible_widgets.dart**

- Pre-built accessible UI components
- `AccessiblePiano`: Semantic wrapper for piano keyboards
- `AccessibleHeader`: Properly marked headers for navigation
- `LiveRegionText`: Dynamic content that announces changes
- `AccessibleIconButton`: Enhanced icon buttons with full semantic information
- `AccessibleContainer`: Semantic containers for grouping content

### Mixins (mixins/)

**accessibility_mixins.dart**

- Reusable accessibility patterns as mixins
- `AccessibilityAnnouncementMixin`: Easy announcements in StatefulWidgets
- `SemanticWrapperMixin`: Common semantic wrapper methods
- `MidiAccessibilityMixin`: MIDI-specific accessibility patterns
- `TimerAccessibilityMixin`: Timer control accessibility patterns

## Usage Patterns

### Basic Import

```dart
import "package:piano_fitness/shared/accessibility/accessibility.dart";
```

### Using Accessible Widgets

```dart
// Replace regular piano widget
InteractivePiano(...)

// With accessible version
AccessiblePiano(
  child: InteractivePiano(...),
  mode: PianoMode.practice,
  highlightedNotes: currentHighlightedNotes,
)
```

### Using Mixins in StatefulWidgets

```dart
class _PracticePageState extends State<PracticePage> 
    with AccessibilityAnnouncementMixin, TimerAccessibilityMixin {
  
  void _onNotePressed(String note) {
    // Easy announcements
    announceNote(note);
  }
  
  Widget _buildTimerDisplay() {
    // Semantic timer wrapper
    return createTimerDisplaySemantic(
      child: Text("$_minutes:$_seconds"),
      duration: Duration(minutes: _minutes, seconds: _seconds),
      isRunning: _isTimerRunning,
    );
  }
}
```

### Using Services Directly

```dart
// Announce mode changes
MusicalAnnouncementsService.announceModeChange(
  context, 
  PianoMode.practice
);

// Create piano semantic wrapper
final accessiblePiano = PianoSemanticsService.createAccessibleWrapper(
  child: myPianoWidget,
  mode: currentMode,
  highlightedNotes: notes,
);
```

## Migration Guide

### Phase 1: Foundation (Current PR)

- ✅ Created modular directory structure
- ✅ Implemented core services and configuration
- ✅ Added accessible widget components
- ✅ Created reusable mixins

### Phase 2: Page Integration (Future PR)

- Migrate existing pages to use new accessible widgets
- Replace hard-coded labels with centralized configuration
- Update StatefulWidgets to use accessibility mixins
- Add comprehensive semantic markup

### Phase 3: Advanced Features (Future PRs)

- Add gesture-based accessibility controls
- Implement voice guidance for practice sessions
- Add customizable accessibility preferences
- Create accessibility testing utilities

## Testing Strategy

### Unit Tests

- Test each service class independently
- Verify label configuration methods
- Test mixin functionality in isolation

### Widget Tests

- Test accessible widgets with semantic finders
- Verify proper semantic markup is applied
- Test screen reader announcement behavior

### Integration Tests

- Test complete accessibility workflows
- Verify semantic navigation patterns
- Test with actual assistive technologies

## Best Practices

1. **Always use centralized labels**: Access strings through `AccessibilityLabels` class
2. **Prefer mixins for common patterns**: Use accessibility mixins instead of repeating code
3. **Use semantic widgets**: Choose appropriate accessible widgets for UI components
4. **Test with screen readers**: Verify functionality with actual assistive technologies
5. **Document semantic structure**: Clearly document the intended semantic hierarchy

## Contributing

When adding new accessibility features:

1. **Add labels to configuration**: Update `accessibility_labels.dart` for new strings
2. **Create focused services**: Add specialized services for new feature areas
3. **Build reusable widgets**: Create accessible widgets for common UI patterns
4. **Extract common patterns**: Add mixins for repeated accessibility logic
5. **Update exports**: Add new components to `accessibility.dart` export file

## Future Enhancements

- **Localization support**: Extend label configuration for multiple languages
- **Dynamic contrast**: Service for managing accessibility color schemes
- **Voice controls**: Integration with speech recognition for hands-free interaction
- **Haptic feedback**: Tactile feedback service for users with visual impairments
- **Custom gestures**: Service for accessibility-specific gesture recognition
