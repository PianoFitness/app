import "package:drift/drift.dart";

import "../app_database.dart";
import "../tables/exercise_history_table.dart";

part "exercise_history_dao.g.dart";

/// Data Access Object for exercise history operations.
///
/// Provides insert and query methods for the [ExerciseHistoryTable].
/// All filtering and ordering is done in SQL for efficiency.
@DriftAccessor(tables: [ExerciseHistoryTable])
class ExerciseHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseHistoryDaoMixin {
  /// Creates an [ExerciseHistoryDao] backed by [db].
  ExerciseHistoryDao(super.db);

  /// Inserts a new history entry and returns the auto-generated row id.
  Future<int> insertEntry(ExerciseHistoryTableCompanion entry) {
    return into(exerciseHistoryTable).insert(entry);
  }

  /// Returns entries for [profileId] ordered by [completedAt] descending.
  ///
  /// Pass [limit] to cap the result set (e.g. for "last 10" queries).
  Future<List<ExerciseHistoryTableData>> getEntriesForProfile(
    String profileId, {
    int? limit,
  }) {
    final query = select(exerciseHistoryTable)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc),
      ]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }
}
