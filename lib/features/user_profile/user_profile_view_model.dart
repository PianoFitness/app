import "package:flutter/foundation.dart";
import "package:logging/logging.dart";

import "../../domain/models/profile_sort_order.dart";
import "../../domain/models/user_profile.dart";
import "../../domain/repositories/user_profile_repository.dart";

/// ViewModel for managing user profile state and operations.
///
/// This class handles all business logic for profile management,
/// including CRUD operations, profile selection, and sort preferences.
class UserProfileViewModel extends ChangeNotifier {
  /// Creates a new UserProfileViewModel with injected dependencies.
  UserProfileViewModel({required IUserProfileRepository userProfileRepository})
    : _userProfileRepository = userProfileRepository;

  static final _log = Logger("UserProfileViewModel");

  final IUserProfileRepository _userProfileRepository;

  List<UserProfile> _profiles = [];
  ProfileSortOrder _sortOrder = ProfileSortOrder.lastActive;
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _activeProfile;

  /// All user profiles, sorted according to current sort order.
  List<UserProfile> get profiles => _profiles;

  /// Current sort order preference.
  ProfileSortOrder get sortOrder => _sortOrder;

  /// Loading state for async operations.
  bool get isLoading => _isLoading;

  /// Error message if any operation failed.
  String? get errorMessage => _errorMessage;

  /// Currently active profile.
  UserProfile? get activeProfile => _activeProfile;

  /// Loads all profiles and applies current sort order.
  Future<void> loadProfiles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sortOrder = await _userProfileRepository.getSortOrder();
      _profiles = await _userProfileRepository.getAllProfiles();
      _applySortOrder();

      // Load active profile
      final activeId = await _userProfileRepository.getActiveProfileId();
      if (activeId != null) {
        _activeProfile = _profiles.firstWhere(
          (p) => p.id == activeId,
          orElse: () => _profiles.isNotEmpty
              ? _profiles.first
              : throw Exception("No profiles available"),
        );
        // Update active profile in case it wasn't found
        if (_activeProfile != null) {
          await _userProfileRepository.setActiveProfileId(_activeProfile!.id);
        }
      } else if (_profiles.isNotEmpty) {
        // Auto-select first profile if none is active
        _activeProfile = _profiles.first;
        await _userProfileRepository.setActiveProfileId(_activeProfile!.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _log.severe("Error loading profiles: $e", e, stackTrace);
      _errorMessage = "Failed to load profiles: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new profile with the given display name.
  ///
  /// Validates the name, creates the profile, sets it as active,
  /// and adds it to the list.
  Future<UserProfile?> createProfile(String displayName) async {
    _errorMessage = null;

    try {
      // Validation happens in domain model
      final profile = await _userProfileRepository.createProfile(displayName);

      // Add to list and set as active
      _profiles.add(profile);
      _applySortOrder();

      await selectProfile(profile.id);

      notifyListeners();
      return profile;
    } catch (e, stackTrace) {
      _log.severe("Error creating profile: $e", e, stackTrace);
      _errorMessage = e is ArgumentError
          ? e.message.toString()
          : "Failed to create profile: $e";
      notifyListeners();
      return null;
    }
  }

  /// Updates an existing profile.
  Future<bool> updateProfile(UserProfile profile) async {
    _errorMessage = null;

    try {
      final updated = await _userProfileRepository.updateProfile(profile);

      // Update in list
      final index = _profiles.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        _profiles[index] = updated;
        _applySortOrder();
      }

      // Update active profile if it was the one updated
      if (_activeProfile?.id == updated.id) {
        _activeProfile = updated;
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _log.severe("Error updating profile: $e", e, stackTrace);
      _errorMessage = "Failed to update profile: $e";
      notifyListeners();
      return false;
    }
  }

  /// Deletes a profile by ID.
  ///
  /// If the deleted profile is the currently active profile,
  /// clears the active profile (caller should handle navigation).
  Future<bool> deleteProfile(String id) async {
    _errorMessage = null;

    try {
      await _userProfileRepository.deleteProfile(id);

      // Remove from list
      _profiles.removeWhere((p) => p.id == id);

      // Clear active profile if it was deleted
      if (_activeProfile?.id == id) {
        if (_profiles.isNotEmpty) {
          // Auto-select first profile after deletion
          await selectProfile(_profiles.first.id);
        } else {
          _activeProfile = null;
        }
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _log.severe("Error deleting profile: $e", e, stackTrace);
      _errorMessage = "Failed to delete profile: $e";
      notifyListeners();
      return false;
    }
  }

  /// Selects a profile as the active profile.
  Future<void> selectProfile(String id) async {
    try {
      // Find profile with safe lookup
      final profile = _profiles.firstWhere(
        (p) => p.id == id,
        orElse: () => throw StateError("Profile with id $id not found"),
      );

      await _userProfileRepository.setActiveProfileId(id);
      _activeProfile = profile;
      notifyListeners();
    } catch (e, stackTrace) {
      _log.severe("Error selecting profile: $e", e, stackTrace);
      _errorMessage = "Failed to select profile: $e";
      notifyListeners();
    }
  }

  /// Toggles between alphabetical and last-active sort order.
  Future<void> toggleSortOrder() async {
    try {
      _sortOrder = _sortOrder == ProfileSortOrder.alphabetical
          ? ProfileSortOrder.lastActive
          : ProfileSortOrder.alphabetical;

      await _userProfileRepository.setSortOrder(_sortOrder);
      _applySortOrder();
      notifyListeners();
    } catch (e, stackTrace) {
      _log.severe("Error toggling sort order: $e", e, stackTrace);
      _errorMessage = "Failed to update sort order: $e";
      notifyListeners();
    }
  }

  /// Updates a profile's last practice date to now.
  Future<void> updateLastPracticeDate(String profileId) async {
    try {
      // Find profile with safe lookup - return early if not found
      final matchingProfiles = _profiles.where((p) => p.id == profileId);
      if (matchingProfiles.isEmpty) {
        _log.warning("Profile with id $profileId not found");
        return;
      }

      final profile = matchingProfiles.first;
      final updated = profile.copyWith(lastPracticeDate: DateTime.now());

      // Update repository directly (don't call updateProfile to avoid setting errorMessage)
      final result = await _userProfileRepository.updateProfile(updated);

      // Update in local list
      final index = _profiles.indexWhere((p) => p.id == result.id);
      if (index != -1) {
        _profiles[index] = result;
        _applySortOrder();
      }

      // Update active profile if it was the one updated
      if (_activeProfile?.id == result.id) {
        _activeProfile = result;
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _log.warning("Error updating last practice date: $e", e, stackTrace);
      // Don't show error to user for background updates - only log
    }
  }

  /// Applies current sort order to the profiles list.
  void _applySortOrder() {
    if (_sortOrder == ProfileSortOrder.alphabetical) {
      _profiles.sort((a, b) => a.displayName.compareTo(b.displayName));
    } else {
      // Sort by lastPracticeDate, most recent first, nulls last
      _profiles.sort((a, b) {
        if (a.lastPracticeDate == null && b.lastPracticeDate == null) return 0;
        if (a.lastPracticeDate == null) return 1;
        if (b.lastPracticeDate == null) return -1;
        return b.lastPracticeDate!.compareTo(a.lastPracticeDate!);
      });
    }
  }

  @override
  void dispose() {
    // No resources to clean up (no streams or controllers)
    super.dispose();
  }
}
