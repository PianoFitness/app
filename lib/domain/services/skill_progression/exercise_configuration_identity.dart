import "dart:convert";

import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";

/// Stable comparison identity for a completed exercise configuration.
///
/// It normalises nullable historical defaults so old and new equivalent
/// configurations match without a history migration.
@immutable
class ExerciseConfigurationIdentity {
  const ExerciseConfigurationIdentity._(this.value);

  factory ExerciseConfigurationIdentity.fromConfiguration(
    ExerciseConfiguration configuration,
  ) {
    return ExerciseConfigurationIdentity._(
      _build(
        practiceMode: configuration.practiceMode.name,
        handSelection: configuration.handSelection.name,
        key: configuration.key?.name,
        scaleType: configuration.scaleType?.name,
        chordType: configuration.chordType?.name,
        includeInversions: configuration.includeInversions,
        includeSeventhChords: configuration.includeSeventhChords,
        musicalNote: configuration.musicalNote?.name,
        arpeggioType: configuration.arpeggioType?.name,
        arpeggioOctaves: configuration.arpeggioOctaves.name,
        pattern: configuration.pattern.name,
        includeLeftHandRoot: configuration.includeLeftHandRoot,
        chordProgressionId: configuration.chordProgressionId,
      ),
    );
  }

  factory ExerciseConfigurationIdentity.fromHistory(
    ExerciseHistoryEntry entry,
  ) {
    return ExerciseConfigurationIdentity._(
      _build(
        practiceMode: entry.practiceMode.name,
        handSelection: entry.handSelection.name,
        key: entry.musicalKey?.name,
        scaleType: entry.scaleType?.name,
        chordType: entry.chordType?.name,
        includeInversions: entry.includeInversions,
        includeSeventhChords: entry.includeSeventhChords,
        musicalNote: entry.musicalNote?.name,
        arpeggioType: entry.arpeggioType?.name,
        arpeggioOctaves: (entry.arpeggioOctaves ?? ArpeggioOctaves.one).name,
        pattern: (entry.pattern ?? ChordTonePattern.straight).name,
        includeLeftHandRoot: entry.includeLeftHandRoot,
        chordProgressionId: entry.chordProgressionId,
      ),
    );
  }

  final String value;

  static String _build({
    required String practiceMode,
    required String handSelection,
    required String? key,
    required String? scaleType,
    required String? chordType,
    required bool includeInversions,
    required bool includeSeventhChords,
    required String? musicalNote,
    required String? arpeggioType,
    required String arpeggioOctaves,
    required String pattern,
    required bool includeLeftHandRoot,
    required String? chordProgressionId,
  }) {
    return jsonEncode([
      practiceMode,
      handSelection,
      key,
      scaleType,
      chordType,
      includeInversions,
      includeSeventhChords,
      musicalNote,
      arpeggioType,
      arpeggioOctaves,
      pattern,
      includeLeftHandRoot,
      chordProgressionId,
    ]);
  }

  @override
  bool operator ==(Object other) =>
      other is ExerciseConfigurationIdentity && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
