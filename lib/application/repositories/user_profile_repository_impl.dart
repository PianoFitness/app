import "package:logging/logging.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uuid/uuid.dart";
import "package:drift/drift.dart";

import "../../domain/models/profile_sort_order.dart";
import "../../domain/models/user_profile.dart";
import "../../domain/repositories/user_profile_repository.dart";
import "../database/app_database.dart";

/// Implementation of IUserProfileRepository using Drift and SharedPreferences.
///
/// Uses Drift for profile CRUD operations and SharedPreferences for
/// active profile ID and sort order preferences.
class UserProfileRepositoryImpl implements IUserProfileRepository {
  /// Creates a UserProfileRepositoryImpl with required dependencies.
  UserProfileRepositoryImpl({
    required AppDatabase database,
    required SharedPreferences prefs,
  }) : _database = database,
       _prefs = prefs;

  final AppDatabase _database;
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();
  final Logger _logger = Logger("UserProfileRepositoryImpl");

  static const String _activeProfileIdKey = "active_profile_id";
  static const String _sortOrderKey = "profile_sort_order";

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final profiles = await _database.userProfileDao.getAllProfiles();
      return profiles.map(_toDomainModel).toList();
    } catch (e, stackTrace) {
      _logger.severe("Error loading profiles", e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<UserProfile?> getProfile(String id) async {
    try {
      final profile = await _database.userProfileDao.getProfile(id);
      return profile != null ? _toDomainModel(profile) : null;
    } catch (e, stackTrace) {
      _logger.severe("Error loading profile $id", e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<UserProfile> createProfile(String displayName) async {
    try {
      final profile = UserProfile(
        id: _uuid.v4(),
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      final companion = UserProfileTableCompanion.insert(
        id: profile.id,
        displayName: profile.displayName,
        lastPracticeDate: Value(profile.lastPracticeDate),
        createdAt: profile.createdAt,
      );

      await _database.userProfileDao.insertProfile(companion);
      return profile;
    } catch (e, stackTrace) {
      _logger.severe("Error creating profile", e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final tableData = _toTableData(profile);
      final success = await _database.userProfileDao.updateProfile(tableData);

      if (!success) {
        throw Exception("Profile not found: ${profile.id}");
      }

      return profile;
    } catch (e, stackTrace) {
      _logger.severe("Error updating profile", e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteProfile(String id) async {
    try {
      await _database.userProfileDao.deleteProfile(id);

      // Clear active profile ID if it was the deleted profile
      final activeId = await getActiveProfileId();
      if (activeId == id) {
        final success = await _prefs.remove(_activeProfileIdKey);
        if (!success) {
          throw Exception("Failed to clear active profile ID from preferences");
        }
      }
    } catch (e, stackTrace) {
      _logger.severe("Error deleting profile $id", e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String?> getActiveProfileId() async {
    try {
      return _prefs.getString(_activeProfileIdKey);
    } catch (e, stackTrace) {
      _logger.severe("Error loading active profile ID", e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> setActiveProfileId(String id) async {
    try {
      final success = await _prefs.setString(_activeProfileIdKey, id);
      if (!success) {
        throw Exception("Failed to save active profile ID to preferences");
      }
    } catch (e, stackTrace) {
      _logger.severe("Error saving active profile ID", e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<ProfileSortOrder> getSortOrder() async {
    try {
      final orderString = _prefs.getString(_sortOrderKey);
      if (orderString == null) {
        return ProfileSortOrder.lastActive;
      }
      // Use enum parsing with fallback
      return ProfileSortOrder.values.firstWhere(
        (e) => e.name == orderString,
        orElse: () => ProfileSortOrder.lastActive,
      );
    } catch (e, stackTrace) {
      _logger.severe("Error loading sort order", e, stackTrace);
      return ProfileSortOrder.lastActive; // Default on error
    }
  }

  @override
  Future<void> setSortOrder(ProfileSortOrder order) async {
    try {
      final success = await _prefs.setString(_sortOrderKey, order.name);
      if (!success) {
        throw Exception("Failed to save sort order to preferences");
      }
    } catch (e, stackTrace) {
      _logger.severe("Error saving sort order", e, stackTrace);
      rethrow;
    }
  }

  /// Converts a Drift table data object to a domain model.
  UserProfile _toDomainModel(UserProfileTableData data) {
    return UserProfile(
      id: data.id,
      displayName: data.displayName,
      lastPracticeDate: data.lastPracticeDate,
      createdAt: data.createdAt,
    );
  }

  /// Converts a domain model to a Drift table data object.
  UserProfileTableData _toTableData(UserProfile profile) {
    return UserProfileTableData(
      id: profile.id,
      displayName: profile.displayName,
      lastPracticeDate: profile.lastPracticeDate,
      createdAt: profile.createdAt,
    );
  }
}
