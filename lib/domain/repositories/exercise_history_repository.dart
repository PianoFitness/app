import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";

/// Repository interface for reading and writing exercise history entries.
///
/// Each completed exercise is saved as a raw event log entry via [saveEntry].
/// No aggregation is performed at write time; aggregation and filtering are
/// deferred to query time so the raw data can be replayed or re-processed.
///
/// Implementations are in the application layer
/// (`ExerciseHistoryRepositoryImpl`); the domain layer depends only on this
/// interface.
abstract class IExerciseHistoryRepository {
  /// Saves a completed exercise to the history log.
  ///
  /// Throws if the database write fails. Call-sites that do not want to block
  /// the user experience should use `unawaited()` with logging on error.
  Future<void> saveEntry(ExerciseHistoryEntry entry);

  /// Returns history entries for a specific user profile, most recent first.
  ///
  /// Pass [limit] to cap the number of returned entries (useful for "recent
  /// activity" widgets). A null [limit] returns all entries for the profile.
  Future<List<ExerciseHistoryEntry>> getEntriesForProfile(
    String profileId, {
    int? limit,
  });
}
