# Custom Keyboard Range Configuration

## Overview

Allow students to configure their piano keyboard range by pressing the lowest and highest keys on their physical keyboard. This will tailor the learning experience to match their specific instrument capabilities.

## User Story

As a piano student with a non-88-key keyboard (61-key, 76-key, etc.), I want to configure the app to match my keyboard range so that:

- Practice exercises stay within my physical keyboard limits
- The on-screen piano only shows keys I can actually play
- I don't get frustrated by exercises that require keys I don't have

## Technical Requirements

### 1. Keyboard Range Detection Screen

- **Location**: New settings page accessible from main settings
- **UI Elements**:
  - Instructions: "Press the lowest key on your keyboard"
  - Visual feedback showing detected note
  - "Next" button to proceed to highest key detection
  - Instructions: "Press the highest key on your keyboard"
  - Visual feedback showing detected note
  - "Save" button to confirm range
  - "Reset to 88-key default" button

### 2. Data Storage

- **Storage Method**: Shared preferences or local database
- **Data Structure**:

  ```dart
  class KeyboardRange {
    final int lowestMidiNote;
    final int highestMidiNote;
    final String lowestNoteName;   // e.g., "C3"
    final String highestNoteName;  // e.g., "F6"
    final DateTime configuredAt;
  }
  ```

### 3. Piano Range Utils Integration

- **New Method**: `PianoRangeUtils.setCustomKeyboardRange(KeyboardRange range)`
- **Updated Constants**: Replace hardcoded 88-key limits with user-configured values
- **Fallback**: Default to 88-key range if no custom range is configured

### 4. MIDI Integration

- **Real-time Detection**: Use existing MIDI listener to capture key presses during setup
- **Note Validation**: Ensure highest > lowest, reasonable range (at least 2 octaves)
- **Error Handling**: Graceful handling if MIDI device disconnected during setup

## Implementation Plan

### Phase 1: Core Infrastructure

1. Create `KeyboardRange` model class
2. Add storage service for keyboard range persistence
3. Update `PianoRangeUtils` to use configurable limits

### Phase 2: Settings UI

1. Create keyboard range configuration screen
2. Add navigation from main settings
3. Implement MIDI-based key detection workflow

### Phase 3: Integration & Testing

1. Update all piano range calculations to use custom range
2. Add validation and error handling
3. Create comprehensive tests for different keyboard sizes

## Acceptance Criteria

### Must Have

- [ ] Users can set custom keyboard range by pressing physical keys
- [ ] Range persists between app sessions
- [ ] All practice exercises respect the configured range
- [ ] On-screen piano adjusts to show only available keys
- [ ] Works with common keyboard sizes (61, 76, 88 keys)

### Should Have

- [ ] Visual preview of keyboard layout during configuration
- [ ] Ability to manually edit range (text input as backup)
- [ ] Export/import range settings for multiple devices
- [ ] Range validation prevents unreasonable configurations

### Could Have

- [ ] Preset options for common keyboard types
- [ ] Range suggestions based on detected MIDI device
- [ ] Analytics on most common keyboard ranges used

## Technical Notes

### Current 88-Key Assumptions to Update

- `PianoRangeUtils.min88KeyMidi = 21` (A0)
- `PianoRangeUtils.max88KeyMidi = 108` (C8)
- Any hardcoded octave limits in chord progression calculations

### Testing Considerations

- Mock different keyboard ranges in unit tests
- Test edge cases (very small ranges, unusual note boundaries)
- Verify chord progressions work within constrained ranges
- Performance testing with extreme ranges

## Dependencies

- Existing MIDI infrastructure (flutter_midi_command)
- Current piano range calculation system
- Settings/preferences storage system

## Risk Mitigation

- **MIDI Detection Failure**: Provide manual note selection as fallback
- **Invalid Range**: Validation with clear error messages
- **Data Loss**: Automatic backup to cloud storage (future enhancement)
- **Performance**: Optimize range calculations for very wide custom ranges
