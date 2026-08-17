import "dart:async";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";

/// ViewModel for the Practice History page.
///
/// Subscribes to the active profile's exercise history entries from
/// [IExerciseHistoryRepository] and exposes them for display. All entries
/// are updated reactively as new exercises are completed, ordered most-recent first.
class HistoryPageViewModel extends ChangeNotifier {
  /// Creates a [HistoryPageViewModel] with the required repository dependencies.
  HistoryPageViewModel({
    required this._userProfileRepository,
    required IExerciseHistoryRepository exerciseHistoryRepository,
  }) : _exerciseHistoryRepository = exerciseHistoryRepository {
    loadEntries();
  }

  static final _log = Logger("HistoryPageViewModel");

  final IUserProfileRepository _userProfileRepository;
  final IExerciseHistoryRepository _exerciseHistoryRepository;

  StreamSubscription<List<ExerciseHistoryEntry>>? _historySubscription;

  List<ExerciseHistoryEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  /// The loaded history entries for the active profile, most-recent first.
  List<ExerciseHistoryEntry> get entries => List.unmodifiable(_entries);

  /// Number of completed practices in the active profile.
  int get totalPracticeCount => _entries.length;

  /// Number of distinct local calendar days containing recorded practice.
  int get practiceDayCount => _entries
      .map((entry) {
        final date = entry.completedAt.toLocal();
        return (date.year, date.month, date.day);
      })
      .toSet()
      .length;

  /// Highest recorded accuracy, hidden when no attempt contains accuracy.
  double? get bestAccuracyPercentage {
    final values = _entries
        .map((entry) => entry.accuracyPercentage)
        .whereType<double>();
    if (values.isEmpty) return null;
    return values.reduce((best, value) => value > best ? value : best);
  }

  /// Whether data fetch/initial load is in progress.
  bool get isLoading => _isLoading;

  /// Non-null when data loading failed; contains a user-facing error message.
  String? get error => _error;

  /// Loads/subscribes to exercise history entries for the active profile.
  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profileId = await _userProfileRepository.getActiveProfileId();
      if (profileId == null) {
        _entries = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _historySubscription?.cancel();
      _historySubscription = _exerciseHistoryRepository
          .watchEntriesForProfile(profileId)
          .listen(
            (entries) {
              _entries = entries;
              _isLoading = false;
              _error = null;
              notifyListeners();
            },
            onError: (Object e, StackTrace stackTrace) {
              _log.severe("Failed to watch exercise history", e, stackTrace);
              _error = "Could not load history. Please try again.";
              _entries = [];
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e, stackTrace) {
      _log.severe("Failed to load active profile for history", e, stackTrace);
      _error = "Could not load history. Please try again.";
      _entries = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }
}
