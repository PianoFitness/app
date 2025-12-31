import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/configurations/chord_progression_configuration.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/music_key.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";

class DummyProgression extends ChordProgression {
  DummyProgression()
    : super(
        name: "Dummy",
        romanNumerals: const [],
        chords: const [],
        difficulty: ProgressionDifficulty.beginner,
      );
}

void main() {
  group("ChordProgressionConfiguration", () {
    test("validate returns Success for valid config", () {
      final config = ChordProgressionConfiguration(
        selectedChordProgression: DummyProgression(),
        selectedKey: MusicKey.c,
        handSelection: HandSelection.left,
      );
      expect(config.validate().isSuccess, true);
    });

    test("validate returns Success for null progression (allowed)", () {
      final config = ChordProgressionConfiguration(
        selectedChordProgression: null,
        selectedKey: MusicKey.c,
        handSelection: HandSelection.left,
      );
      expect(config.validate().isSuccess, true);
    });
  });
}
