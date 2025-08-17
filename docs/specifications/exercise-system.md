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

### Note-Fingering Element

The fundamental building block combining a musical note with its fingering instruction.

```dart
class NoteFingeringElement {
  final int midiNote;     // MIDI note number (0-127)
  final Hand hand;        // Which hand plays this note
  final int finger;       // Finger number (1-5, thumb to pinky)
  
  const NoteFingeringElement({
    required this.midiNote,
    required this.hand,
    required this.finger,
  });
  
  // Helper methods
  String get noteName => _midiNoteToNoteName(midiNote);
  String get fingerName => _getFingerName(finger);
  bool get isBlackKey => _isBlackKey(midiNote);
}

enum Hand { left, right }
```

### Note Group

Represents one or more notes to be played simultaneously (single notes, intervals, chords).

```dart
class NoteGroup {
  final List<NoteFingeringElement> notes;
  final String? label;              // Optional label (e.g., "C Major Triad")
  
  const NoteGroup({
    required this.notes,
    this.label,
  });
  
  // Helper methods
  bool get isChord => notes.length >= 3;
  bool get isInterval => notes.length == 2;
  bool get isSingleNote => notes.length == 1;
  bool get isBothHands => notes.any((n) => n.hand == Hand.left) && 
                          notes.any((n) => n.hand == Hand.right);
  
  // Get notes for specific hand
  List<NoteFingeringElement> getNotesForHand(Hand hand) {
    return notes.where((note) => note.hand == hand).toList();
  }
  
  // Get all MIDI note numbers
  List<int> get midiNotes => notes.map((n) => n.midiNote).toList();
}
```

### Exercise Step

Represents a single step in an exercise sequence. Steps are automatically numbered by list index.

```dart
class ExerciseStep {
  final NoteGroup noteGroup;        // What notes to play
  final String? instruction;        // Optional step-specific instruction
  
  const ExerciseStep({
    required this.noteGroup,
    this.instruction,
  });
  
  // Helper methods
  bool get hasMultipleNotes => noteGroup.notes.length > 1;
  bool get requiresBothHands => noteGroup.isBothHands;
  List<int> get expectedMidiNotes => noteGroup.midiNotes;
}
```

### Exercise Source Attribution

Tracks where exercises come from for proper attribution and licensing.

```dart
class ExerciseSource {
  final String id;
  final SourceType type;
  final String title;
  final String? author;
  final String? publisher;
  final String? url;
  final String? isbn;
  final int? pageNumber;
  final String? exerciseNumber;
  final DateTime? publicationDate;
  final String? licenseType;
  final bool requiresAttribution;
  final String? attributionText;
  final List<String> tags;
  
  const ExerciseSource({
    required this.id,
    required this.type,
    required this.title,
    this.author,
    this.publisher,
    this.url,
    this.isbn,
    this.pageNumber,
    this.exerciseNumber,
    this.publicationDate,
    this.licenseType,
    this.requiresAttribution = true,
    this.attributionText,
    this.tags = const [],
  });
  
  // Generate proper attribution text
  String generateAttribution() {
    if (attributionText != null) return attributionText!;
    
    final parts = <String>[];
    if (author != null) parts.add(author!);
    parts.add(title);
    if (publisher != null) parts.add(publisher!);
    if (publicationDate != null) parts.add(publicationDate!.year.toString());
    if (pageNumber != null) parts.add('p. $pageNumber');
    if (exerciseNumber != null) parts.add('Exercise $exerciseNumber');
    
    return parts.join(', ');
  }
}

enum SourceType {
  book,           // Published method book or collection
  article,        // Magazine or journal article
  website,        // Online resource
  video,          // YouTube, Vimeo, etc.
  teacher,        // Teacher-created exercise
  community,      // Community-contributed
  traditional,    // Traditional exercise (public domain)
  original,       // Original Piano Fitness creation
}
```

### Exercise Definition

The complete exercise structure with sequential steps.

```dart
class ExerciseDefinition {
  final String id;
  final String name;
  final String description;
  final ExerciseType type;
  final DifficultyLevel difficulty;
  final List<ExerciseStep> steps;          // Sequential note groups to play
  final ExerciseSource? source;            // Attribution information
  final int defaultTempo;                  // Default BPM for the exercise
  final List<String> supportedKeys;        // Musical keys this exercise works in
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;                  // User ID who created this exercise
  
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.steps,
    this.source,
    required this.defaultTempo,
    required this.supportedKeys,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });
  
  // Helper methods
  int get totalSteps => steps.length;
  bool get requiresBothHands => steps.any((step) => step.requiresBothHands);
  bool get hasChords => steps.any((step) => step.noteGroup.isChord);
  List<int> get allMidiNotes => steps
      .expand((step) => step.noteGroup.midiNotes)
      .toSet()
      .toList()..sort();
}

enum ExerciseType {
  scale,
  chord,
  arpeggio,
  progression,
  technique,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}
```

## Usage Examples

### Creating a Simple Scale Exercise

```dart
final cMajorScale = ExerciseDefinition(
  id: 'c_major_scale_1_octave',
  name: 'C Major Scale - 1 Octave',
  description: 'Practice the C major scale ascending with proper fingering',
  type: ExerciseType.scale,
  difficulty: DifficultyLevel.beginner,
  defaultTempo: 80,
  supportedKeys: ['C Major'],
  steps: [
    // Step 0: C (thumb)
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(
            midiNote: 60, // C4
            hand: Hand.right,
            finger: 1, // Thumb
          ),
        ],
        label: 'C',
      ),
      instruction: 'Start with your right thumb on middle C',
    ),
    // Step 1: D (index finger)
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(
            midiNote: 62, // D4
            hand: Hand.right,
            finger: 2,
          ),
        ],
        label: 'D',
      ),
    ),
    // Step 2: E (middle finger)
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(
            midiNote: 64, // E4
            hand: Hand.right,
            finger: 3,
          ),
        ],
        label: 'E',
      ),
    ),
    // Continue for full octave...
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(midiNote: 65, hand: Hand.right, finger: 1), // F
        ],
        label: 'F',
      ),
    ),
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(midiNote: 67, hand: Hand.right, finger: 2), // G
        ],
        label: 'G',
      ),
    ),
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(midiNote: 69, hand: Hand.right, finger: 3), // A
        ],
        label: 'A',
      ),
    ),
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(midiNote: 71, hand: Hand.right, finger: 4), // B
        ],
        label: 'B',
      ),
    ),
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(midiNote: 72, hand: Hand.right, finger: 5), // C5
        ],
        label: 'C',
      ),
    ),
  ],
  source: ExerciseSource(
    id: 'traditional_scales',
    type: SourceType.traditional,
    title: 'Traditional Piano Scales',
    author: 'Traditional',
    requiresAttribution: false,
  ),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  createdBy: 'system',
);
```

### Creating a Chord Exercise

```dart
final cMajorTriad = ExerciseDefinition(
  id: 'c_major_triad_block',
  name: 'C Major Triad - Block Chord',
  description: 'Practice playing C major triad as a block chord with both hands',
  type: ExerciseType.chord,
  difficulty: DifficultyLevel.beginner,
  defaultTempo: 60,
  supportedKeys: ['C Major'],
  steps: [
    // Step 0: Play all notes simultaneously
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [
          NoteFingeringElement(midiNote: 48, hand: Hand.left, finger: 5), // C3
          NoteFingeringElement(midiNote: 52, hand: Hand.left, finger: 3), // E3
          NoteFingeringElement(midiNote: 55, hand: Hand.left, finger: 1), // G3
          NoteFingeringElement(midiNote: 60, hand: Hand.right, finger: 1), // C4
          NoteFingeringElement(midiNote: 64, hand: Hand.right, finger: 3), // E4
          NoteFingeringElement(midiNote: 67, hand: Hand.right, finger: 5), // G4
        ],
        label: 'C Major Triad',
      ),
      instruction: 'Play all six notes simultaneously',
    ),
  ],
  source: ExerciseSource(
    id: 'basic_chords',
    type: SourceType.traditional,
    title: 'Basic Piano Chords',
    requiresAttribution: false,
  ),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  createdBy: 'system',
);
```

### Creating a Broken Chord (Arpeggio) Exercise

```dart
final cMajorArpeggio = ExerciseDefinition(
  id: 'c_major_arpeggio_ascending',
  name: 'C Major Arpeggio - Ascending',
  description: 'Practice C major arpeggio ascending with proper fingering',
  type: ExerciseType.arpeggio,
  difficulty: DifficultyLevel.intermediate,
  defaultTempo: 100,
  supportedKeys: ['C Major'],
  steps: [
    // Step 0: C
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [NoteFingeringElement(midiNote: 60, hand: Hand.right, finger: 1)],
        label: 'C',
      ),
    ),
    // Step 1: E
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [NoteFingeringElement(midiNote: 64, hand: Hand.right, finger: 2)],
        label: 'E',
      ),
    ),
    // Step 2: G
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [NoteFingeringElement(midiNote: 67, hand: Hand.right, finger: 3)],
        label: 'G',
      ),
    ),
    // Step 3: C (octave)
    ExerciseStep(
      noteGroup: NoteGroup(
        notes: [NoteFingeringElement(midiNote: 72, hand: Hand.right, finger: 5)],
        label: 'C',
      ),
    ),
  ],
  source: ExerciseSource(
    id: 'youtube_arpeggio_lesson',
    type: SourceType.video,
    title: 'Piano Arpeggios for Beginners',
    author: 'Piano Teacher Pro',
    url: 'https://youtube.com/watch?v=example123',
    publicationDate: DateTime(2023, 6, 15),
  ),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  createdBy: 'teacher_user_123',
);
```

## Benefits of This Simplified Model

### 1. **MVP-Focused Design**

- Essential fields only - no over-engineering for initial version
- Simple step-by-step progression using list indexes
- Clear note-to-finger mapping without complexity

### 2. **Easy Exercise Creation**

- Straightforward structure for scales, chords, arpeggios
- No need to calculate step numbers or complex timing
- Focus on the core: what notes to play and which fingers to use

### 3. **Student-Centered Learning**

- System highlights expected notes and waits for student input
- Success is simply playing the correct notes
- Visual feedback managed automatically by the system

### 4. **Flexible Timing**

- Student controls tempo via metronome
- System measures timing accuracy against metronome beats
- No complex duration calculations needed

### 5. **Source Attribution**

- Proper credit for exercise sources (books, videos, etc.)
- Clean separation of exercise content and attribution
- Supports various content types and licensing

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
