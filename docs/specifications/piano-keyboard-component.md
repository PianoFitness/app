# PianoKeyboard Component Specification

## Overview

The PianoKeyboard component is a Flutter widget that renders an interactive piano keyboard interface. It listens for MIDI events and provides visual feedback by highlighting keys when they are pressed and held down.

## Key Features

### Visual Layout

- **49-key keyboard layout** - Standard 49-key MIDI keyboard configuration
- **Centered around middle C** - Keys arranged with middle C (C4/C60) as the central reference point
- **Black and white key differentiation** - Traditional piano key color scheme and positioning
- **Responsive design** - Adapts to different screen sizes while maintaining proper proportions

### MIDI Integration

- **Real-time MIDI event listening** - Responds to MIDI note on/off messages
- **Key press visualization** - Highlights keys while they are held down
- **Multi-touch support** - Multiple keys can be highlighted simultaneously
- **MIDI note mapping** - Maps MIDI note numbers to corresponding visual keys

## Technical Requirements

### Key Range

- **Total keys**: 49 keys
- **Key range**: C2 to C6 (MIDI notes 36-84)
- **Octaves**: 4 complete octaves plus one additional C
- **Middle C position**: Centered in the keyboard layout

### Key Layout Details

- **White keys**: 29 keys (C, D, E, F, G, A, B pattern)
- **Black keys**: 20 keys (C#, D#, F#, G#, A# pattern)
- **Key arrangement**: Standard piano layout with black keys positioned between appropriate white keys

### MIDI Event Handling

- **Note On events**: Trigger key highlighting for visual feedback only
- **Note Off events**: Remove key highlighting
- **Velocity support**: Optional support for velocity-based visual effects
- **Channel filtering**: Support for specific MIDI channel filtering
- **Input-only design**: Component receives MIDI input for display purposes only

### Visual States

- **Default state**: Normal key appearance
- **Pressed state**: Highlighted/pressed key appearance  
- **Target state**: Keys that should be pressed (exercise guidance)
- **Correct state**: Successfully played keys
- **Incorrect state**: Wrong key presses

## Component Interface

### Properties

```dart
class PianoKeyboard extends StatefulWidget {
  final Set<int> pressedKeys;
  final Set<int> targetKeys;
  final Set<int> correctKeys;
  final Set<int> incorrectKeys;
  final double? keyboardHeight;
  final Color? whiteKeyColor;
  final Color? blackKeyColor;
  final Color? pressedKeyColor;
  final Color? targetKeyColor;
  final Color? correctKeyColor;
  final Color? incorrectKeyColor;
  final bool enableMidiInput;
  final bool showFingerNumbers;
  final Map<int, FingerNumber>? fingerNumbers;
}
```

### Key Properties

- `pressedKeys`: Set of currently pressed MIDI note numbers (from MIDI input)
- `targetKeys`: Set of keys that should be pressed (exercise guidance)
- `correctKeys`: Set of correctly played keys (positive feedback)
- `incorrectKeys`: Set of incorrectly played keys (error feedback)
- `keyboardHeight`: Optional custom height for the keyboard
- `whiteKeyColor`: Custom color for white keys
- `blackKeyColor`: Custom color for black keys  
- `pressedKeyColor`: Custom color for pressed keys
- `targetKeyColor`: Custom color for target keys
- `correctKeyColor`: Custom color for correct keys
- `incorrectKeyColor`: Custom color for incorrect keys
- `enableMidiInput`: Toggle MIDI input listening
- `showFingerNumbers`: Display finger number indicators
- `fingerNumbers`: Map of MIDI notes to finger number assignments

## Implementation Guidelines

### Widget Structure

- Use `CustomPainter` or `Canvas` for efficient key rendering
- Display-only component (no touch interaction required)
- Ensure smooth animations for key press/release states
- Support multiple simultaneous key states

### Performance Considerations

- Optimize for 60fps rendering during MIDI playback
- Minimize rebuilds by using appropriate state management
- Implement efficient key lookup mechanisms

### Accessibility

- Provide semantic labels for screen readers describing key states
- Support high contrast modes for visual clarity
- Implement appropriate contrast ratios for all key states
- Ensure finger numbers are readable with sufficient contrast

### Platform Support

- iOS: Core MIDI integration
- Android: USB MIDI and Bluetooth MIDI support
- Web: Web MIDI API integration
- Desktop: Platform-specific MIDI APIs

## Dependencies

### Required Packages

- `flutter_midi_command`: MIDI input/output handling
- `flutter/material.dart`: UI components and theming

### Optional Packages

- `provider`: State management (if using Provider pattern)
- `bloc`: State management (if using BLoC pattern)

## Testing Requirements

### Unit Tests

- Key mapping logic (MIDI note number to key position)
- State management (multiple key state tracking)
- Visual state transitions
- Finger number mapping and display

### Widget Tests  

- Key rendering and positioning
- Visual state changes for all key states
- Finger number overlay rendering
- Color theme application

### Integration Tests

- MIDI device connectivity
- Real-time event processing
- Multi-key press scenarios

## Future Enhancements

### Phase 2 Features

- **Keyboard size options**: 25, 37, 61, 76, 88 key layouts
- **Custom key labeling**: Note names, scale degrees, chord symbols
- **Recording capability**: MIDI sequence recording and playback
- **Visual effects**: Velocity-based colors, trailing effects

### Phase 3 Features

- **Split keyboard**: Different sounds/channels per keyboard section
- **Transpose functionality**: Key transposition controls
- **Scale highlighting**: Visual scale and chord overlays
- **Practice modes**: Interactive learning features

## Acceptance Criteria

- [ ] Renders 49-key piano keyboard layout correctly
- [ ] Responds to MIDI note on/off events in real-time (display only)
- [ ] Supports multiple simultaneous key states (pressed, target, correct, incorrect)
- [ ] Displays finger number indicators when enabled
- [ ] Maintains 60fps performance during active MIDI input
- [ ] Works across iOS, Android, and other supported platforms
- [ ] Provides customizable colors and dimensions for all key states
- [ ] Includes comprehensive test coverage for visual states
- [ ] Follows Flutter accessibility guidelines
- [ ] Integrates cleanly with Visual Feedback System
- [ ] No touch interaction or input generation required
