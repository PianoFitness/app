<!--
  Status: Active
  Created: 2026-03-02
  Last updated: 2026-03-29
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
- **Hand selection tracking**: Record whether the exercise was practiced with left hand, right hand, or both hands
- **Typed configuration columns**: Each `ExerciseConfiguration` field is stored as an individual typed column (no JSON serialization), making every field independently queryable and type-safe; see ADR-0028
- **Extensible schema**: Adding new metrics or configuration fields requires a schema migration; each new field maps to a new typed column in `ExerciseHistoryTable`, consistent with the column-mirroring design

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

Each `ExerciseHistoryEntry` in the database mirrors all fields of `ExerciseConfiguration` as individual typed columns (see ADR-0028). There is no JSON blob; every field is independently queryable.

**Integration with history logging** — `PracticePageViewModel` intercepts the exercise-completed callback and records history before notifying the UI:

```dart
// In PracticePageViewModel.initializePracticeSession()
_practiceSession = PracticeSession(
  onExerciseCompleted: () {
    unawaited(_recordExerciseHistory()); // fire-and-forget, never blocks UI
    onExerciseCompleted();
  },
  // …
);

// _recordExerciseHistory builds the entry from the live ExerciseConfiguration:
final entry = ExerciseHistoryEntry.fromConfiguration(
  id: _uuid.v4(),
  profileId: profileId,
  completedAt: DateTime.now(),
  config: _practiceSession!.config,
);
await _exerciseHistoryRepository.saveEntry(entry);
```

If no active profile exists, or if `saveEntry` throws, the error is logged and silently swallowed — a history save failure must never interrupt practice.

### Exercise History Data Model

The core entity is an **exercise history entry**, representing one completed practice "set."

**`ExerciseHistoryEntry`** holds the following fields. The domain model uses typed Dart enums; the database stores their `.name` strings.

| Field                  | Type               | Nullable | Notes                                                   |
| ---------------------- | ------------------ | -------- | ------------------------------------------------------- |
| `id`                   | `String` (UUID v4) | No       | Unique identifier generated at save time                |
| `profileId`            | `String`           | No       | FK → `UserProfileTable.id`, CASCADE delete              |
| `completedAt`          | `DateTime`         | No       | Wall-clock time the exercise was finished               |
| `practiceMode`         | `PracticeMode`     | No       | Always present                                          |
| `handSelection`        | `HandSelection`    | No       | Always present                                          |
| `musicalKey`           | `Key?`             | Yes      | scales, chordsByKey, chordProgressions modes            |
| `scaleType`            | `ScaleType?`       | Yes      | scales, chordsByKey modes                               |
| `chordType`            | `ChordType?`       | Yes      | chordsByType mode                                       |
| `includeInversions`    | `bool`             | No       | chordsByType mode; default `false`                      |
| `includeSeventhChords` | `bool`             | No       | chordsByKey mode; default `false`                       |
| `musicalNote`          | `MusicalNote?`     | Yes      | arpeggios mode (root note)                              |
| `arpeggioType`         | `ArpeggioType?`    | Yes      | arpeggios mode                                          |
| `arpeggioOctaves`      | `ArpeggioOctaves?` | Yes      | arpeggios mode; default `one`                           |
| `chordProgressionId`   | `String?`          | Yes      | chordProgressions mode; maps to `ChordProgression.name` |

Multiple completions of the same exercise produce separate rows — each is an independent event.

#### Enum Serialization

All domain enums are stored as their `.name` string (e.g., `PracticeMode.scales.name → "scales"`). Deserialization uses `EnumType.values.byName(string)`, which throws a descriptive error if an unknown name is encountered.

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
@DataClassName("ExerciseHistoryTableData")
class ExerciseHistoryTable extends Table {
  TextColumn get id => text()();

  TextColumn get profileId => text().customConstraint(
    "NOT NULL REFERENCES user_profile_table(id) ON DELETE CASCADE",
  )();

  DateTimeColumn get completedAt => dateTime()();

  // ── Exercise configuration columns ──────────────────────────────────────
  TextColumn get practiceMode => text()();
  TextColumn get handSelection => text()();
  TextColumn get musicalKey => text().nullable()();
  TextColumn get scaleType => text().nullable()();
  TextColumn get chordType => text().nullable()();
  BoolColumn get includeInversions =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get includeSeventhChords =>
      boolean().withDefault(const Constant(false))();
  TextColumn get musicalNote => text().nullable()();
  TextColumn get arpeggioType => text().nullable()();
  TextColumn get arpeggioOctaves => text().nullable()();
  TextColumn get chordProgressionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**Notes**:

- `@DataClassName("ExerciseHistoryTableData")` avoids a name collision with the domain model `ExerciseHistoryEntry`.
- The `ON DELETE CASCADE` constraint on `profileId` is expressed via `customConstraint` because Drift v2 does not support `ON DELETE CASCADE` through the regular `.references()` DSL for text columns.
- The **composite index on `(profileId, completedAt DESC)`** is declared in the `AppDatabase.from2To3` migration via `issueCustomQuery` rather than in the table definition, to ensure full SQLite `DESC` ordering support:

```dart
await m.issueCustomQuery(
  "CREATE INDEX IF NOT EXISTS idx_exercise_history_profile_date "
  "ON exercise_history_table (profile_id, completed_at DESC)",
);
```

### Repository Interface

The domain interface (`lib/domain/repositories/exercise_history_repository.dart`) exposes two operations for the MVP:

```dart
abstract class IExerciseHistoryRepository {
  /// Saves a completed exercise to the history log.
  Future<void> saveEntry(ExerciseHistoryEntry entry);

  /// Returns history entries for a profile, most recent first.
  /// Pass [limit] to cap the result (e.g. for "last 10" widgets).
  Future<List<ExerciseHistoryEntry>> getEntriesForProfile(
    String profileId, {
    int? limit,
  });
}
```

The Drift-backed implementation (`ExerciseHistoryRepositoryImpl`) rounds enums through `.name` / `values.byName()` on every write and read, keeping the database content human-readable and the in-memory representation fully typed.

## Integration Points

- **User Profiles** (`docs/specifications/user-profiles.md`): Exercise history is linked to profiles via `profileId` foreign key with CASCADE delete
- **Exercise Configuration Model** (ADR-0026): `ExerciseHistoryEntry.fromConfiguration()` constructs an entry directly from a live `ExerciseConfiguration`; no serialization step
- **Practice Sessions** (`docs/specifications/practice-sessions.md`): `PracticePageViewModel` intercepts the exercise-completed callback to call `saveEntry` (fire-and-forget via `unawaited`) before notifying the UI
- **Drift Database** (ADR-0024): Database schema and DAO implementation follow established Drift patterns from user profiles feature
- **Repository Pattern** (ADR-0004): Data access abstracted behind domain interface for testability and Clean Architecture compliance
- **History UI** (`docs/specifications/practice-history-page.md`): Phase 2 History page built on top of this data layer; see that spec for UI requirements and acceptance criteria

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

### Phase 2 — History Timeline (Current)

**Goal**: Let users view their practice history in a simple, readable timeline.

**Deliverables**:

- A dedicated "History" tab in the main bottom navigation (see `practice-history-page.md`)
- Reverse-chronological list of completed exercises, one card per entry
- General-purpose entry card displaying mode, exercise parameters, hand selection, and timestamp for each entry
- Empty-state and loading-state handling

**What's NOT included in this phase**: date grouping headers, aggregate statistics (total count, streaks, most-practiced keys), and filtering by mode/key/date range. These remain deferred to a later phase.

### Phase 3 — History Analytics & Progress Tracking (Future)

**Goal**: Add date grouping, aggregate statistics, and performance metrics.

**Deliverables**:

- Date-grouped headers in the history list
- Aggregate stats: total exercises completed, most practiced keys, current streak
- Filtering by practice mode, musical key, or date range
- Capture tempo (BPM) and accuracy percentage

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

- All required fields (`id`, `profileId`, `completedAt`, `practiceMode`, `handSelection`) are populated
- Mode-specific optional fields (`musicalKey`, `scaleType`, `chordType`, etc.) are set when relevant and null otherwise
- Foreign key constraint to `UserProfileTable` is enforced

✅ **Testability**:

- DAO operations are unit tested with in-memory database
- Repository interface can be mocked for ViewModel tests
- Cascade deletion is verified via integration test

✅ **Performance**:

- Logging an exercise completes in < 100ms (local SQLite write)
- Querying recent history (last 30 days) completes in < 200ms for up to 10,000 records
- Composite index on `(profileId, completedAt DESC)` is created and used for all profile-based timestamp queries

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

- **ADR-0028**: Exercise History: Configuration-Mirroring Column Schema — Supersedes ADR-0025; documents the column-mirroring design, UUID PK, and fire-and-forget integration that was implemented
- **ADR-0025**: Exercise History Data Model — Original design proposal (superseded); context and requirements remain accurate
- **ADR-0026**: Unified Exercise Configuration Model — Domain model mirrored by the history table schema
- **ADR-0024**: Drift for Database Persistence — Database implementation strategy and migration conventions
- **exercise-system.md**: Describes the structure of practice exercises and the five practice modes
- **user-profiles.md**: Describes user profile model and lifecycle, including deletion behavior
