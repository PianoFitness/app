import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/configurations/arpeggio_configuration.dart";
import "package:piano_fitness/shared/models/musical_note.dart";
import "package:piano_fitness/shared/models/arpeggio_type.dart";
import "package:piano_fitness/shared/models/arpeggio_octaves.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";

void main() {
  group("ArpeggioConfiguration", () {
    test("validate returns Success for valid config", () {
      final config = ArpeggioConfiguration(
        selectedRootNote: MusicalNote.c,
        selectedArpeggioType: ArpeggioType.major,
        selectedArpeggioOctaves: ArpeggioOctaves.one,
        handSelection: HandSelection.left,
      );
      expect(config.validate().isSuccess, true);
    });
  });
}
