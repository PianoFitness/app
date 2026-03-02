import "package:drift/drift.dart";

/// Drift table for user profiles.
///
/// Each profile represents an independent user on the shared device,
/// storing only their display name and practice activity metadata.
@DataClassName("UserProfileTableData")
class UserProfileTable extends Table {
  /// Unique identifier (UUID) for the profile.
  TextColumn get id => text()();

  /// Display name for the profile (1-30 characters).
  /// Typically the user's first name for privacy and simplicity.
  TextColumn get displayName => text().withLength(min: 1, max: 30)();

  /// The last date when this profile practiced.
  /// Null if the profile has never practiced.
  DateTimeColumn get lastPracticeDate => dateTime().nullable()();

  /// The timestamp when this profile was created.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
