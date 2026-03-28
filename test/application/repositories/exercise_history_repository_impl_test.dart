import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/database/app_database.dart";
import "package:piano_fitness/application/repositories/exercise_history_repository_impl.dart";
import "package:piano_fitness/application/repositories/user_profile_repository_impl.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
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
  }) {
    return ExerciseHistoryEntry.fromConfiguration(
      id: id,
      profileId: profileId,
      completedAt: completedAt ?? DateTime(2025, 6, 15, 10),
      config:
          config ??
          ExerciseConfiguration(
            practiceMode: PracticeMode.scales,
            handSelection: HandSelection.both,
            key: music.Key.c,
            scaleType: music.ScaleType.major,
          ),
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

    test("should rethrow on duplicate id", () async {
      final entry = makeEntry(profileId: testProfileId);
      await repository.saveEntry(entry);

      // Inserting the exact same ID again must fail
      await expectLater(repository.saveEntry(entry), throwsA(anything));
    });
  });

  group("ExerciseHistoryRepositoryImpl - getEntriesForProfile", () {
    test("should return empty list for profile with no history", () async {
      final results = await repository.getEntriesForProfile(testProfileId);
      expect(results, isEmpty);
    });

    test("should return only entries for the requested profile", () async {
      // Create a second profile
      SharedPreferences.setMockInitialValues({});
      final prefs2 = await SharedPreferences.getInstance();
      final profileRepo2 = UserProfileRepositoryImpl(
        database: database,
        prefs: prefs2,
      );
      final profile2 = await profileRepo2.createProfile("Other User");

      await repository.saveEntry(makeEntry(id: "e1", profileId: testProfileId));
      await repository.saveEntry(makeEntry(id: "e2", profileId: profile2.id));

      final results = await repository.getEntriesForProfile(testProfileId);
      expect(results.length, equals(1));
      expect(results.first.id, equals("e1"));
    });

    test("should respect the limit parameter", () async {
      for (var i = 1; i <= 5; i++) {
        await repository.saveEntry(
          makeEntry(
            id: "entry-$i",
            profileId: testProfileId,
            completedAt: DateTime(2025, 1, i),
          ),
        );
      }

      final limited = await repository.getEntriesForProfile(
        testProfileId,
        limit: 3,
      );
      expect(limited.length, equals(3));
      // Results must be ordered most-recent-first (completedAt DESC).
      // With entries dated Jan 1..5, limit 3 returns Jan 5, 4, 3.
      expect(limited[0].id, equals("entry-5"));
      expect(limited[1].id, equals("entry-4"));
      expect(limited[2].id, equals("entry-3"));
    });

    test("should return all entries when limit is null", () async {
      for (var i = 1; i <= 4; i++) {
        await repository.saveEntry(
          makeEntry(
            id: "entry-$i",
            profileId: testProfileId,
            completedAt: DateTime(2025, 1, i),
          ),
        );
      }

      final all = await repository.getEntriesForProfile(testProfileId);
      expect(all.length, equals(4));
    });
  });

  group("ExerciseHistoryRepositoryImpl - round-trip serialization", () {
    test("should round-trip practiceMode enum correctly", () async {
      for (final mode in PracticeMode.values) {
        final id = "mode-${mode.name}";
        final config = ExerciseConfiguration(
          practiceMode: mode,
          handSelection: HandSelection.both,
        );
        await repository.saveEntry(
          makeEntry(id: id, profileId: testProfileId, config: config),
        );

        final results = await repository.getEntriesForProfile(testProfileId);
        final found = results.firstWhere((e) => e.id == id);
        expect(found.practiceMode, equals(mode));
      }
    });

    test("should round-trip handSelection enum correctly", () async {
      for (final hand in HandSelection.values) {
        final id = "hand-${hand.name}";
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: hand,
        );
        await repository.saveEntry(
          makeEntry(id: id, profileId: testProfileId, config: config),
        );

        final results = await repository.getEntriesForProfile(testProfileId);
        final found = results.firstWhere((e) => e.id == id);
        expect(found.handSelection, equals(hand));
      }
    });

    test("should round-trip scales configuration with all fields", () async {
      final config = ExerciseConfiguration(
        practiceMode: PracticeMode.scales,
        handSelection: HandSelection.right,
        key: music.Key.f,
        scaleType: music.ScaleType.dorian,
      );
      final original = makeEntry(
        id: "scales-full",
        profileId: testProfileId,
        config: config,
      );
      await repository.saveEntry(original);

      final results = await repository.getEntriesForProfile(testProfileId);
      final restored = results.first;

      expect(restored.practiceMode, equals(PracticeMode.scales));
      expect(restored.handSelection, equals(HandSelection.right));
      expect(restored.musicalKey, equals(music.Key.f));
      expect(restored.scaleType, equals(music.ScaleType.dorian));
    });

    test("should round-trip chordsByType configuration", () async {
      final config = ExerciseConfiguration(
        practiceMode: PracticeMode.chordsByType,
        handSelection: HandSelection.left,
        chordType: ChordType.augmented,
        includeInversions: true,
      );
      await repository.saveEntry(
        makeEntry(id: "chords-type", profileId: testProfileId, config: config),
      );

      final results = await repository.getEntriesForProfile(testProfileId);
      final restored = results.first;

      expect(restored.chordType, equals(ChordType.augmented));
      expect(restored.includeInversions, isTrue);
    });

    test("should round-trip arpeggios configuration", () async {
      final config = ExerciseConfiguration(
        practiceMode: PracticeMode.arpeggios,
        handSelection: HandSelection.both,
        musicalNote: MusicalNote.b,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.two,
      );
      await repository.saveEntry(
        makeEntry(id: "arpeggios", profileId: testProfileId, config: config),
      );

      final results = await repository.getEntriesForProfile(testProfileId);
      final restored = results.first;

      expect(restored.musicalNote, equals(MusicalNote.b));
      expect(restored.arpeggioType, equals(ArpeggioType.major));
      expect(restored.arpeggioOctaves, equals(ArpeggioOctaves.two));
    });

    test("should preserve nullable fields as null when not set", () async {
      final config = ExerciseConfiguration(
        practiceMode: PracticeMode.chordsByType,
        handSelection: HandSelection.both,
        chordType: ChordType.major,
      );
      await repository.saveEntry(
        makeEntry(id: "nullable", profileId: testProfileId, config: config),
      );

      final results = await repository.getEntriesForProfile(testProfileId);
      final restored = results.first;

      expect(restored.musicalKey, isNull);
      expect(restored.scaleType, isNull);
      expect(restored.musicalNote, isNull);
      expect(restored.arpeggioType, isNull);
      // arpeggioOctaves defaults to ArpeggioOctaves.one in ExerciseConfiguration,
      // so the DB always stores "one" (not null) and the mapper returns ArpeggioOctaves.one.
      expect(restored.arpeggioOctaves, equals(ArpeggioOctaves.one));
      expect(restored.chordProgressionId, isNull);
    });

    test("should preserve completedAt timestamp precisely", () async {
      final timestamp = DateTime(2025, 12, 31, 23, 59, 59);
      await repository.saveEntry(
        makeEntry(
          id: "timestamp",
          profileId: testProfileId,
          completedAt: timestamp,
        ),
      );

      final results = await repository.getEntriesForProfile(testProfileId);
      expect(results.first.completedAt, equals(timestamp));
    });
    test(
      "should round-trip chordsByKey with includeSeventhChords: true",
      () async {
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByKey,
          handSelection: HandSelection.both,
          key: music.Key.g,
          scaleType: music.ScaleType.major,
          includeSeventhChords: true,
        );
        await repository.saveEntry(
          makeEntry(
            id: "chords-key-sevenths",
            profileId: testProfileId,
            config: config,
          ),
        );

        final results = await repository.getEntriesForProfile(testProfileId);
        final restored = results.first;

        expect(restored.includeSeventhChords, isTrue);
        expect(restored.musicalKey, equals(music.Key.g));
        expect(restored.scaleType, equals(music.ScaleType.major));
      },
    );

    test(
      "should round-trip chordProgressions with non-null chordProgressionId",
      () async {
        const progressionId = "i_iv_v_i";
        final config = ExerciseConfiguration(
          practiceMode: PracticeMode.chordProgressions,
          handSelection: HandSelection.right,
          key: music.Key.c,
          chordProgressionId: progressionId,
        );
        await repository.saveEntry(
          makeEntry(id: "chord-prog", profileId: testProfileId, config: config),
        );

        final results = await repository.getEntriesForProfile(testProfileId);
        final restored = results.first;

        expect(restored.chordProgressionId, equals(progressionId));
        expect(restored.musicalKey, equals(music.Key.c));
      },
    );
  });
}
