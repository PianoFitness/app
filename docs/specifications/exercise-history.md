<!--
  Status: Draft
  Created: 2026-03-02
  Last updated: 2026-03-02
-->

# Exercise History Specification

## Overview

The Exercise History feature provides persistent logging of completed practice exercises, enabling users to track their practice patterns, measure progress over time, and identify areas for improvement. This is the foundational data layer for analytics and motivational features.

The feature is inspired by gym workout logging: each time a user successfully completes a practice exercise (like playing a C Major Scale or I-IV-V-I chord progression), an entry is recorded to the database—analogous to logging a "set" of physical exercises.

This specification covers the **MVP implementation**, focusing on simple, reliable event logging without advanced analytics. Future phases will add aggregation queries, visualization, and performance metrics.

## Goals

- **Capture practice activity**: Log every completed exercise with essential metadata (what, when, who, how)
- **Enable future analytics**: Provide clean data for building progress tracking, streak counting, and pattern analysis features
- **Work across all modes**: Support scales, chords (by key/type), arpeggios, and chord progressions with a unified data model
- **Respect user privacy**: Exercise history is profile-specific and deleted when profiles are deleted
- **Stay simple for MVP**: Focus on reliable logging; defer advanced metrics and UI to later phases

## Requirements

### Functional Requirements

- **Log completed exercises**: When a user completes a practice exercise, create a timestamped database entry
- **Profile association**: Each entry must be linked to the active user profile
- **Composite identification**: Exercises are identified by practice mode + musical key + optional exercise type (e.g., scales/C/major or chordProgressions/C/i_iv_v_i)
- **Hand selection tracking**: Record whether the exercise was practiced with left hand, right hand, or both hands
- **Extensible metadata**: Support storing additional configuration details (tempo, progression name, etc.) without schema changes

### Data Retention Requirements

- **Cascade deletion**: When a user profile is deleted, all associated exercise history entries must be automatically deleted
- **No automatic cleanup**: Exercise history is retained indefinitely unless the profile is deleted or the user explicitly clears it (future feature)

### Performance Requirements

- **Low-latency writes**: Exercise completion logging should complete in < 100ms to avoid disrupting practice flow
- **Efficient queries**: Aggregation queries (e.g., "count exercises for this profile in the last 7 days") should complete in < 200ms for up to 10,000 records

## Accessibility

This feature has no direct UI surface in the MVP—it is a background data persistence layer. Accessibility considerations will apply when we build UI for viewing exercise history in a future phase.

## Design Notes

### Exercise Configuration Model

Exercise configurations are represented by the **`ExerciseConfiguration`** domain model (see ADR-0026). This immutable model unifies all practice mode configuration parameters (13 fields) into a single, type-safe structure with JSON serialization support.

The `configuration` field in `ExerciseHistoryTable` stores the serialized `ExerciseConfiguration` object, providing:

- **Complete reproducibility**: All configuration parameters preserved for re-creating the exact exercise
- **Type-safe deserialization**: JSON can be deserialized back to `ExerciseConfiguration` using `ExerciseConfiguration.fromJson()`
- **Extensibility**: Adding new configuration fields to the domain model doesn't require database schema migrations
- **Validation**: Configuration validation rules are enforced in the domain model via `config.validate()`

**Integration with history logging:**

```dart
// In PracticePageViewModel when exercise completes
final entry = ExerciseHistoryEntry(
  profileId: currentProfile.id,
  completedAt: DateTime.now(),
  practiceMode: config.practiceMode.name,
  musicalKey: deriveMusicalKey(config),  // Mode-specific derivation
  exerciseType: deriveExerciseType(config),  // Mode-specific derivation
  handSelection: config.handSelection.name,
  configuration: jsonEncode(config.toJson()),  // Serialize complete config
);
await exerciseHistoryRepository.logExercise(entry);
```

### Exercise History Data Model

The core entity is an **exercise history entry**, representing one completed practice "set."

**ExerciseHistoryEntry** must hold:

- `id`: Auto-incrementing integer primary key
- `profileId`: Foreign key to `UserProfileTable` (CASCADE delete)
- `completedAt`: Timestamp when the exercise was completed (DateTime)
- `practiceMode`: String representation of `PracticeMode` enum (scales, chordsByKey, chordsByType, arpeggios, chordProgressions)
- `musicalKey`: Tonal center as string (e.g., "C", "Am", "F#", "Bb")
- `exerciseType`: Optional string for mode-specific refinement (e.g., "major_scale", "minor_triad", "i_iv_v_i")
- `handSelection`: Optional string indicating which hands were used ("left", "right", "both")
- `configuration`: Optional JSON string for extensible metadata (tempo, accuracy, duration, etc.)

**Composite exercise identification**: Exercises are uniquely described (not uniquely constrained) by:

```
(practiceMode, musicalKey, exerciseType)
```

Multiple completions of the same exercise create separate rows—each is an independent event.

#### Composite Key Derivation Rules

The composite key components are derived from `ExerciseConfiguration` using mode-specific rules:

| Practice Mode         | `musicalKey` Derivation         | `exerciseType` Derivation                                      | Example Composite Key                   |
| --------------------- | ------------------------------- | -------------------------------------------------------------- | --------------------------------------- |
| **scales**            | `config.key.name`               | `config.scaleType.name`                                        | (scales, C, major)                      |
| **chordsByKey**       | `config.key.name`               | `config.scaleType.name + "_chords"`                            | (chordsByKey, Am, harmonicMinor_chords) |
| **chordsByType**      | Iteration key (e.g., "C", "Db") | `config.chordType.name` + inversion suffix                     | (chordsByType, C, majorTriad_first)     |
| **arpeggios**         | `config.musicalNote.name`       | `config.arpeggioType.name + "_" + config.arpeggioOctaves.name` | (arpeggios, C, majorSeventh_two)        |
| **chordProgressions** | `config.key.name`               | `config.chordProgressionId`                                    | (chordProgressions, C, I - V)           |

**Derivation notes:**

- **chordsByType iteration**: This mode iterates through all 12 chromatic keys. Each iteration logs a separate entry with its own `musicalKey` (C, Db, D, etc.).
- **Inversion suffixes**: When `includeInversions` is true, each inversion (root, first, second) is logged as a separate `exerciseType` (e.g., "majorTriad", "majorTriad_first", "majorTriad_second").
- **ChordProgression IDs**: The `chordProgressionId` field stores `ChordProgression.name` directly (e.g., "I - V", "I - ♭VII").
- **Scale type suffixes**: For chordsByKey, the "_chords" suffix differentiates chord exercises from scale exercises in the same key.

**Configuration field** (JSON string) stores the complete `ExerciseConfiguration` object serialized via `config.toJson()`. This captures all mode-specific parameters for reproducibility and analysis.

#### Configuration Field Structure by Practice Mode

Each practice mode has a specific set of required and optional configuration fields:

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

*Required*: practiceMode, handSelection, key, scaleType  
*Optional*: startOctave (default: 4), autoProgressKeys (default: false)

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

*Required*: practiceMode, handSelection, key, scaleType  
*Optional*: includeSeventhChords (default: false), startOctave (default: 4), autoProgressKeys (default: false)

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

*Required*: practiceMode, handSelection, chordType  
*Optional*: includeInversions (default: false), startOctave (default: 4), autoProgressKeys (default: false)

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

*Required*: practiceMode, handSelection, musicalNote (root note), arpeggioType  
*Optional*: arpeggioOctaves (default: one), startOctave (default: 4), autoProgressKeys (default: false)

**Chord Progressions Configuration:**

```json
{
  "practiceMode": "chordProgressions",
  "handSelection": "both",
  "key": "C",
  "chordProgressionId": "I - V",
  "startOctave": 4
}
```

*Required*: practiceMode, handSelection, key, chordProgressionId  
*Optional*: startOctave (default: 4), autoProgressKeys (default: false)

#### Enum Serialization

All domain enums use the `.name` property for JSON serialization (e.g., `PracticeMode.scales.name → "scales"`). Deserialization uses `EnumType.values.byName(string)` for type-safe reconstruction.

### Completion Criteria (MVP)

An exercise is considered "complete" and eligible for logging when:

- The user **plays all notes in the exercise sequence** (regardless of accuracy or timing)
- The user reaches the end of the exercise sequence (no notes remaining)

This low-friction completion criteria encourages practice volume and establishes the habit of logging without requiring perfect performance.

Future phases may introduce:

- Accuracy thresholds (e.g., must achieve 80%+ correct notes)
- Manual completion button for user discretion  
- Tempo targets or timing validation

### Database Schema (Drift)

Implemented as a Drift table in `lib/application/database/tables/exercise_history_table.dart`:

```dart
@DataClassName("ExerciseHistoryEntry")
class ExerciseHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text()
    .references(UserProfileTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get practiceMode => text()();
  TextColumn get musicalKey => text()();
  TextColumn get exerciseType => text().nullable()();
  TextColumn get handSelection => text().nullable()();
  TextColumn get configuration => text().nullable()();
}
```

**Indexes**: Consider adding composite index on `(profileId, completedAt DESC)` for efficient queries like "recent practice activity for this profile."

### Repository Interface

Define a domain repository interface for exercise history operations:

**IExerciseHistoryRepository** must support:

- `Future<void> logExercise(ExerciseHistoryEntry entry)` — Create a new history entry
- `Future<List<ExerciseHistoryEntry>> getHistory(String profileId, {DateTime? since, DateTime? until})` — Retrieve entries for a profile, optionally filtered by date range
- `Future<int> countExercises(String profileId, {DateTime? since})` — Count completed exercises for a profile
- `Future<void> deleteHistory(String profileId)` — Delete all history for a profile (admin/testing, not user-facing in MVP)

Implementation resides in `lib/application/database/daos/exercise_history_dao.dart`.

## Integration Points

- **User Profiles** (`docs/specifications/user-profiles.md`): Exercise history is linked to profiles via `profileId` foreign key with CASCADE delete
- **Exercise Configuration Model** (ADR-0026): The `configuration` field stores serialized `ExerciseConfiguration` objects
- **Practice Sessions** (`docs/specifications/practice-sessions.md`): PracticePageViewModel calls the repository to log exercises upon completion
- **Drift Database** (ADR-0024): Database schema and DAO implementation follow established Drift patterns from user profiles feature
- **Repository Pattern** (ADR-0004): Data access abstracted behind domain interface for testability and Clean Architecture compliance

## Implementation Phases

### Phase 1 — MVP: Event Logging (Current)

**Goal**: Establish reliable exercise completion logging with minimal friction.

**Deliverables**:

- Drift table definition for `ExerciseHistoryTable`
- DAO implementation with insert and basic query operations
- Domain repository interface (`IExerciseHistoryRepository`)
- Integration in `PracticePageViewModel` to log exercises on completion
- Unit tests for DAO operations
- Repository mock for widget tests

**What's NOT included**:

- No UI for viewing history (data layer only)
- No analytics or aggregation queries beyond basic count
- No accuracy or performance metrics captured

### Phase 2 — History Viewing & Basic Analytics (Future)

**Goal**: Let users view their practice history and see simple statistics.

**Deliverables**:

- History page showing recent completed exercises grouped by date
- Basic stats: total exercises completed, most practiced keys, current streak
- Filtering by practice mode, musical key, or date range

### Phase 3 — Performance Metrics & Progress Tracking (Future)

**Goal**: Add performance metrics (tempo, accuracy, duration) and visualize progress over time.

**Deliverables**:

- Capture tempo (BPM) and accuracy percentage in `configuration` field
- Progress charts showing improvement in tempo and accuracy for specific exercises
- Goal-setting and achievement tracking

## Testing Requirements

### Unit Tests

- **DAO operations**: Insert, query, count, delete operations for exercise history entries
- **Repository implementation**: Verify repository correctly calls DAO and maps data
- **Cascade deletion**: Verify that deleting a profile deletes all associated exercise history

### Integration Tests

- **End-to-end logging flow**: Complete an exercise in practice page → verify entry created in database
- **Profile lifecycle**: Create profile → log exercises → delete profile → verify history deleted

### Test Data

Use `NativeDatabase.memory()` for isolated, fast database tests. Seed with sample profiles and history entries for query testing.

## Acceptance Criteria

✅ **Exercise logging**:

- When a user completes any practice exercise (scales, chords, arpeggios, progressions), a new entry is created in `ExerciseHistoryTable`
- Entry contains correct `profileId`, `completedAt` timestamp, `practiceMode`, `musicalKey`, and `handSelection`

✅ **Profile association**:

- Exercise history entries are linked to the active user profile
- Deleting a profile automatically deletes all associated exercise history (CASCADE)

✅ **Data integrity**:

- All required fields (`id`, `profileId`, `completedAt`, `practiceMode`, `musicalKey`) are populated
- Foreign key constraint to `UserProfileTable` is enforced

✅ **Testability**:

- DAO operations are unit tested with in-memory database
- Repository interface can be mocked for ViewModel tests
- Cascade deletion is verified via integration test

✅ **Performance**:

- Logging an exercise completes in < 100ms (local SQLite write)
- Querying recent history (last 30 days) completes in < 200ms for up to 10,000 records

## Future Enhancements

### Phase 2+

- **History UI**: Dedicated page for viewing exercise history with filtering/sorting
- **Statistics dashboard**: Aggregated metrics like total exercises, most practiced keys, longest streak
- **CSV export**: Allow users to export their practice history for external analysis
- **Performance metrics**: Capture tempo, accuracy percentage, error count, and duration in `configuration` field
- **Session grouping**: Add `sessionId` to group exercises completed in the same practice session
- **Goal tracking**: Link exercises to practice goals (e.g., "practice all major scales 5 times this week")
- **Source attribution**: Track which exercise library or method book the exercise came from (aligns with `exercise-system.md` source attribution model)

## Related Documentation

- **ADR-0026**: Unified Exercise Configuration Model — Domain model for representing practice configurations
- **ADR-0025**: Exercise History Data Model — Architectural decision rationale for composite key approach and JSON configuration field
- **ADR-0024**: Drift for Database Persistence — Database implementation strategy
- **exercise-system.md**: Describes the structure of practice exercises, relevant for understanding `exerciseType` values
- **user-profiles.md**: Describes user profile model and lifecycle, including deletion behavior
