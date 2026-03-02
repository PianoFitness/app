import "../models/profile_sort_order.dart";
import "../models/user_profile.dart";

/// Repository interface for user profile persistence and management.
///
/// This interface defines the contract for profile CRUD operations,
/// active profile management, and sort order preferences.
/// Implementations handle the actual persistence mechanism (e.g., Drift + SharedPreferences).
abstract class IUserProfileRepository {
  /// Retrieves all user profiles from storage.
  ///
  /// Returns an empty list if no profiles exist.
  Future<List<UserProfile>> getAllProfiles();

  /// Retrieves a specific profile by ID.
  ///
  /// Returns null if the profile doesn't exist.
  Future<UserProfile?> getProfile(String id);

  /// Creates a new profile with the given display name.
  ///
  /// Generates a UUID for the profile ID and sets createdAt to now.
  /// Returns the newly created profile.
  /// Throws [ArgumentError] if displayName is invalid (empty or >30 chars).
  Future<UserProfile> createProfile(String displayName);

  /// Updates an existing profile.
  ///
  /// Returns the updated profile.
  /// Throws an exception if the profile doesn't exist.
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Deletes a profile by ID.
  ///
  /// This should also delete all associated data (practice sessions, preferences, etc.)
  /// when those features are implemented.
  /// Does nothing if the profile doesn't exist.
  Future<void> deleteProfile(String id);

  /// Retrieves the currently active profile ID.
  ///
  /// Returns null if no active profile is set.
  Future<String?> getActiveProfileId();

  /// Sets the currently active profile ID.
  ///
  /// This persists across app restarts.
  Future<void> setActiveProfileId(String id);

  /// Retrieves the profile chooser sort order preference.
  ///
  /// Defaults to [ProfileSortOrder.lastActive] if not set.
  Future<ProfileSortOrder> getSortOrder();

  /// Sets the profile chooser sort order preference.
  ///
  /// This persists across app restarts.
  Future<void> setSortOrder(ProfileSortOrder order);
}
