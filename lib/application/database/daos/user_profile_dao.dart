import "package:drift/drift.dart";

import "../app_database.dart";
import "../tables/user_profile_table.dart";

part "user_profile_dao.g.dart";

/// Data Access Object for user profile operations.
///
/// Provides methods for CRUD operations on the UserProfile table.
@DriftAccessor(tables: [UserProfileTable])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  /// Creates a UserProfileDao with the given [db] instance.
  UserProfileDao(super.db);

  /// Retrieves all profiles from the database.
  Future<List<UserProfileTableData>> getAllProfiles() {
    return select(userProfileTable).get();
  }

  /// Retrieves profiles sorted alphabetically by display name.
  Future<List<UserProfileTableData>> getProfilesAlphabetically() {
    return (select(
      userProfileTable,
    )..orderBy([(t) => OrderingTerm(expression: t.displayName)])).get();
  }

  /// Retrieves profiles sorted by last practice date (most recent first).
  /// Profiles that have never practiced appear last.
  Future<List<UserProfileTableData>> getProfilesByLastActive() {
    return (select(userProfileTable)..orderBy([
          (t) => OrderingTerm(
            expression: t.lastPracticeDate,
            mode: OrderingMode.desc,
            nulls: NullsOrder.last,
          ),
        ]))
        .get();
  }

  /// Retrieves a specific profile by ID.
  Future<UserProfileTableData?> getProfile(String id) {
    return (select(
      userProfileTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new profile into the database.
  Future<int> insertProfile(UserProfileTableCompanion profile) {
    return into(userProfileTable).insert(profile);
  }

  /// Updates an existing profile.
  Future<bool> updateProfile(UserProfileTableData profile) {
    return update(userProfileTable).replace(profile);
  }

  /// Deletes a profile by ID.
  Future<int> deleteProfile(String id) {
    return (delete(userProfileTable)..where((t) => t.id.equals(id))).go();
  }
}
