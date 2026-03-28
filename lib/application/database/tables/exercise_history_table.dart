import "package:drift/drift.dart";

import "user_profile_table.dart";

/// Drift table for the raw exercise history event log.
///
/// Each row is one completed exercise. Configuration fields mirror those of
/// [ExerciseConfiguration] so the two stay in sync as new modes are added.
/// Enum values are stored as their `.name` strings for readability and to
/// avoid coupling the database schema to Dart ordinal values.
///
/// The `(profileId, completedAt)` index is declared in [AppDatabase]'s
/// migration to support efficiently fetching a profile's history ordered by
/// date.
@DataClassName("ExerciseHistoryTableData")
class ExerciseHistoryTable extends Table {
  /// Unique identifier for this history entry (UUID v4).
  TextColumn get id => text()();

  /// Foreign-key reference to the [UserProfileTable] that owns this entry.
  ///
  /// `customConstraint` adds the REFERENCES clause while keeping drift's
  /// own NOT NULL constraint in place.
  TextColumn get profileId => text().customConstraint(
    "NOT NULL REFERENCES user_profile_table(id) ON DELETE CASCADE",
  )();

  /// Wall-clock timestamp when the exercise was completed.
  DateTimeColumn get completedAt => dateTime()();

  // ── Exercise configuration columns ────────────────────────────────────────

  /// Practice mode name (e.g. "scales", "chordsByKey"). Never null.
  TextColumn get practiceMode => text()();

  /// Hand selection name (e.g. "right", "left", "both"). Never null.
  TextColumn get handSelection => text()();

  /// Musical key name (e.g. "c", "fSharp"). Null for modes without a key.
  TextColumn get musicalKey => text().nullable()();

  /// Scale type name (e.g. "major", "dorian"). Null for non-scale modes.
  TextColumn get scaleType => text().nullable()();

  /// Chord type name (e.g. "major", "dominant7"). Null for non-chord modes.
  TextColumn get chordType => text().nullable()();

  /// Whether inversions were included (chordsByType mode).
  BoolColumn get includeInversions =>
      boolean().withDefault(const Constant(false))();

  /// Whether seventh chords were included (chordsByKey mode).
  BoolColumn get includeSeventhChords =>
      boolean().withDefault(const Constant(false))();

  /// Root note name for arpeggios mode (e.g. "c", "fSharp"). Null otherwise.
  TextColumn get musicalNote => text().nullable()();

  /// Arpeggio type name (e.g. "major", "minor7"). Null for non-arpeggio modes.
  TextColumn get arpeggioType => text().nullable()();

  /// Arpeggio octave count name (e.g. "one", "two"). Null for non-arpeggio modes.
  TextColumn get arpeggioOctaves => text().nullable()();

  /// Chord progression identifier (chordProgressions mode). Null otherwise.
  TextColumn get chordProgressionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
