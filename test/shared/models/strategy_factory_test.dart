import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/strategy_factory.dart";
import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";

class DummyConfig implements PracticeConfiguration {
  @override
  final mode = PracticeMode.scales;
  @override
  final handSelection = HandSelection.right;
  @override
  validate() => throw UnimplementedError();
}

class DummyStrategy implements PracticeStrategy {
  DummyStrategy(this.config);
  final PracticeConfiguration config;
  @override
  List<int> generateSequence() => [60];
  @override
  List<int> getHighlightedNotes(int currentIndex) => [60];
  @override
  bool handleNotePressed(int midiNote, int currentIndex) => true;
  @override
  bool handleNoteReleased(int midiNote, int currentIndex) => true;
  @override
  PracticeConfiguration get configuration => config;
}

void main() {
  test("StrategyFactory returns correct strategy", () {
    final factory = StrategyFactory();
    final config = DummyConfig();
    final strategy = factory.createStrategy(config);
    expect(strategy, isA<DummyStrategy>());
    expect(strategy.configuration, config);
  });

  test("StrategyFactory throws for unregistered mode", () {
    final factory = StrategyFactory();
    final config = DummyConfig();
    expect(() => factory.createStrategy(config), throwsArgumentError);
  });
}
