import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
// Import concrete strategies here as they are implemented
// import 'strategies/scale_strategy.dart';
// import 'strategies/arpeggio_strategy.dart';
// ...

/// Factory for creating PracticeStrategy instances from PracticeConfiguration.
class StrategyFactory {
  StrategyFactory(this._creators);
  final Map<PracticeMode, PracticeStrategy Function(PracticeConfiguration)>
  _creators;

  PracticeStrategy createStrategy(PracticeConfiguration config) {
    final creator = _creators[config.mode];
    if (creator == null) {
      throw ArgumentError("No strategy registered for mode: ${config.mode}");
    }
    return creator(config);
  }
}
