import "package:flutter_test/flutter_test.dart";
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
  @override
  List<int> generateSequence() => [60, 62, 64];
  @override
  List<int> getHighlightedNotes(int currentIndex) => [60 + currentIndex];
  @override
  bool handleNotePressed(int midiNote, int currentIndex) =>
      midiNote == 60 + currentIndex;
  @override
  bool handleNoteReleased(int midiNote, int currentIndex) =>
      midiNote == 60 + currentIndex;
  @override
  PracticeConfiguration get configuration => DummyConfig();
}

void main() {
  test("DummyStrategy basic contract", () {
    final strategy = DummyStrategy();
    expect(strategy.generateSequence(), [60, 62, 64]);
    expect(strategy.getHighlightedNotes(1), [61]);
    expect(strategy.handleNotePressed(61, 1), true);
    expect(strategy.handleNoteReleased(61, 1), true);
    expect(strategy.configuration, isA<PracticeConfiguration>());
  });
}
