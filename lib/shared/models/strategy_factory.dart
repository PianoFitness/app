import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
// Import concrete strategies here as they are implemented
import "strategies/scale_strategy.dart";
import "strategies/arpeggio_strategy.dart";
import "configurations/scale_configuration.dart";
import "configurations/arpeggio_configuration.dart";
// ...

/// Factory for creating PracticeStrategy instances from PracticeConfiguration.

class StrategyFactory {
  StrategyFactory()
    : _creators = {
        PracticeMode.scales: (config) =>
            ScaleStrategy(config as ScaleConfiguration),
        PracticeMode.arpeggios: (config) =>
            ArpeggioStrategy(config as ArpeggioConfiguration),
        // Add other strategies here as implemented
      };

  final Map<PracticeMode, PracticeStrategy Function(PracticeConfiguration)>
  _creators;

  PracticeStrategy createStrategy(PracticeConfiguration config) {
    final creator = _creators[config.mode];
    if (creator == null) {
      throw ArgumentError("No strategy registered for mode: \\${config.mode}");
    }
    return creator(config);
  }
}
