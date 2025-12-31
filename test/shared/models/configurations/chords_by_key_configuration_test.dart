import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_key_configuration.dart";
import "package:piano_fitness/shared/models/music_key.dart";
import "package:piano_fitness/shared/models/scale_type.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";

void main() {
  group("ChordsByKeyConfiguration", () {
    test("validate returns Success for valid config", () {
      final config = ChordsByKeyConfiguration(
        selectedKey: MusicKey.c,
        selectedScaleType: ScaleType.major,
        handSelection: HandSelection.both,
      );
      expect(config.validate().isSuccess, true);
    });
  });
}
