import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategies.dart";

/// Factory for creating practice strategies based on exercise configuration.
class ExerciseStrategyFactory {
  static const int defaultStartOctave = MusicalConstants.baseOctave;

  /// Creates the appropriate strategy based on the current practice mode.
  static PracticeStrategy create(ExerciseConfiguration config) {
    switch (config.practiceMode) {
      case PracticeMode.scales:
        return ScalesStrategy(
          key: config.key!,
          scaleType: config.scaleType!,
          handSelection: config.handSelection,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.arpeggios:
        return ArpeggiosStrategy(
          rootNote: config.musicalNote!,
          arpeggioType: config.arpeggioType!,
          arpeggioOctaves: config.arpeggioOctaves,
          handSelection: config.handSelection,
          startOctave: defaultStartOctave,
          pattern: config.pattern,
          includeLeftHandRoot: config.includeLeftHandRoot,
        );
      case PracticeMode.blockChords:
        return BlockChordsStrategy(
          rootNote: config.musicalNote!,
          arpeggioType: config.arpeggioType!,
          arpeggioOctaves: config.arpeggioOctaves,
          handSelection: config.handSelection,
          startOctave: defaultStartOctave,
          pattern: config.pattern,
          includeLeftHandRoot: config.includeLeftHandRoot,
        );
      case PracticeMode.chordsByKey:
        return ChordsByKeyStrategy(
          key: config.key!,
          scaleType: config.scaleType!,
          handSelection: config.handSelection,
          startOctave: defaultStartOctave,
          includeSeventhChords: config.includeSeventhChords,
        );
      case PracticeMode.chordsByType:
        return ChordsByTypeStrategy(
          chordType: config.chordType!,
          includeInversions: config.includeInversions,
          handSelection: config.handSelection,
          startOctave: defaultStartOctave,
        );
      case PracticeMode.chordProgressions:
        // Default to I-V progression if none selected
        final progression = config.chordProgressionId != null
            ? ChordProgressionLibrary.getProgressionByName(
                config.chordProgressionId!,
              )
            : null;

        return ChordProgressionsStrategy(
          key: config.key!,
          chordProgression:
              progression ??
              ChordProgressionLibrary.getProgressionByName("I - V")!,
          handSelection: config.handSelection,
          startOctave: defaultStartOctave,
        );

      case PracticeMode.dominantCadence:
        return DominantCadenceStrategy(
          key: config.key!,
          handSelection: config.handSelection,
          startOctave: defaultStartOctave,
          includeSeventhChords: config.includeSeventhChords,
        );
    }
  }
}
