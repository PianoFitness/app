# ADR-0025: Exercise History Data Model

**Status:** Superseded by [ADR-0028](0028-exercise-history-configuration-mirroring-schema.md)

**Date:** 2026-03-02

> **Note:** This ADR was superseded before implementation. The JSON `configuration` blob, composite `exerciseType` string, and integer autoincrement primary key described here were replaced by a column-mirroring schema with a UUID text primary key (see ADR-0028). The context and requirements remain accurate; only the schema design and repository API differ.

## Context

Piano Fitness needs to track exercise completion history to enable progress tracking, pattern analysis, and motivational features. The primary use case is logging when a user successfully completes a practice exercise (e.g., playing a C Major Scale or I-IV-V-I chord progression).

This is analogous to gym workout logging where each "set" of an exercise is recorded with relevant metadata (weight, reps, date). For piano practice, we need to capture:

- **Which exercise** was completed (practice mode, musical key, exercise type)
- **When** it was completed (timestamp)
- **Who** completed it (user profile)
- **How** it was practiced (hand selection, configuration options)

The data model must:

1. **Work across all practice modes**: Scales, chords (by key/type), arpeggios, and chord progressions each have different configurations but should use a unified logging structure
2. **Support future enhancements**: Allow for adding metrics like tempo, accuracy percentage, duration, and other performance indicators without requiring schema rewrites for existing records
3. **Enable aggregation**: Support queries like "how many times has this user practiced C Major scale in the last week?" or "which keys are practiced most frequently?"
4. **Respect user privacy**: Exercise history should be deleted when the associated profile is deleted (cascade)
5. **Be simple for MVP**: Avoid over-engineering while maintaining extensibility

## Decision

We implement an **event-log-style exercise history table** with a composite key approach for exercise identification. Each completed exercise creates one row representing a single "set" of practice.

### Table Structure

```dart
@DataClassName("ExerciseHistoryEntry")
class ExerciseHistoryTable extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();
  
  // Profile association (CASCADE delete)
  TextColumn get profileId => text()
    .references(UserProfileTable, #id, onDelete: KeyAction.cascade)();
  
  // Temporal tracking
  DateTimeColumn get completedAt => dateTime()();
  
  // Exercise identification (composite key elements)
  TextColumn get practiceMode => text()();      // PracticeMode enum name
  TextColumn get musicalKey => text()();        // e.g., "C", "Am", "F#"
  TextColumn get exerciseType => text().nullable()();  
    // e.g., "major_scale", "minor_triad", "i_iv_v_i"
  
  // Practice configuration
  TextColumn get handSelection => text().nullable()();  
    // "left", "right", "both"
  TextColumn get configuration => text();  
    // JSON string for complete ExerciseConfiguration (required)
}
```

### Composite Exercise Identification

Exercises are uniquely identified by the combination of:

1. **`practiceMode`** (required): Enum name from `PracticeMode` (scales, chordsByKey, chordsByType, arpeggios, chordProgressions)
2. **`musicalKey`** (required): The tonal center (e.g., "C", "Am", "F#", "Bb")
3. **`exerciseType`** (optional): Further refinement within the mode (e.g., "major", "harmonic_minor", "diminished", "i_iv_v_i")

This composite approach provides:

- **Consistency**: Same pattern works for all practice modes
- **Queryability**: Easy to filter by mode, key, or type independently
- **Readability**: Human-readable values instead of opaque IDs

#### Composite Key Derivation Rules by Practice Mode

Each practice mode has specific rules for deriving the composite key components from `ExerciseConfiguration` (see ADR-0026):

| Practice Mode         | `musicalKey` Derivation               | `exerciseType` Derivation                                                                                                               | Example                             |
| --------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| **scales**            | `config.key.name` (e.g., "C", "Am")   | `config.scaleType.name` (e.g., "major", "harmonicMinor")                                                                                | scales/C/major                      |
| **chordsByKey**       | `config.key.name`                     | `config.scaleType.name` + "_chords" suffix                                                                                              | chordsByKey/Am/harmonicMinor_chords |
| **chordsByType**      | Iteration key (e.g., "C", "Db", "D")  | `config.chordType.name` + inversion suffix if `includeInversions` is true (e.g., "majorTriad", "majorTriad_first", "majorTriad_second") | chordsByType/C/majorTriad_first     |
| **arpeggios**         | `config.musicalNote.name` (root note) | `config.arpeggioType.name` + "_" + `config.arpeggioOctaves.name` (e.g., "majorSeventh_two")                                             | arpeggios/C/majorSeventh_two        |
| **chordProgressions** | `config.key.name`                     | `config.chordProgressionId` (e.g., "I - V", "I - ♭VII")                                                                                 | chordProgressions/C/I - V           |

**Notes:**

- **chordsByType iteration**: The mode iterates through all 12 chromatic keys (C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B). Each iteration creates a separate exercise history entry with its own `musicalKey` component.
- **Inversion suffixes**: When `includeInversions` is true for chordsByType, each inversion (root position, first, second) is logged as a separate exercise type (e.g., "majorTriad", "majorTriad_first", "majorTriad_second").
- **ChordProgression IDs**: The `chordProgressionId` field stores `ChordProgression.name` directly (human-readable string like "I - V"). This maps to `ChordProgressionLibrary.getProgressionByName()` for retrieving the full progression object.
- **Scale type suffixes**: For chordsByKey, the "_chords" suffix differentiates chord exercises from scale exercises in the same key (e.g., "major_chords" vs just "major" for scales).

### Configuration Field

The `configuration` field (required text/JSON) stores the complete `ExerciseConfiguration` object (see ADR-0026) as serialized JSON. This provides:

- **Complete exercise context**: All configuration parameters preserved for reproducibility
- **Type-safe deserialization**: JSON can be deserialized back to `ExerciseConfiguration` for analysis
- **Extensibility**: Adding new configuration fields doesn't require schema migrations
- **Mode-specific details**: Each practice mode's unique parameters are captured

#### Configuration Field Structure by Practice Mode

**Scales Configuration Example:**

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

**Chords by Key Configuration Example:**

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

**Chords by Type Configuration Example:**

```json
{
  "practiceMode": "chordsByType",
  "handSelection": "left",
  "chordType": "diminishedTriad",
  "includeInversions": true,
  "startOctave": 3
}
```

**Arpeggios Configuration Example:**

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

**Chord Progressions Configuration Example:**

```json
{
  "practiceMode": "chordProgressions",
  "handSelection": "both",
  "key": "C",
  "chordProgressionId": "I - V",
  "startOctave": 4
}
```

#### Enum Serialization Convention

All domain enums use the `.name` property for JSON serialization (e.g., `PracticeMode.scales.name → "scales"`). This provides:

- **Human readability**: JSON is easy to inspect and debug
- **Refactoring resilience**: Reordering enum values doesn't break serialization
- **Type safety**: Deserialization via `EnumType.values.byName(string)` validates values

#### Future Configuration Extensions

The configuration field can be extended to include performance metrics without schema changes:

```json
{
  "practiceMode": "scales",
  "key": "C",
  "scaleType": "major",
  "handSelection": "both",
  "tempo": 120,
  "accuracy": 0.95,
  "duration": 45.2,
  "attempts": 3
}
```

### MVP Success Criteria

For the MVP, an exercise is considered "complete" and logged when the user **plays all notes in the exercise sequence**, regardless of accuracy. This encourages practice volume and establishes the logging habit before introducing more complex validation.

## Consequences

### Positive

- **Unified model**: Single table works for all practice modes; no mode-specific tables needed
- **MVP-focused**: Captures essential data (what, when, who) without over-engineering
- **Extensible**: JSON configuration field allows adding new metrics without schema migrations
- **Queryable**: Composite key structure enables flexible filtering and aggregation
- **Privacy-respecting**: CASCADE delete ensures exercise history is removed with profiles
- **Event-driven**: Simple append-only pattern—each completion is a new row
- **Testable**: Clean separation between domain logic (what constitutes completion) and persistence (logging the event)

### Negative

- **No upfront accuracy tracking**: MVP doesn't capture performance metrics like error rate or tempo—these must be added later via configuration field or schema migration
- **JSON parsing overhead**: Configuration field requires JSON encode/decode; not ideal for high-frequency queries on nested fields
- **Composite key verbosity**: Queries must filter on multiple columns (practiceMode + musicalKey + exerciseType) rather than a single exercise_id
- **String-based enums**: practiceMode stored as string rather than integer enum; slightly less efficient but more maintainable

### Neutral

- **No deduplication**: Multiple completions of the same exercise create separate rows (intentional—each "set" is logged)
- **No session grouping**: Exercises completed within the same practice session are not explicitly linked (can be inferred from timestamps if needed)

## Related Decisions

- [ADR-0026: Unified Exercise Configuration Model](0026-unified-exercise-configuration-model.md) - Configuration field structure and serialization
- [ADR-0024: Drift for Database Persistence](0024-drift-database-persistence.md) - Database implementation strategy
- [ADR-0001: Clean Architecture with Three Layers](0001-clean-architecture-three-layers.md) - Repository pattern for data access
- [ADR-0004: Repository Pattern for External Dependencies](0004-repository-pattern-external-dependencies.md) - Interface-based data access

## Technical Story

- **Specification**: `docs/specifications/exercise-history.md`
- **Implementation directory**: `lib/application/database/tables/` (table definition)
- **Implementation directory**: `lib/application/database/daos/` (data access object)
- **Domain interface**: `lib/domain/repositories/exercise_history_repository.dart` (future)
- **Related PR**: User profiles (#44) established the profile linkage pattern

## Future Enhancements

The following enhancements can be added via schema migrations or configuration field additions:

1. **Performance metrics**: Tempo (BPM), accuracy percentage, error count, duration (seconds)
2. **Session grouping**: `session_id` to group exercises completed in one practice session
3. **Difficulty tracking**: `difficulty_level` (beginner, intermediate, advanced)
4. **Streak tracking**: Derived from `completedAt` timestamps per exercise/key
5. **Goal association**: Link exercises to practice goals or learning objectives
6. **Source attribution**: Track which exercise library or method book the exercise came from
