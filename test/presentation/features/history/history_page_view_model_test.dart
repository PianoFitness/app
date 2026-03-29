import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
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

    ExerciseHistoryEntry makeEntry(String id) =>
        ExerciseHistoryEntry.fromConfiguration(
          id: id,
          profileId: "profile-1",
          completedAt: DateTime(2026, 3, 29, 10),
          config: ExerciseConfiguration(
            practiceMode: PracticeMode.scales,
            handSelection: HandSelection.both,
            key: music.Key.c,
            scaleType: music.ScaleType.major,
          ),
        );

    test("starts in loading state", () {
      // Arrange: never-completing futures
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) => Future.delayed(const Duration(hours: 1)));

      // Act
      final vm = makeViewModel();

      // Assert: isLoading immediately
      expect(vm.isLoading, isTrue);
      expect(vm.entries, isEmpty);
      expect(vm.error, isNull);

      vm.dispose();
    });

    test("loads entries for active profile", () async {
      // Arrange
      final entries = [makeEntry("e1"), makeEntry("e2")];
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => "profile-1");
      when(
        mockExerciseHistoryRepository.getEntriesForProfile("profile-1"),
      ).thenAnswer((_) async => entries);

      // Act
      final vm = makeViewModel();
      await Future<void>.delayed(Duration.zero); // let async loading complete

      // Assert
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.entries, hasLength(2));
      expect(vm.entries.first.id, "e1");
    });

    test("shows empty entries when no active profile", () async {
      // Arrange
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => null);

      // Act
      final vm = makeViewModel();
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.entries, isEmpty);
    });

    test("shows empty entries when profile has no history", () async {
      // Arrange
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => "profile-1");
      when(
        mockExerciseHistoryRepository.getEntriesForProfile("profile-1"),
      ).thenAnswer((_) async => []);

      // Act
      final vm = makeViewModel();
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNull);
      expect(vm.entries, isEmpty);
    });

    test("sets error message when repository throws", () async {
      // Arrange
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => "profile-1");
      when(
        mockExerciseHistoryRepository.getEntriesForProfile("profile-1"),
      ).thenThrow(Exception("DB error"));

      // Act
      final vm = makeViewModel();
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(vm.isLoading, isFalse);
      expect(vm.error, isNotNull);
      expect(vm.entries, isEmpty);
    });

    test("entries list is unmodifiable", () async {
      // Arrange
      when(
        mockUserProfileRepository.getActiveProfileId(),
      ).thenAnswer((_) async => "profile-1");
      when(
        mockExerciseHistoryRepository.getEntriesForProfile("profile-1"),
      ).thenAnswer((_) async => [makeEntry("e1")]);

      // Act
      final vm = makeViewModel();
      await Future.microtask(() {});

      // Assert: mutating the returned list does not affect the ViewModel
      expect(
        () => vm.entries.add(makeEntry("e-rogue")),
        throwsUnsupportedError,
      );
    });
  });
}
