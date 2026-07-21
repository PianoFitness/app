import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/database/app_database.dart";
import "package:piano_fitness/application/repositories/exercise_history_repository_impl.dart";
import "package:piano_fitness/application/repositories/user_profile_repository_impl.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:shared_preferences/shared_preferences.dart";

void main() {
  late AppDatabase database;
  late ExerciseHistoryRepositoryImpl repository;
  late String testProfileId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final profileRepo = UserProfileRepositoryImpl(
      database: database,
      prefs: prefs,
    );
    final profile = await profileRepo.createProfile("Test User");
    testProfileId = profile.id;

    repository = ExerciseHistoryRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  ExerciseHistoryEntry makeEntry({
    String id = "entry-1",
    required String profileId,
    DateTime? completedAt,
    ExerciseConfiguration? config,
    double? accuracyPercentage,
    int? correctNoteCount,
    int? errorCount,
  }) {
    return ExerciseHistoryEntry.fromConfiguration(
      id: id,
      profileId: profileId,
      completedAt: completedAt ?? DateTime(2025, 6, 15, 10),
      config:
          config ??
          const ExerciseConfiguration(
            practiceMode: PracticeMode.scales,
            handSelection: HandSelection.both,
            key: music.Key.c,
            scaleType: music.ScaleType.major,
          ),
      accuracyPercentage: accuracyPercentage,
      correctNoteCount: correctNoteCount,
      errorCount: errorCount,
    );
  }

  group("ExerciseHistoryRepositoryImpl - saveEntry", () {
    test("should insert an entry without error", () async {
      final entry = makeEntry(profileId: testProfileId);
      await expectLater(repository.saveEntry(entry), completes);
    });

    test("should persist entry retrievable via getEntriesForProfile", () async {
      final entry = makeEntry(profileId: testProfileId);
      await repository.saveEntry(entry);

      final results = await repository.getEntriesForProfile(testProfileId);
      expect(results.length, equals(1));
      expect(results.first.id, equals(entry.id));
    });

    test("should persist and restore accuracy metrics", () async {
      final entry = makeEntry(
        profileId: testProfileId,
        accuracyPercentage: 95.5,
        correctNoteCount: 20,
        errorCount: 1,
      );
      await repository.saveEntry(entry);

      final results = await repository.getEntriesForProfile(testProfileId);
      expect(results.length, equals(1));
      expect(results.first.accuracyPercentage, equals(95.5));
      expect(results.first.correctNoteCount, equals(20));
      expect(results.first.errorCount, equals(1));
    });

    test("should rethrow on duplicate id", () async {
      final entry = makeEntry(profileId: testProfileId);
      await repository.saveEntry(entry);

      await expectLater(repository.saveEntry(entry), throwsA(anything));
    });
  });

  group("ExerciseHistoryRepositoryImpl - watchEntriesForProfile", () {
    test("should emit updated list when new entry is saved", () async {
      await repository.saveEntry(makeEntry(profileId: testProfileId));
      final stream = repository.watchEntriesForProfile(testProfileId);

      expect(await stream.first, hasLength(1));
    });
  });

  group("ExerciseHistoryRepositoryImpl - getEntriesForProfile", () {
    test("should return empty list for profile with no history", () async {
      final results = await repository.getEntriesForProfile(testProfileId);
      expect(results, isEmpty);
    });

    test("should return only entries for the requested profile", () async {
      SharedPreferences.setMockInitialValues({});
      final prefs2 = await SharedPreferences.getInstance();
      final profileRepo2 = UserProfileRepositoryImpl(
        database: database,
        prefs: prefs2,
      );
      final profile2 = await profileRepo2.createProfile("Other User");

      await repository.saveEntry(makeEntry(id: "e1", profileId: testProfileId));
      await repository.saveEntry(makeEntry(id: "e2", profileId: profile2.id));

      final results1 = await repository.getEntriesForProfile(testProfileId);
      expect(results1.length, equals(1));
      expect(results1.first.id, equals("e1"));

      final results2 = await repository.getEntriesForProfile(profile2.id);
      expect(results2.length, equals(1));
      expect(results2.first.id, equals("e2"));
    });

    test("should return entries ordered by completedAt descending", () async {
      final oldEntry = makeEntry(
        id: "old",
        profileId: testProfileId,
        completedAt: DateTime(2025),
      );
      final newEntry = makeEntry(
        id: "new",
        profileId: testProfileId,
        completedAt: DateTime(2025, 6),
      );

      await repository.saveEntry(oldEntry);
      await repository.saveEntry(newEntry);

      final results = await repository.getEntriesForProfile(testProfileId);
      expect(results.map((e) => e.id), equals(["new", "old"]));
    });
  });
}
