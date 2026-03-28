import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// An immutable record of a single completed exercise.
///
/// This is a raw event log entry — one row per completion. It stores the full
/// exercise configuration so entries can be filtered by mode, key, chord type,
/// etc. without needing joins. Aggregation (daily stats, streaks, gap
/// detection) is deferred to query time.
///
/// The configuration fields mirror [ExerciseConfiguration] exactly so that the
/// two stay in sync as new modes are added.
@immutable
class ExerciseHistoryEntry {
  const ExerciseHistoryEntry._({
    required this.id,
    required this.profileId,
    required this.completedAt,
    required this.practiceMode,
    required this.handSelection,
    this.musicalKey,
    this.scaleType,
    this.chordType,
    required this.includeInversions,
    required this.includeSeventhChords,
    this.musicalNote,
    this.arpeggioType,
    this.arpeggioOctaves,
    this.chordProgressionId,
  });

  /// Creates an [ExerciseHistoryEntry] from an [ExerciseConfiguration].
  ///
  /// Call this immediately after the user completes an exercise.
  /// [id] must be a unique UUID for this event.
  /// [profileId] is the UUID of the active user profile.
  /// [completedAt] is the wall-clock time the exercise was finished.
  factory ExerciseHistoryEntry.fromConfiguration({
    required String id,
    required String profileId,
    required DateTime completedAt,
    required ExerciseConfiguration config,
  }) {
    return ExerciseHistoryEntry._(
      id: id,
      profileId: profileId,
      completedAt: completedAt,
      practiceMode: config.practiceMode,
      handSelection: config.handSelection,
      musicalKey: config.key,
      scaleType: config.scaleType,
      chordType: config.chordType,
      includeInversions: config.includeInversions,
      includeSeventhChords: config.includeSeventhChords,
      musicalNote: config.musicalNote,
      arpeggioType: config.arpeggioType,
      arpeggioOctaves: config.arpeggioOctaves,
      chordProgressionId: config.chordProgressionId,
    );
  }

  // ── Identity & ownership ─────────────────────────────────────────────────

  /// Unique identifier for this history entry (UUID v4).
  final String id;

  /// The profile that completed the exercise.
  final String profileId;

  /// Wall-clock timestamp when the exercise was completed.
  ///
  /// Stored with full precision to allow grouping by day, week, or month
  /// at query time without losing granularity.
  final DateTime completedAt;

  // ── Exercise configuration (mirrors ExerciseConfiguration fields) ────────

  /// The practice mode that was active when the exercise was completed.
  final PracticeMode practiceMode;

  /// Which hand(s) were used for the exercise.
  final HandSelection handSelection;

  /// The musical key used (scales, chordsByKey, chordProgressions modes).
  /// Null for modes that do not use a key (e.g. chordsByType, arpeggios).
  final music.Key? musicalKey;

  /// The scale type used (scales, chordsByKey modes).
  final music.ScaleType? scaleType;

  /// The chord type used (chordsByType mode).
  final ChordType? chordType;

  /// Whether chord inversions were included (chordsByType mode).
  final bool includeInversions;

  /// Whether seventh chords were included (chordsByKey mode).
  final bool includeSeventhChords;

  /// The root note for arpeggios mode.
  final MusicalNote? musicalNote;

  /// The arpeggio type used (arpeggios mode).
  final ArpeggioType? arpeggioType;

  /// The number of octaves for the arpeggio (arpeggios mode).
  final ArpeggioOctaves? arpeggioOctaves;

  /// The chord progression identifier (chordProgressions mode).
  final String? chordProgressionId;
}
