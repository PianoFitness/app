import "dart:async";

import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/application/skill_progression/default_skill_catalogue.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_proficiency_snapshot.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_catalogue_validator.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_proficiency_evaluator.dart";

/// Reactively derives technique-tree proficiency from the active profile's
/// existing history stream.
class SkillTreePageViewModel extends ChangeNotifier {
  SkillTreePageViewModel({
    required IUserProfileRepository userProfileRepository,
    required IExerciseHistoryRepository exerciseHistoryRepository,
    SkillCatalogue? catalogue,
  }) : _userProfileRepository = userProfileRepository,
       _exerciseHistoryRepository = exerciseHistoryRepository,
       catalogue = catalogue ?? DefaultSkillCatalogue.catalogue {
    SkillCatalogueValidator.validate(this.catalogue);
    loadProgress();
  }

  static final _log = Logger("SkillTreePageViewModel");

  final IUserProfileRepository _userProfileRepository;
  final IExerciseHistoryRepository _exerciseHistoryRepository;
  final SkillCatalogue catalogue;
  StreamSubscription<List<ExerciseHistoryEntry>>? _historySubscription;

  List<SkillNodeProficiency> _nodeProficiencies = const [];
  bool _isLoading = true;
  String? _error;

  List<SkillNodeProficiency> get nodeProficiencies =>
      List.unmodifiable(_nodeProficiencies);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Begins watching the active profile's history and recomputes on every
  /// completion, including repetitions made while the tree remains below the
  /// existing Practice Page route.
  Future<void> loadProgress() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profileId = await _userProfileRepository.getActiveProfileId();
      if (profileId == null) {
        _setEntries(const []);
        return;
      }
      await _historySubscription?.cancel();
      _historySubscription = _exerciseHistoryRepository
          .watchEntriesForProfile(profileId)
          .listen(
            _setEntries,
            onError: (Object error, StackTrace stackTrace) {
              _log.severe("Failed to watch skill progress", error, stackTrace);
              _nodeProficiencies = const [];
              _error = "Could not load progress. Please try again.";
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (error, stackTrace) {
      _log.severe(
        "Failed to load active profile for skill progress",
        error,
        stackTrace,
      );
      _nodeProficiencies = const [];
      _error = "Could not load progress. Please try again.";
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setEntries(List<ExerciseHistoryEntry> entries) {
    _nodeProficiencies = catalogue.nodes
        .map((node) => SkillProficiencyEvaluator.evaluateNode(node, entries))
        .toList(growable: false);
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }
}
