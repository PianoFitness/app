import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:path_provider/path_provider.dart";

import "app_database.steps.dart";
import "daos/exercise_history_dao.dart";
import "daos/user_profile_dao.dart";
import "tables/exercise_history_table.dart";
import "tables/user_profile_table.dart";

part "app_database.g.dart";

/// Central Drift database for Piano Fitness.
///
/// All persistent tables are registered in the [DriftDatabase] annotation.
/// Add new table classes to the `tables` list as features require persistence.
///
/// Schema version must be incremented whenever the table structure changes.
/// Provide a corresponding migration in [migration] to handle upgrades.
///
/// **Note:** When no tables are registered, Drift generates a manager class
/// with an unused `_db` field. The generated file includes `ignore_for_file`
/// for `unused_field` to suppress this analyzer warning. This warning naturally
/// disappears once tables are added to the schema.
///
/// Usage (via Provider in main.dart):
/// ```dart
/// Provider<AppDatabase>(
///   create: (_) => AppDatabase(),
///   dispose: (_, db) => db.close(),
/// )
/// ```
@DriftDatabase(
  tables: [UserProfileTable, ExerciseHistoryTable],
  daos: [UserProfileDao, ExerciseHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates the database, optionally accepting a custom [QueryExecutor].
  ///
  /// Passing a custom executor is used in tests to provide an in-memory
  /// database:
  /// ```dart
  /// final db = AppDatabase(NativeDatabase.memory());
  /// ```
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: stepByStep(
        from1To2: (m, schema) async {
          // Create the user_profile_table for version 2
          await m.createTable(schema.userProfileTable);
        },
        from2To3: (m, schema) async {
          // Create the exercise_history_table for version 3
          await m.createTable(schema.exerciseHistoryTable);
          // Index for efficiently querying a profile's history by date
          await m.issueCustomQuery(
            "CREATE INDEX IF NOT EXISTS idx_exercise_history_profile_date "
            "ON exercise_history_table (profile_id, completed_at DESC)",
          );
        },
      ),
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: "piano_fitness",
      native: const DriftNativeOptions(
        // Store the database in the application support directory so it is
        // excluded from iCloud backups and persists across app updates.
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
