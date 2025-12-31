import "strategies/chord_progression_strategy.dart";
import "configurations/chord_progression_configuration.dart";
import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
// Import concrete strategies here as they are implemented
import "strategies/scale_strategy.dart";
import "strategies/arpeggio_strategy.dart";
import "configurations/scale_configuration.dart";
import "configurations/arpeggio_configuration.dart";
import "strategies/chords_by_key_strategy.dart";
import "configurations/chords_by_key_configuration.dart";
import "strategies/chords_by_type_strategy.dart";
import "configurations/chords_by_type_configuration.dart";

/// Factory for creating PracticeStrategy instances from PracticeConfiguration.

class StrategyFactory {
  StrategyFactory()
    : _creators = {
        PracticeMode.scales: (config) =>
            ScaleStrategy(config as ScaleConfiguration),
        PracticeMode.arpeggios: (config) =>
            ArpeggioStrategy(config as ArpeggioConfiguration),
        // Add other strategies here as implemented
        PracticeMode.chordsByKey: (config) =>
            ChordsByKeyStrategy(config as ChordsByKeyConfiguration),
        PracticeMode.chordsByType: (config) =>
            ChordsByTypeStrategy(config as ChordsByTypeConfiguration),
        PracticeMode.chordProgressions: (config) =>
            ChordProgressionStrategy(config as ChordProgressionConfiguration),
      };

  final Map<PracticeMode, PracticeStrategy Function(PracticeConfiguration)>
  _creators;

  PracticeStrategy createStrategy(PracticeConfiguration config) {
    final creator = _creators[config.mode];
    if (creator == null) {
      throw ArgumentError("No strategy registered for mode: ${config.mode}");
    }
    return creator(config);
  }

  /// Allows tests to register custom strategies for a given mode.
  void register(
    PracticeMode mode,
    PracticeStrategy Function(PracticeConfiguration) creator,
  ) {
    _creators[mode] = creator;
  }
}
