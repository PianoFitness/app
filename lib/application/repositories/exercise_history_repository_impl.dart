import "package:drift/drift.dart";
import "package:logging/logging.dart";

import "../../domain/models/music/hand_selection.dart";
import "../../domain/models/music/scale_types.dart" as music;
import "../../domain/models/practice/exercise_configuration.dart";
import "../../domain/models/practice/exercise_history_entry.dart";
import "../../domain/models/practice/practice_mode.dart";
import "../../domain/repositories/exercise_history_repository.dart";
import "../../domain/services/music_theory/arpeggios.dart";
import "../../domain/services/music_theory/chord_definitions.dart";
import "../../domain/services/music_theory/note_utils.dart";
import "../database/app_database.dart";

/// Drift-backed implementation of [IExerciseHistoryRepository].
///
/// Enum fields are round-tripped as their `.name` strings so that database
/// content remains human-readable and is not coupled to Dart ordinal values.
class ExerciseHistoryRepositoryImpl implements IExerciseHistoryRepository {
  /// Creates the repository backed by the given [database].
  ExerciseHistoryRepositoryImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;
  final Logger _logger = Logger("ExerciseHistoryRepositoryImpl");

  @override
  Future<void> saveEntry(ExerciseHistoryEntry entry) async {
    try {
      final companion = ExerciseHistoryTableCompanion.insert(
        id: entry.id,
        profileId: entry.profileId,
        completedAt: entry.completedAt,
        practiceMode: entry.practiceMode.name,
        handSelection: entry.handSelection.name,
        musicalKey: Value(entry.musicalKey?.name),
        scaleType: Value(entry.scaleType?.name),
        chordType: Value(entry.chordType?.name),
        includeInversions: Value(entry.includeInversions),
        includeSeventhChords: Value(entry.includeSeventhChords),
        musicalNote: Value(entry.musicalNote?.name),
        arpeggioType: Value(entry.arpeggioType?.name),
        arpeggioOctaves: Value(entry.arpeggioOctaves?.name),
        chordProgressionId: Value(entry.chordProgressionId),
      );

      await _database.exerciseHistoryDao.insertEntry(companion);
    } catch (e, stackTrace) {
      _logger.severe("Error saving exercise history entry", e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<ExerciseHistoryEntry>> getEntriesForProfile(
    String profileId, {
    int? limit,
  }) async {
    try {
      final rows = await _database.exerciseHistoryDao.getEntriesForProfile(
        profileId,
        limit: limit,
      );
      return rows.map(_toDomainModel).toList();
    } catch (e, stackTrace) {
      _logger.severe("Error loading exercise history entries", e, stackTrace);
      rethrow;
    }
  }

  // ── Mapping helpers ───────────────────────────────────────────────────────

  /// Converts a database row back to the domain model.
  ///
  /// Reconstructs an [ExerciseConfiguration] from the stored enum name strings
  /// and then delegates to the canonical factory constructor so all fields are
  /// set consistently.
  ExerciseHistoryEntry _toDomainModel(ExerciseHistoryTableData row) {
    final config = ExerciseConfiguration(
      practiceMode: PracticeMode.values.byName(row.practiceMode),
      handSelection: HandSelection.values.byName(row.handSelection),
      key: row.musicalKey != null
          ? music.Key.values.byName(row.musicalKey!)
          : null,
      scaleType: row.scaleType != null
          ? music.ScaleType.values.byName(row.scaleType!)
          : null,
      chordType: row.chordType != null
          ? ChordType.values.byName(row.chordType!)
          : null,
      includeInversions: row.includeInversions,
      includeSeventhChords: row.includeSeventhChords,
      musicalNote: row.musicalNote != null
          ? MusicalNote.values.byName(row.musicalNote!)
          : null,
      arpeggioType: row.arpeggioType != null
          ? ArpeggioType.values.byName(row.arpeggioType!)
          : null,
      // arpeggioOctaves is non-nullable in ExerciseConfiguration (defaults to
      // ArpeggioOctaves.one), so null is never written to this column through
      // the normal save path. The fallback is kept for defensive correctness.
      arpeggioOctaves: row.arpeggioOctaves != null
          ? ArpeggioOctaves.values.byName(row.arpeggioOctaves!)
          : ArpeggioOctaves.one,
      chordProgressionId: row.chordProgressionId,
    );

    return ExerciseHistoryEntry.fromConfiguration(
      id: row.id,
      profileId: row.profileId,
      completedAt: row.completedAt,
      config: config,
    );
  }
}
