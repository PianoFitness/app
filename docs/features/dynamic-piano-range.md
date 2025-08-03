# Dynamic Piano Range Feature

## Overview

This feature automatically adjusts the interactive piano keyboard's visible range to ensure all highlighted keys for an exercise are visible without requiring horizontal scrolling. This improves the practice flow by eliminating the need for students to manually scroll the piano display during exercises.

## Implementation

### Core Utility: `PianoRangeUtils`

The `lib/utils/piano_range_utils.dart` file provides intelligent range calculation with the following key features:

#### Key Functions

1. **`calculateOptimalRange(List<NotePosition> highlightedNotes)`**
   - Calculates the optimal piano range to display all highlighted notes
   - Adds buffer space around the highlighted notes for context
   - Ensures minimum and maximum range limits for usability
   - Falls back to default treble+bass clef range when no notes are highlighted

2. **`calculateRangeForExercise(List<int> midiSequence)`**
   - Optimized for complete exercise sequences (scales, arpeggios, etc.)
   - Analyzes the entire sequence to find the optimal range
   - Ensures all notes in the exercise are visible from the start

#### Smart Range Logic

- **Buffer Zone**: Adds one octave (12 semitones) on each side of highlighted notes
- **Minimum Range**: Ensures at least 2 octaves are always visible
- **Maximum Range**: Limits display to 4 octaves to prevent overly wide keyboards
- **Boundary Handling**: Clamps to valid MIDI range (0-127)

### Integration Points

#### Practice Page (`practice_page.dart`)
- Uses `calculateRangeForExercise()` when an exercise is active
- Falls back to `calculateOptimalRange()` for individual highlighted notes
- Provides the best experience for structured exercises

#### Play Page (`play_page.dart`)
- Uses `calculateOptimalRange()` for real-time note highlighting
- Optimizes for immediate MIDI input feedback

## Benefits

### For Students
- **Seamless Practice Flow**: No need to scroll during exercises
- **Better Focus**: All relevant keys are always visible
- **Reduced Cognitive Load**: Students can focus on playing rather than navigation

### For Exercises
- **Scales**: Entire scale range visible from start to finish
- **Arpeggios**: All notes in the arpeggio pattern are visible
- **Chords**: Chord progressions fit within the visible range
- **Custom Exercises**: Automatically adapts to any note combination

## Technical Details

### Range Calculation Algorithm

1. **Input Analysis**: Examine highlighted notes or exercise sequence
2. **MIDI Conversion**: Convert note positions to MIDI numbers for calculation
3. **Range Detection**: Find minimum and maximum MIDI values
4. **Buffer Addition**: Add buffer zones around the detected range
5. **Constraint Application**: Apply minimum and maximum range limits
6. **Boundary Clamping**: Ensure valid MIDI range (0-127)
7. **Position Conversion**: Convert back to NotePosition objects
8. **Range Creation**: Create NoteRange with from/to positions

### Configuration Constants

```dart
static const int minOctaves = 2;           // Minimum visible octaves
static const int maxOctaves = 4;           // Maximum visible octaves  
static const int bufferSemitones = 12;     // Buffer size (1 octave)
```

## Testing

Comprehensive test coverage in `test/utils/piano_range_utils_test.dart`:

- Empty note lists (fallback behavior)
- Single note optimization  
- Multiple notes in same octave
- Notes spanning multiple octaves
- Exercise sequence optimization
- Accidental handling (sharps/flats)
- Extreme MIDI ranges
- Custom fallback ranges

## Future Enhancements

### Planned Improvements
- **User Preferences**: Allow users to customize buffer size and range limits
- **Context Awareness**: Different optimization strategies for different exercise types
- **Animation**: Smooth transitions when range changes
- **Memory**: Remember preferred ranges for specific exercises

### Advanced Features
- **Adaptive Learning**: Learn user preferences over time
- **Exercise-Specific Profiles**: Custom range settings per exercise type
- **Teacher Controls**: Allow teachers to set range constraints for students
- **Accessibility**: Enhanced support for users with specific range preferences

## Usage Examples

### Basic Usage
```dart
// For highlighted notes
final optimalRange = PianoRangeUtils.calculateOptimalRange(highlightedNotes);

// For exercise sequences  
final exerciseRange = PianoRangeUtils.calculateRangeForExercise(midiNotes);

// With custom fallback
final customRange = PianoRangeUtils.calculateOptimalRange(
  notes,
  fallbackRange: customFallback,
);
```

### Integration in Widgets
```dart
InteractivePiano(
  highlightedNotes: notes,
  noteRange: PianoRangeUtils.calculateOptimalRange(notes),
  // ... other properties
)
```

This feature significantly improves the user experience by ensuring students can see all relevant keys without manual scrolling during their practice sessions.
