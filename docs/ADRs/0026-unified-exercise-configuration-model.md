# ADR-0026: Unified Exercise Configuration Model

**Status:** Accepted

**Date:** 2026-03-02

## Context

Piano Fitness has 5 practice modes (scales, chordsByKey, chordsByType, arpeggios, chordProgressions), each with different configuration parameters. Currently, `PracticeSession` manages state with 13+ separate fields, and `PracticePageViewModel` has 14+ setter methods for individual parameters. This scattered approach creates several problems:

1. **Type safety gaps**: No single source of truth for what constitutes a valid configuration per practice mode
2. **Serialization complexity**: Converting configuration to/from JSON for exercise history requires manual field mapping
3. **Validation inconsistency**: Required vs. optional fields are not explicitly defined per mode
4. **Code duplication**: Similar configuration logic scattered across ViewModel, state management, and persistence layers
5. **Testing difficulty**: Mocking configuration requires setting up many individual fields

The exercise history feature (ADR-0025) requires serializing practice configurations to JSON for logging. Rather than continuing with ad-hoc field mapping, we need a **unified domain model** that represents exercise configuration in a type-safe, serializable, and mode-aware manner.

This model should:

- **Work across all 5 practice modes** while respecting mode-specific requirements
- **Use enums and primitives** for type safety and maintainability
- **Support JSON serialization** via `toJson()`/`fromJson()` for database persistence
- **Enforce validation rules** per practice mode (required fields, defaults, constraints)
- **Be immutable** to prevent accidental state mutations
- **Live in the domain layer** to keep business logic independent of UI and infrastructure

## Decision

We introduce **`ExerciseConfiguration`** as an immutable domain model representing a complete practice exercise configuration. This model unifies the 13+ scattered configuration parameters into a single, type-safe structure.

### Domain Model Structure

```dart
// lib/domain/models/practice/exercise_configuration.dart

import 'package:piano_fitness/domain/models/practice/practice_mode.dart';
import 'package:piano_fitness/domain/models/music/hand_selection.dart';
import 'package:piano_fitness/domain/models/music/key.dart';
import 'package:piano_fitness/domain/models/music/scale_type.dart';
import 'package:piano_fitness/domain/models/music/musical_note.dart';
import 'package:piano_fitness/domain/models/music/chord_type.dart';
import 'package:piano_fitness/domain/models/music/arpeggio_type.dart';
import 'package:piano_fitness/domain/models/music/arpeggio_octaves.dart';

/// Immutable configuration for a practice exercise.
/// 
/// This model unifies configuration across all practice modes while
/// respecting mode-specific requirements through validation.
class ExerciseConfiguration {
  // Required for all modes
  final PracticeMode practiceMode;
  final HandSelection handSelection;
  
  // Scales mode: key, scaleType, startOctave, autoProgressKeys
  final Key? key;                      // Required: scales, chordsByKey, chordProgressions
  final ScaleType? scaleType;          // Required: scales, chordsByKey
  
  // Chords mode (by type): chordType, includeInversions
  final ChordType? chordType;          // Required: chordsByType
  final bool includeInversions;        // Default: false
  
  // Chords mode (by key): includeSeventhChords
  final bool includeSeventhChords;     // Default: false
  
  // Arpeggios mode: musicalNote (root), arpeggioType, arpeggioOctaves
  final MusicalNote? musicalNote;      // Required: arpeggios (root note)
  final ArpeggioType? arpeggioType;    // Required: arpeggios
  final ArpeggioOctaves arpeggioOctaves; // Default: one
  
  // Chord Progressions mode: chordProgressionId
  final String? chordProgressionId;    // Required: chordProgressions (maps to ChordProgression.name)
  
  // Common optional fields
  final int startOctave;               // Default: 4 (middle C)
  final bool autoProgressKeys;         // Default: false
  
  const ExerciseConfiguration({
    required this.practiceMode,
    required this.handSelection,
    this.key,
    this.scaleType,
    this.chordType,
    this.includeInversions = false,
    this.includeSeventhChords = false,
    this.musicalNote,
    this.arpeggioType,
    this.arpeggioOctaves = ArpeggioOctaves.one,
    this.chordProgressionId,
    this.startOctave = 4,
    this.autoProgressKeys = false,
  });
  
  /// Creates configuration from JSON (for database deserialization).
  factory ExerciseConfiguration.fromJson(Map<String, dynamic> json) {
    return ExerciseConfiguration(
      practiceMode: PracticeMode.values.byName(json['practiceMode'] as String),
      handSelection: HandSelection.values.byName(json['handSelection'] as String),
      key: json['key'] != null ? Key.values.byName(json['key'] as String) : null,
      scaleType: json['scaleType'] != null ? ScaleType.values.byName(json['scaleType'] as String) : null,
      chordType: json['chordType'] != null ? ChordType.values.byName(json['chordType'] as String) : null,
      includeInversions: json['includeInversions'] as bool? ?? false,
      includeSeventhChords: json['includeSeventhChords'] as bool? ?? false,
      musicalNote: json['musicalNote'] != null ? MusicalNote.values.byName(json['musicalNote'] as String) : null,
      arpeggioType: json['arpeggioType'] != null ? ArpeggioType.values.byName(json['arpeggioType'] as String) : null,
      arpeggioOctaves: json['arpeggioOctaves'] != null 
          ? ArpeggioOctaves.values.byName(json['arpeggioOctaves'] as String)
          : ArpeggioOctaves.one,
      chordProgressionId: json['chordProgressionId'] as String?,
      startOctave: json['startOctave'] as int? ?? 4,
      autoProgressKeys: json['autoProgressKeys'] as bool? ?? false,
    );
  }
  
  /// Converts configuration to JSON (for database serialization).
  Map<String, dynamic> toJson() {
    return {
      'practiceMode': practiceMode.name,
      'handSelection': handSelection.name,
      if (key != null) 'key': key!.name,
      if (scaleType != null) 'scaleType': scaleType!.name,
      if (chordType != null) 'chordType': chordType!.name,
      if (includeInversions) 'includeInversions': includeInversions,
      if (includeSeventhChords) 'includeSeventhChords': includeSeventhChords,
      if (musicalNote != null) 'musicalNote': musicalNote!.name,
      if (arpeggioType != null) 'arpeggioType': arpeggioType!.name,
      if (arpeggioOctaves != ArpeggioOctaves.one) 'arpeggioOctaves': arpeggioOctaves.name,
      if (chordProgressionId != null) 'chordProgressionId': chordProgressionId,
      if (startOctave != 4) 'startOctave': startOctave,
      if (autoProgressKeys) 'autoProgressKeys': autoProgressKeys,
    };
  }
  
  /// Validates that required fields are present for the configured practice mode.
  /// 
  /// Throws [ArgumentError] if required fields are missing.
  void validate() {
    switch (practiceMode) {
      case PracticeMode.scales:
        if (key == null) throw ArgumentError('key is required for scales mode');
        if (scaleType == null) throw ArgumentError('scaleType is required for scales mode');
        break;
        
      case PracticeMode.chordsByKey:
        if (key == null) throw ArgumentError('key is required for chordsByKey mode');
        if (scaleType == null) throw ArgumentError('scaleType is required for chordsByKey mode');
        break;
        
      case PracticeMode.chordsByType:
        if (chordType == null) throw ArgumentError('chordType is required for chordsByType mode');
        break;
        
      case PracticeMode.arpeggios:
        if (musicalNote == null) throw ArgumentError('musicalNote is required for arpeggios mode');
        if (arpeggioType == null) throw ArgumentError('arpeggioType is required for arpeggios mode');
        break;
        
      case PracticeMode.chordProgressions:
        if (key == null) throw ArgumentError('key is required for chordProgressions mode');
        if (chordProgressionId == null) throw ArgumentError('chordProgressionId is required for chordProgressions mode');
        break;
    }
  }
  
  /// Creates a copy with modified fields (copyWith pattern for immutability).
  ExerciseConfiguration copyWith({
    PracticeMode? practiceMode,
    HandSelection? handSelection,
    Key? key,
    ScaleType? scaleType,
    ChordType? chordType,
    bool? includeInversions,
    bool? includeSeventhChords,
    MusicalNote? musicalNote,
    ArpeggioType? arpeggioType,
    ArpeggioOctaves? arpeggioOctaves,
    String? chordProgressionId,
    int? startOctave,
    bool? autoProgressKeys,
  }) {
    return ExerciseConfiguration(
      practiceMode: practiceMode ?? this.practiceMode,
      handSelection: handSelection ?? this.handSelection,
      key: key ?? this.key,
      scaleType: scaleType ?? this.scaleType,
      chordType: chordType ?? this.chordType,
      includeInversions: includeInversions ?? this.includeInversions,
      includeSeventhChords: includeSeventhChords ?? this.includeSeventhChords,
      musicalNote: musicalNote ?? this.musicalNote,
      arpeggioType: arpeggioType ?? this.arpeggioType,
      arpeggioOctaves: arpeggioOctaves ?? this.arpeggioOctaves,
      chordProgressionId: chordProgressionId ?? this.chordProgressionId,
      startOctave: startOctave ?? this.startOctave,
      autoProgressKeys: autoProgressKeys ?? this.autoProgressKeys,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseConfiguration &&
          runtimeType == other.runtimeType &&
          practiceMode == other.practiceMode &&
          handSelection == other.handSelection &&
          key == other.key &&
          scaleType == other.scaleType &&
          chordType == other.chordType &&
          includeInversions == other.includeInversions &&
          includeSeventhChords == other.includeSeventhChords &&
          musicalNote == other.musicalNote &&
          arpeggioType == other.arpeggioType &&
          arpeggioOctaves == other.arpeggioOctaves &&
          chordProgressionId == other.chordProgressionId &&
          startOctave == other.startOctave &&
          autoProgressKeys == other.autoProgressKeys;
  
  @override
  int get hashCode => Object.hash(
        practiceMode,
        handSelection,
        key,
        scaleType,
        chordType,
        includeInversions,
        includeSeventhChords,
        musicalNote,
        arpeggioType,
        arpeggioOctaves,
        chordProgressionId,
        startOctave,
        autoProgressKeys,
      );
}
```

### Configuration Requirements by Practice Mode

| Practice Mode         | Required Fields                                        | Optional Fields                                     | Notes                                        |
| --------------------- | ------------------------------------------------------ | --------------------------------------------------- | -------------------------------------------- |
| **scales**            | practiceMode, handSelection, key, scaleType            | startOctave, autoProgressKeys                       | Generates scale patterns in specified key    |
| **chordsByKey**       | practiceMode, handSelection, key, scaleType            | includeSeventhChords, startOctave, autoProgressKeys | Uses scale type to determine diatonic chords |
| **chordsByType**      | practiceMode, handSelection, chordType                 | includeInversions, startOctave, autoProgressKeys    | Plays specific chord type across keys        |
| **arpeggios**         | practiceMode, handSelection, musicalNote, arpeggioType | arpeggioOctaves, startOctave, autoProgressKeys      | Root note + arpeggio pattern                 |
| **chordProgressions** | practiceMode, handSelection, key, chordProgressionId   | startOctave, autoProgressKeys                       | Progression ID maps to ChordProgression.name |

### Enum Serialization Strategy

All domain enums support the `.name` property for JSON serialization:

```dart
// Serialization examples
PracticeMode.scales.name            // → "scales"
HandSelection.both.name             // → "both"
Key.C.name                          // → "C"
ScaleType.major.name                // → "major"
ChordType.majorTriad.name           // → "majorTriad"
ArpeggioType.majorSeventh.name      // → "majorSeventh"
ArpeggioOctaves.two.name            // → "two"

// Deserialization examples
PracticeMode.values.byName("scales")            // → PracticeMode.scales
HandSelection.values.byName("both")             // → HandSelection.both
Key.values.byName("C")                          // → Key.C
```

This approach provides:

- **Type safety**: Compiler catches invalid enum values
- **Readability**: JSON is human-readable ("scales" vs 0)
- **Maintainability**: Reordering enum values doesn't break serialization
- **Built-in**: No custom serialization code needed

### ChordProgression String Identifier

The `chordProgressionId` field stores the `ChordProgression.name` directly (e.g., "I - V", "I - ♭VII"). This maps to `ChordProgressionLibrary.getProgressionByName(name)` for retrieving the full progression object.

**Rationale**: ChordProgression is a complex object with interval arrays (`List<List<int>>`), but exercises are identified by the progression's human-readable name. Storing the name string provides:

- **Queryability**: Easy to filter by progression name in history queries
- **Readability**: "I - V" is more meaningful than an opaque ID or serialized interval array
- **Consistency**: Matches how progressions are referenced in the UI and domain services

**Constraint**: ChordProgression names must be unique in ChordProgressionLibrary (currently enforced by library design).

### JSON Serialization Examples

**Scales Configuration:**

```json
{
  "practiceMode": "scales",
  "handSelection": "both",
  "key": "C",
  "scaleType": "major",
  "startOctave": 4,
  "autoProgressKeys": false
}
```

**Chords by Key Configuration:**

```json
{
  "practiceMode": "chordsByKey",
  "handSelection": "right",
  "key": "Am",
  "scaleType": "harmonicMinor",
  "includeSeventhChords": true,
  "startOctave": 4,
  "autoProgressKeys": true
}
```

**Chords by Type Configuration:**

```json
{
  "practiceMode": "chordsByType",
  "handSelection": "left",
  "chordType": "diminishedTriad",
  "includeInversions": true,
  "startOctave": 3
}
```

**Arpeggios Configuration:**

```json
{
  "practiceMode": "arpeggios",
  "handSelection": "both",
  "musicalNote": "C",
  "arpeggioType": "majorSeventh",
  "arpeggioOctaves": "two",
  "startOctave": 4
}
```

**Chord Progressions Configuration:**

```json
{
  "practiceMode": "chordProgressions",
  "handSelection": "both",
  "key": "C",
  "chordProgressionId": "I - V",
  "startOctave": 4,
  "autoProgressKeys": false
}
```

## Consequences

### Positive

- **Type safety**: Compiler enforces valid configurations; eliminates runtime errors from missing fields
- **Single source of truth**: Configuration logic centralized in domain model instead of scattered across 13+ fields
- **Testability**: Easy to create mock configurations for unit tests; immutability prevents accidental mutations
- **Serialization simplicity**: `toJson()`/`fromJson()` methods provide clean database integration
- **Maintainability**: Adding new configuration fields requires updating one model, not multiple layers
- **Validation clarity**: Explicit validation rules per practice mode make requirements obvious
- **Clean Architecture compliance**: Domain model lives in domain layer, independent of UI and infrastructure
- **Enum robustness**: Using `.name` property makes JSON human-readable and resilient to enum reordering

### Negative

- **Migration effort**: Requires refactoring `PracticeSession` and `PracticePageViewModel` to use `ExerciseConfiguration`
- **Field count**: 13 fields in one model may feel "large," but reflects actual domain complexity
- **Nullable proliferation**: Mode-specific fields are nullable, requiring careful validation
- **ChordProgression coupling**: `chordProgressionId` assumes ChordProgressionLibrary names are stable (acceptable for domain model)

### Neutral

- **No backward compatibility**: This is a new model; no migration path needed from existing scattered fields
- **Validation at construction**: Validation is opt-in via `validate()` method rather than enforced at construction (allows partial configuration during UI input)

## Alternatives Considered

### Alternative 1: Separate Configuration Classes per Mode

Create `ScalesConfiguration`, `ChordsConfiguration`, etc.

**Rejected**: This fragments the codebase and requires complex polymorphism for serialization and database storage. The unified model is simpler and more maintainable.

### Alternative 2: Use Map<String, dynamic> for Configuration

Store configuration as unstructured maps.

**Rejected**: Loses all type safety benefits. Error-prone and difficult to maintain.

### Alternative 3: Store Enum Values as Integers

Use enum indices (0, 1, 2) instead of names for JSON.

**Rejected**: Fragile—reordering enums breaks deserialization. Less readable in raw JSON. The `.name` property provides better maintainability.

### Alternative 4: Serialize ChordProgression as Full Object

Store entire ChordProgression (with interval arrays) in configuration JSON.

**Rejected**: Excessive data duplication. ChordProgression.name is sufficient to uniquely identify progressions, and the full object can be retrieved from ChordProgressionLibrary when needed.

## Related Decisions

- [ADR-0025: Exercise History Data Model](0025-exercise-history-data-model.md) - Configuration field uses this model
- [ADR-0001: Clean Architecture with Three Layers](0001-clean-architecture-three-layers.md) - Domain model placement
- [ADR-0024: Drift for Database Persistence](0024-drift-database-persistence.md) - JSON serialization strategy

## Implementation Notes

### Migration Path

1. **Create domain model**: Implement `ExerciseConfiguration` in `lib/domain/models/practice/`
2. **Add tests**: Unit tests for validation, serialization, equality
3. **Update PracticeSession**: Replace 13 separate fields with single `ExerciseConfiguration config` field
4. **Update ViewModel**: Replace individual setters with `updateConfiguration(ExerciseConfiguration config)` method
5. **Update UI**: Refactor settings panels to build `ExerciseConfiguration` objects
6. **Update exercise history**: Use `config.toJson()` for configuration field in database

### Testing Strategy

**Unit tests** must cover:

- Validation rules for all 5 practice modes (required fields)
- JSON serialization round-trips (toJson → fromJson preserves data)
- Enum serialization correctness (name property roundtrips)
- Equality and hashCode correctness
- CopyWith pattern behavior

**Integration tests** must cover:

- Configuration created from UI → stored in database → retrieved correctly
- Invalid configurations rejected at validation (missing required fields)

## Future Enhancements

1. **Builder pattern**: Add `ExerciseConfigurationBuilder` for cleaner UI construction with fluent API
2. **Presets**: Named configuration presets (e.g., "Beginner Scales", "Jazz Progressions")
3. **Validation messages**: Return specific validation errors instead of throwing exceptions
4. **Schema evolution**: Add versioning if configuration structure changes significantly
5. **Configuration library**: Shared configuration templates across profiles (e.g., curriculum-based exercise sequences)
