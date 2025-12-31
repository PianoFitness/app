import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/configurations/arpeggio_configuration.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart" as arpeggio_utils;
import "package:piano_fitness/shared/utils/note_utils.dart" as note_utils;
import "package:piano_fitness/shared/models/hand_selection.dart";

void main() {
  group("ArpeggioConfiguration", () {
    test("validate returns Success for valid config", () {
      final config = ArpeggioConfiguration(
        selectedRootNote: note_utils.MusicalNote.c,
        selectedArpeggioType: arpeggio_utils.ArpeggioType.major,
        selectedArpeggioOctaves: arpeggio_utils.ArpeggioOctaves.one,
        handSelection: HandSelection.left,
      );
      expect(config.validate().isSuccess, true);
    });
  });
}
