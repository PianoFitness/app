import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/database/app_database.dart";
import "package:piano_fitness/application/database/daos/user_profile_dao.dart";

void main() {
  group("UserProfileDao", () {
    late AppDatabase db;
    late UserProfileDao dao;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = db.userProfileDao;
    });

    tearDown(() async {
      await db.close();
    });

    group("insertProfile", () {
      test("should insert a new profile", () async {
        const profile = UserProfileTableCompanion(
          id: Value("test-id-1"),
          displayName: Value("Alice"),
        );

        final insertedId = await dao.insertProfile(profile);

        expect(insertedId, isPositive);

        final retrieved = await dao.getProfile("test-id-1");
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals("test-id-1"));
        expect(retrieved.displayName, equals("Alice"));
      });

      test("should insert profile with lastPracticeDate", () async {
        final practiceDate = DateTime(2026, 2);
        final profile = UserProfileTableCompanion(
          id: const Value("test-id-2"),
          displayName: const Value("Bob"),
          lastPracticeDate: Value(practiceDate),
        );

        await dao.insertProfile(profile);

        final retrieved = await dao.getProfile("test-id-2");
        expect(retrieved, isNotNull);
        expect(retrieved!.lastPracticeDate, equals(practiceDate));
      });
    });

    group("getAllProfiles", () {
      test("should return empty list when no profiles exist", () async {
        final profiles = await dao.getAllProfiles();
        expect(profiles, isEmpty);
      });

      test("should return all profiles", () async {
        const profile1 = UserProfileTableCompanion(
          id: Value("id-1"),
          displayName: Value("Alice"),
        );
        const profile2 = UserProfileTableCompanion(
          id: Value("id-2"),
          displayName: Value("Bob"),
        );
        const profile3 = UserProfileTableCompanion(
          id: Value("id-3"),
          displayName: Value("Charlie"),
        );

        await dao.insertProfile(profile1);
        await dao.insertProfile(profile2);
        await dao.insertProfile(profile3);

        final profiles = await dao.getAllProfiles();

        expect(profiles, hasLength(3));
        expect(
          profiles.map((p) => p.displayName),
          containsAll(["Alice", "Bob", "Charlie"]),
        );
      });
    });

    group("getProfilesAlphabetically", () {
      test(
        "should return profiles sorted alphabetically by display name",
        () async {
          const profile1 = UserProfileTableCompanion(
            id: Value("id-1"),
            displayName: Value("Zebra"),
          );
          const profile2 = UserProfileTableCompanion(
            id: Value("id-2"),
            displayName: Value("Apple"),
          );
          const profile3 = UserProfileTableCompanion(
            id: Value("id-3"),
            displayName: Value("Mango"),
          );

          await dao.insertProfile(profile1);
          await dao.insertProfile(profile2);
          await dao.insertProfile(profile3);

          final profiles = await dao.getProfilesAlphabetically();

          expect(profiles, hasLength(3));
          expect(profiles[0].displayName, equals("Apple"));
          expect(profiles[1].displayName, equals("Mango"));
          expect(profiles[2].displayName, equals("Zebra"));
        },
      );

      test("should handle case-insensitive sorting", () async {
        const profile1 = UserProfileTableCompanion(
          id: Value("id-1"),
          displayName: Value("alice"),
        );
        const profile2 = UserProfileTableCompanion(
          id: Value("id-2"),
          displayName: Value("Bob"),
        );

        await dao.insertProfile(profile1);
        await dao.insertProfile(profile2);

        final profiles = await dao.getProfilesAlphabetically();

        expect(profiles, hasLength(2));
        // SQLite default collation is case-insensitive
        expect(profiles[0].displayName, equals("alice"));
        expect(profiles[1].displayName, equals("Bob"));
      });
    });

    group("getProfilesByLastActive", () {
      test(
        "should return profiles sorted by last practice date (most recent first)",
        () async {
          final oldDate = DateTime(2026);
          final middleDate = DateTime(2026, 2);
          final recentDate = DateTime(2026, 3);

          final profile1 = UserProfileTableCompanion(
            id: const Value("id-1"),
            displayName: const Value("Alice"),
            lastPracticeDate: Value(oldDate),
          );
          final profile2 = UserProfileTableCompanion(
            id: const Value("id-2"),
            displayName: const Value("Bob"),
            lastPracticeDate: Value(recentDate),
          );
          final profile3 = UserProfileTableCompanion(
            id: const Value("id-3"),
            displayName: const Value("Charlie"),
            lastPracticeDate: Value(middleDate),
          );

          await dao.insertProfile(profile1);
          await dao.insertProfile(profile2);
          await dao.insertProfile(profile3);

          final profiles = await dao.getProfilesByLastActive();

          expect(profiles, hasLength(3));
          expect(profiles[0].displayName, equals("Bob")); // Most recent
          expect(profiles[1].displayName, equals("Charlie")); // Middle
          expect(profiles[2].displayName, equals("Alice")); // Oldest
        },
      );

      test(
        "should place profiles with null lastPracticeDate at the end",
        () async {
          final recentDate = DateTime(2026, 3);

          final profile1 = UserProfileTableCompanion(
            id: const Value("id-1"),
            displayName: const Value("Alice"),
            lastPracticeDate: Value(recentDate),
          );
          const profile2 = UserProfileTableCompanion(
            id: Value("id-2"),
            displayName: Value("Bob"),
            lastPracticeDate: Value(null), // Never practiced
          );
          const profile3 = UserProfileTableCompanion(
            id: Value("id-3"),
            displayName: Value("Charlie"),
            lastPracticeDate: Value(null), // Never practiced
          );

          await dao.insertProfile(profile1);
          await dao.insertProfile(profile2);
          await dao.insertProfile(profile3);

          final profiles = await dao.getProfilesByLastActive();

          expect(profiles, hasLength(3));
          expect(profiles[0].displayName, equals("Alice")); // Has practice date
          // Bob and Charlie should be last (nulls last)
          expect(
            profiles.sublist(1).map((p) => p.displayName),
            containsAll(["Bob", "Charlie"]),
          );
        },
      );

      test("should handle all profiles with null lastPracticeDate", () async {
        const profile1 = UserProfileTableCompanion(
          id: Value("id-1"),
          displayName: Value("Alice"),
        );
        const profile2 = UserProfileTableCompanion(
          id: Value("id-2"),
          displayName: Value("Bob"),
        );

        await dao.insertProfile(profile1);
        await dao.insertProfile(profile2);

        final profiles = await dao.getProfilesByLastActive();

        expect(profiles, hasLength(2));
        // All have null dates, order not guaranteed
        expect(
          profiles.map((p) => p.displayName),
          containsAll(["Alice", "Bob"]),
        );
      });
    });

    group("getProfile", () {
      test("should return profile by ID", () async {
        const profile = UserProfileTableCompanion(
          id: Value("test-id"),
          displayName: Value("Alice"),
        );

        await dao.insertProfile(profile);

        final retrieved = await dao.getProfile("test-id");

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals("test-id"));
        expect(retrieved.displayName, equals("Alice"));
      });

      test("should return null for non-existent ID", () async {
        final retrieved = await dao.getProfile("non-existent");
        expect(retrieved, isNull);
      });
    });

    group("updateProfile", () {
      test("should update existing profile", () async {
        final createdAt = DateTime(2026);
        final profile = UserProfileTableCompanion(
          id: const Value("test-id"),
          displayName: const Value("Alice"),
          createdAt: Value(createdAt),
        );

        await dao.insertProfile(profile);

        final retrieved = await dao.getProfile("test-id");
        expect(retrieved, isNotNull);

        final updatedProfile = retrieved!.copyWith(
          displayName: "Alice Smith",
          lastPracticeDate: Value(DateTime(2026, 2, 15)),
        );

        final success = await dao.updateProfile(updatedProfile);
        expect(success, isTrue);

        final updated = await dao.getProfile("test-id");
        expect(updated, isNotNull);
        expect(updated!.displayName, equals("Alice Smith"));
        expect(updated.lastPracticeDate, equals(DateTime(2026, 2, 15)));
        expect(updated.createdAt, equals(createdAt)); // Unchanged
      });

      test("should return false for non-existent profile", () async {
        final nonExistent = UserProfileTableData(
          id: "non-existent",
          displayName: "Ghost",
          createdAt: DateTime(2026),
        );

        final success = await dao.updateProfile(nonExistent);
        expect(success, isFalse);
      });
    });

    group("deleteProfile", () {
      test("should delete profile by ID", () async {
        const profile = UserProfileTableCompanion(
          id: Value("test-id"),
          displayName: Value("Alice"),
        );

        await dao.insertProfile(profile);

        final beforeDelete = await dao.getProfile("test-id");
        expect(beforeDelete, isNotNull);

        final deletedCount = await dao.deleteProfile("test-id");
        expect(deletedCount, equals(1));

        final afterDelete = await dao.getProfile("test-id");
        expect(afterDelete, isNull);
      });

      test("should return 0 for non-existent profile", () async {
        final deletedCount = await dao.deleteProfile("non-existent");
        expect(deletedCount, equals(0));
      });

      test("should only delete specified profile", () async {
        const profile1 = UserProfileTableCompanion(
          id: Value("id-1"),
          displayName: Value("Alice"),
        );
        const profile2 = UserProfileTableCompanion(
          id: Value("id-2"),
          displayName: Value("Bob"),
        );

        await dao.insertProfile(profile1);
        await dao.insertProfile(profile2);

        await dao.deleteProfile("id-1");

        final allProfiles = await dao.getAllProfiles();
        expect(allProfiles, hasLength(1));
        expect(allProfiles[0].displayName, equals("Bob"));
      });
    });
  });
}
