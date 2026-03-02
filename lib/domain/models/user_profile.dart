/// Domain model representing a user profile.
///
/// This is a framework-independent model using only core Dart types,
/// allowing the domain layer to remain decoupled from UI frameworks.
///
/// Each profile represents an independent user on the shared device,
/// identified by display name only (no personally identifiable information).
class UserProfile {
  /// Creates a new UserProfile instance.
  ///
  /// The [displayName] must be non-empty and between 1-30 characters.
  /// Throws [ArgumentError] if validation fails.
  factory UserProfile({
    required String id,
    required String displayName,
    DateTime? lastPracticeDate,
    required DateTime createdAt,
  }) {
    // Validate display name
    final trimmedDisplayName = displayName.trim();
    if (trimmedDisplayName.isEmpty) {
      throw ArgumentError("Display name cannot be empty");
    }
    if (trimmedDisplayName.length > 30) {
      throw ArgumentError("Display name cannot exceed 30 characters");
    }

    return UserProfile._(
      id: id,
      displayName: trimmedDisplayName,
      lastPracticeDate: lastPracticeDate,
      createdAt: createdAt,
    );
  }

  /// Private constructor for validated instances.
  const UserProfile._({
    required this.id,
    required this.displayName,
    this.lastPracticeDate,
    required this.createdAt,
  });

  /// Unique identifier (UUID) for this profile.
  final String id;

  /// Display name for this profile (1-30 characters).
  /// Typically the user's first name for privacy and simplicity.
  final String displayName;

  /// The last date when this profile practiced.
  /// Null if the profile has never practiced.
  final DateTime? lastPracticeDate;

  /// The timestamp when this profile was created.
  final DateTime createdAt;

  /// Creates a copy of this profile with the given fields replaced.
  ///
  /// To explicitly set [lastPracticeDate] to null, use:
  /// `profile.copyWithNullableDate(lastPracticeDate: null)`
  UserProfile copyWith({
    String? id,
    String? displayName,
    DateTime? lastPracticeDate,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a copy with explicit control over nullable [lastPracticeDate].
  ///
  /// This allows explicitly setting [lastPracticeDate] to null, which cannot
  /// be done with [copyWith] due to Dart's null-coalescing operator behavior.
  UserProfile copyWithNullableDate({
    String? id,
    String? displayName,
    DateTime? Function()? lastPracticeDate,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      lastPracticeDate: lastPracticeDate != null
          ? lastPracticeDate()
          : this.lastPracticeDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          lastPracticeDate == other.lastPracticeDate &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, displayName, lastPracticeDate, createdAt);

  @override
  String toString() {
    return "UserProfile(id: $id, displayName: $displayName, "
        "lastPracticeDate: $lastPracticeDate, createdAt: $createdAt)";
  }
}
