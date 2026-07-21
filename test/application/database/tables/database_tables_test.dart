import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/database/app_database.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Database Tables Tests", () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test("UserProfileTable data structure is active in database", () async {
      final profiles = await db.userProfileDao.getAllProfiles();
      expect(profiles, isEmpty);
    });

    test("ExerciseHistoryTable data structure is active in database", () async {
      final history = await db.exerciseHistoryDao.getEntriesForProfile(
        "test_profile",
      );
      expect(history, isEmpty);
    });

    test("AppDatabase allTables contains schema definitions", () {
      expect(db.allTables, isNotEmpty);
      expect(db.allTables.length, greaterThanOrEqualTo(2));
    });
  });
}
