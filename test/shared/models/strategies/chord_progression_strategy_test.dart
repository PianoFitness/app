import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/strategies/chord_progression_strategy.dart";
import "package:piano_fitness/shared/models/configurations/chord_progression_configuration.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/music_key.dart";

void main() {
  test(
    "ChordProgressionStrategy generates a non-empty sequence for C major",
    () {
      final config = ChordProgressionConfiguration(
        selectedKey: MusicKey.c,
        selectedChordProgression:
            null, // Replace with a valid ChordProgression instance if required
        handSelection: HandSelection.right,
      );
      final strategy = ChordProgressionStrategy(config);
      final sequence = strategy.generateSequence();
      expect(sequence.isNotEmpty, true);
    },
  );

  test("ChordProgressionStrategy handles note pressed and released", () {
    final config = ChordProgressionConfiguration(
      selectedKey: MusicKey.c,
      selectedChordProgression:
          null, // Replace with a valid ChordProgression instance if required
      handSelection: HandSelection.right,
    );
    final strategy = ChordProgressionStrategy(config);
    final sequence = strategy.generateSequence();
    if (sequence.isNotEmpty) {
      expect(strategy.handleNotePressed(sequence[0], 0), true);
      expect(strategy.handleNoteReleased(sequence[0], 0), true);
    }
  });
}
