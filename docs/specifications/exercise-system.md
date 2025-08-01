# Exercise System Specification

## Overview

The Exercise System is the core component of Piano Fitness that provides structured technical exercises for piano students. It offers comprehensive practice materials focused on building coordination, muscle memory, and technical proficiency through scales, chords, arpeggios, and progressions.

## Exercise Categories

### 1. Scales
- **Major Scales**: All 12 major scales in standard fingering patterns
- **Natural Minor Scales**: All 12 natural minor scales
- **Harmonic Minor Scales**: All 12 harmonic minor scales with raised 7th degree
- **Melodic Minor Scales**: All 12 melodic minor scales (different ascending/descending)
- **Modal Scales**: Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian
- **Range**: Up to three octaves per scale
- **Fingering**: Standard fingering patterns with visual indicators

### 2. Chords
#### Diatonic Triads
- **Root Position**: I, ii, iii, IV, V, vi, vii° in all major keys
- **First Inversion**: All triads in first inversion
- **Second Inversion**: All triads in second inversion
- **Practice Methods**:
  - Block chords (simultaneous notes)
  - Broken chords (arpeggiated)
  - Alberti bass patterns

#### Chord Types
- Major triads
- Minor triads  
- Diminished triads
- Augmented triads
- Extended chords (7ths, 9ths, etc.)

### 3. Arpeggios
- **Diatonic Arpeggios**: Based on scale degrees in all keys
- **Range Options**:
  - One octave
  - Two octaves
  - Three octaves
- **Direction Patterns**:
  - Ascending only
  - Descending only
  - Ascending and descending
  - Alternating patterns

### 4. Chord Progressions
#### Common Progressions
- **I-IV-V-I**: Primary progression in all keys
- **ii-V-I**: Jazz progression in all keys
- **vi-IV-I-V**: Pop progression pattern
- **I-vi-ii-V**: Circle progression
- **Custom Progression Builder**: User-defined progressions

#### Practice Variations
- Block chord style
- Arpeggiated style
- Bass line accompaniment
- Melody harmonization

## Exercise Configuration

### Key Selection
- **All Major Keys**: C, G, D, A, E, B, F#, C#, F, Bb, Eb, Ab
- **All Minor Keys**: Natural, harmonic, and melodic variants
- **Relative/Parallel**: Toggle between relative and parallel minor
- **Circle of Fifths**: Organized practice sequence
- **Random Selection**: Automated key rotation

### Tempo Settings
- **Range**: 40-208 BPM
- **Increment**: 1 BPM steps for fine control
- **Preset Tempos**: Common practice tempos (60, 72, 84, 96, 108, 120, 132, 144, 160, 176, 192)
- **Tap Tempo**: Manual tempo setting via tap input
- **Gradual Acceleration**: Automatic tempo increase during practice

### Practice Modes
- **Hands Separate**: Left hand only, right hand only
- **Hands Together**: Simultaneous execution
- **Custom Hand Patterns**:
  - Alternating hands
  - Canon (offset timing)
  - Contrary motion
  - Parallel motion

### Difficulty Levels
- **Beginner**: 
  - Single octave
  - Slower tempos (40-80 BPM)
  - Basic fingering patterns
  - Simple progressions
- **Intermediate**:
  - Two octaves
  - Moderate tempos (60-120 BPM)
  - Standard fingering
  - Common progressions
- **Advanced**:
  - Three octaves
  - Faster tempos (100-208 BPM)
  - Complex fingering patterns
  - Advanced progressions

## Exercise Data Structure

### Exercise Class
```dart
class Exercise {
  final String id;
  final String name;
  final ExerciseType type;
  final String description;
  final List<Key> supportedKeys;
  final DifficultyLevel difficulty;
  final List<FingeringPattern> fingerings;
  final int minTempo;
  final int maxTempo;
  final List<PracticeMode> supportedModes;
}
```

### Exercise Types
```dart
enum ExerciseType {
  scale,
  chord,
  arpeggio,
  progression,
  custom
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced
}

enum PracticeMode {
  leftHand,
  rightHand,
  handsTogether,
  alternatingHands,
  canon,
  contraryMotion,
  parallelMotion
}
```

### Fingering Pattern
```dart
class FingeringPattern {
  final Hand hand;
  final List<int> fingers; // 1-5 for each note
  final List<int> midiNotes;
  final String pattern; // Ascending, descending, etc.
}

enum Hand {
  left,
  right
}
```

## Exercise Generation

### Scale Generation
- **Pattern Recognition**: Whole and half step patterns
- **Key Signature**: Automatic sharp/flat application
- **Octave Expansion**: Generate multi-octave patterns
- **Modal Variations**: Generate modes from parent scales

### Chord Generation
- **Interval Calculation**: Third-based chord construction
- **Inversion Logic**: Root, 1st, 2nd inversion patterns
- **Voice Leading**: Smooth transitions between chords
- **Harmonic Context**: Diatonic relationships

### Progression Generation
- **Roman Numeral Analysis**: Chord function identification
- **Voice Leading**: Smooth chord transitions
- **Cadence Patterns**: Authentic, plagal, deceptive cadences
- **Modulation**: Key changes within progressions

## Exercise Validation

### Note Accuracy
- **Pitch Matching**: Compare played notes to expected notes
- **Timing Tolerance**: Acceptable deviation from beat
- **Chord Recognition**: Simultaneous note validation
- **Sequence Verification**: Correct note order

### Technique Assessment
- **Fingering Compliance**: Match recommended fingering
- **Legato Consistency**: Smooth connection between notes
- **Rhythm Accuracy**: Adherence to tempo and timing
- **Dynamic Control**: Volume consistency (where applicable)

## Exercise Progression

### Adaptive Difficulty
- **Performance Tracking**: Success rate monitoring
- **Automatic Advancement**: Move to next level based on accuracy
- **Remedial Practice**: Return to easier variations if needed
- **Personalized Pacing**: Individual progression speed

### Mastery Criteria
- **Accuracy Threshold**: 90% note accuracy
- **Tempo Achievement**: Target tempo reached
- **Consistency**: Multiple successful attempts
- **Technique Quality**: Proper fingering and legato

## Exercise Customization

### User-Defined Exercises
- **Custom Scales**: User-created scale patterns
- **Custom Progressions**: Personal chord sequences
- **Practice Variations**: Modified practice patterns
- **Goal Setting**: Personal targets and objectives

### Exercise Libraries
- **Classical Repertoire**: Exercises from method books
- **Jazz Standards**: Jazz-specific progressions and scales
- **Popular Music**: Contemporary chord patterns
- **Examination Syllabi**: Graded exam requirements

## Integration Points

### MIDI Integration
- **Real-time Input**: Live MIDI note detection
- **Exercise Playback**: Demonstration of exercises
- **Metronome Sync**: Coordinated timing with metronome
- **Multi-device**: Support for various MIDI controllers

### Progress Tracking
- **Session Data**: Exercise completion and accuracy
- **Historical Trends**: Progress over time
- **Achievement System**: Milestone recognition
- **Analytics**: Performance metrics and insights

### Visual Feedback
- **Piano Keyboard**: Real-time key highlighting
- **Sheet Music**: Optional notation display
- **Fingering Guides**: Visual finger number indicators
- **Progress Indicators**: Completion status and accuracy

## Performance Requirements

### Responsiveness
- **Real-time Processing**: &lt; 20ms MIDI input latency
- **Exercise Loading**: &lt; 500ms exercise initialization
- **Smooth Playback**: 60fps visual updates
- **Battery Efficiency**: Optimized for mobile devices

### Scalability
- **Exercise Library**: Support for 1000+ exercises
- **Concurrent Processing**: Multiple exercise types
- **Memory Management**: Efficient exercise caching
- **Database Operations**: Fast exercise retrieval

## Future Enhancements

### Phase 2 Features
- **AI-Generated Exercises**: Machine learning-based exercise creation
- **Sight-reading Integration**: Reading exercises with exercise practice
- **Collaborative Practice**: Multi-user exercise sessions
- **Advanced Analytics**: Machine learning performance analysis

### Phase 3 Features
- **Video Integration**: Video lessons with exercises
- **Gamification**: Points, badges, and competition
- **Social Features**: Sharing and community challenges
- **Cross-platform Sync**: Multi-device progress synchronization