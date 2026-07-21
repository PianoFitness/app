import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/presentation/features/history/history_page_view_model.dart";

import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("HistoryPageViewModel", () {
    late MockIUserProfileRepository mockUserProfileRepository;
    late MockIExerciseHistoryRepository mockExerciseHistoryRepository;

    setUp(() {
      mockUserProfileRepository = MockIUserProfileRepository();
      mockExerciseHistoryRepository = MockIExerciseHistoryRepository();
    });

    HistoryPageViewModel makeViewModel() => HistoryPageViewModel(
      userProfileRepository: mockUserProfileRepository,
      exerciseHistoryRepository: mockExerciseHistoryRepository,
    );

    ExerciseHistoryEntry makeEntry(String id, {double? accuracyPercentage}) =>
        ExerciseHistoryEntry.fromConfiguration(
          id: id,
          profileId: "profile-1",
          completedAt: DateTime(2026, 3, 29, 10),
          config: const ExerciseConfiguration(
            practiceMode: PracticeMode.scales,
            handSelection: HandSelection.both,
            key: music.Key.c,
            scaleType: music.ScaleType.major,
          ),
          accuracyPercentage: accuracyPercentage,
        );

    test("starts in loading state", () {
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) => Future.delayed(const Duration(hours: 1)));

      final vm = makeViewModel();

      expect(vm.isLoading, isTrue);
      expect(vm.entries, isEmpty);
      expect(vm.error, isNull);

      vm.dispose();
    });

    test(
      "loads entries for active profile and updates reactively on stream events",
      () async {
        final streamController = StreamController<List<ExerciseHistoryEntry>>();
        addTearDown(streamController.close);

        when(
          mockUserProfileRepository.getActiveProfileId(),
        ).thenAnswer((_) async => "profile-1");
        when(
          mockExerciseHistoryRepository.watchEntriesForProfile("profile-1"),
        ).thenAnswer((_) => streamController.stream);

        final vm = makeViewModel();
        await Future<void>.delayed(Duration.zero);

        final initialEntry = makeEntry("e1", accuracyPercentage: 90.0);
        streamController.add([initialEntry]);
        await Future<void>.delayed(Duration.zero);

        expect(vm.isLoading, isFalse);
        expect(vm.error, isNull);
        expect(vm.entries, hasLength(1));
        expect(vm.entries.first.accuracyPercentage, equals(90.0));

        final newEntry = makeEntry("e2", accuracyPercentage: 100.0);
        streamController.add([newEntry, initialEntry]);
        await Future<void>.delayed(Duration.zero);

        expect(vm.entries, hasLength(2));
        expect(vm.entries.first.id, equals("e2"));
        expect(vm.entries.first.accuracyPercentage, equals(100.0));

        vm.dispose();
      },
    );

    test("shows empty entries when no active profile", () async {
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => null);

      final vm = makeViewModel();
      await Future<void>.delayed(Duration.zero);

      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.entries, isEmpty);

      vm.dispose();
    });

    test("sets error message when repository stream throws", () async {
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => "profile-1");
      when(
        mockExerciseHistoryRepository.watchEntriesForProfile("profile-1"),
      ).thenAnswer((_) => Stream.error(Exception("DB error")));

      final vm = makeViewModel();
      await Future<void>.delayed(Duration.zero);

      expect(vm.isLoading, isFalse);
      expect(vm.error, isNotNull);
      expect(vm.entries, isEmpty);

      vm.dispose();
    });

    test("entries list is unmodifiable", () async {
      final streamController = StreamController<List<ExerciseHistoryEntry>>();
      addTearDown(streamController.close);

      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => "profile-1");
      when(
        mockExerciseHistoryRepository.watchEntriesForProfile("profile-1"),
      ).thenAnswer((_) => streamController.stream);

      final vm = makeViewModel();
      streamController.add([makeEntry("e1")]);
      await Future<void>.delayed(Duration.zero);

      expect(
        () => vm.entries.add(makeEntry("e-rogue")),
        throwsUnsupportedError,
      );

      vm.dispose();
    });
  });
}
