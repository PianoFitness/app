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
    required IUserProfileRepository userProfileRepository,
    required IExerciseHistoryRepository exerciseHistoryRepository,
  }) : _userProfileRepository = userProfileRepository,
       _exerciseHistoryRepository = exerciseHistoryRepository {
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
