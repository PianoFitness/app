import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/database/app_database.dart";
import "package:piano_fitness/application/repositories/user_profile_repository_impl.dart";
import "package:piano_fitness/domain/models/profile_sort_order.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  late AppDatabase database;
  late UserProfileRepositoryImpl repository;

  setUp(() async {
    // Use in-memory database for tests
    database = AppDatabase(NativeDatabase.memory());

    // Initialize SharedPreferences with test values
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    repository = UserProfileRepositoryImpl(database: database, prefs: prefs);
  });

  tearDown(() async {
    await database.close();
  });

  group("UserProfileRepositoryImpl - CRUD operations", () {
    test("getAllProfiles returns empty list initially", () async {
      final profiles = await repository.getAllProfiles();
      expect(profiles, isEmpty);
    });

    test("createProfile creates and returns new profile", () async {
      final profile = await repository.createProfile("John");

      expect(profile.id, isNotEmpty);
      expect(profile.displayName, "John");
      expect(profile.lastPracticeDate, isNull);
      expect(profile.createdAt, isNotNull);
    });

    test("createProfile validates display name", () async {
      expect(() => repository.createProfile(""), throwsA(isA<ArgumentError>()));

      expect(
        () => repository.createProfile("a" * 31),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("getProfile retrieves profile by ID", () async {
      final created = await repository.createProfile("Jane");
      final retrieved = await repository.getProfile(created.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, created.id);
      expect(retrieved.displayName, "Jane");
    });

    test("getProfile returns null for non-existent ID", () async {
      final profile = await repository.getProfile("non-existent");
      expect(profile, isNull);
    });

    test("getAllProfiles returns all created profiles", () async {
      await repository.createProfile("Alice");
      await repository.createProfile("Bob");
      await repository.createProfile("Charlie");

      final profiles = await repository.getAllProfiles();
      expect(profiles.length, 3);

      final names = profiles.map((p) => p.displayName).toList();
      expect(names, containsAll(["Alice", "Bob", "Charlie"]));
    });

    test("updateProfile updates display name", () async {
      final original = await repository.createProfile("John");
      final updated = original.copyWith(displayName: "Johnny");

      await repository.updateProfile(updated);

      final retrieved = await repository.getProfile(original.id);
      expect(retrieved!.displayName, "Johnny");
    });

    test("updateProfile updates lastPracticeDate", () async {
      final original = await repository.createProfile("John");
      final lastPractice = DateTime(2026, 3);
      final updated = original.copyWith(lastPracticeDate: lastPractice);

      await repository.updateProfile(updated);

      final retrieved = await repository.getProfile(original.id);
      expect(retrieved!.lastPracticeDate, lastPractice);
    });

    test("deleteProfile removes profile", () async {
      final profile = await repository.createProfile("John");
      await repository.deleteProfile(profile.id);

      final retrieved = await repository.getProfile(profile.id);
      expect(retrieved, isNull);
    });

    test("deleteProfile removes from list", () async {
      final profile1 = await repository.createProfile("Alice");
      final profile2 = await repository.createProfile("Bob");

      await repository.deleteProfile(profile1.id);

      final profiles = await repository.getAllProfiles();
      expect(profiles.length, 1);
      expect(profiles.first.id, profile2.id);
    });
  });

  group("UserProfileRepositoryImpl - Active Profile", () {
    test("getActiveProfileId returns null initially", () async {
      final activeId = await repository.getActiveProfileId();
      expect(activeId, isNull);
    });

    test("setActiveProfileId stores profile ID", () async {
      await repository.setActiveProfileId("test-id");
      final activeId = await repository.getActiveProfileId();
      expect(activeId, "test-id");
    });

    test("deleteProfile clears active profile ID if deleted", () async {
      final profile = await repository.createProfile("John");
      await repository.setActiveProfileId(profile.id);

      await repository.deleteProfile(profile.id);

      final activeId = await repository.getActiveProfileId();
      expect(activeId, isNull);
    });

    test("deleteProfile does not clear different active profile ID", () async {
      final profile1 = await repository.createProfile("Alice");
      final profile2 = await repository.createProfile("Bob");

      await repository.setActiveProfileId(profile2.id);
      await repository.deleteProfile(profile1.id);

      final activeId = await repository.getActiveProfileId();
      expect(activeId, profile2.id);
    });
  });

  group("UserProfileRepositoryImpl - Sort Order", () {
    test("getSortOrder returns lastActive by default", () async {
      final sortOrder = await repository.getSortOrder();
      expect(sortOrder, ProfileSortOrder.lastActive);
    });

    test("setSortOrder stores and retrieves alphabetical", () async {
      await repository.setSortOrder(ProfileSortOrder.alphabetical);
      final sortOrder = await repository.getSortOrder();
      expect(sortOrder, ProfileSortOrder.alphabetical);
    });

    test("setSortOrder stores and retrieves lastActive", () async {
      await repository.setSortOrder(ProfileSortOrder.lastActive);
      final sortOrder = await repository.getSortOrder();
      expect(sortOrder, ProfileSortOrder.lastActive);
    });

    test("setSortOrder persists across repository instances", () async {
      await repository.setSortOrder(ProfileSortOrder.alphabetical);

      // Create new repository instance with same prefs
      final prefs = await SharedPreferences.getInstance();
      final newRepository = UserProfileRepositoryImpl(
        database: database,
        prefs: prefs,
      );

      final sortOrder = await newRepository.getSortOrder();
      expect(sortOrder, ProfileSortOrder.alphabetical);
    });
  });
}
