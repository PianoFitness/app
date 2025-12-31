import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_type_configuration.dart";
import "package:piano_fitness/shared/models/chord_type.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";

void main() {
  group("ChordsByTypeConfiguration", () {
    test("validate returns Success for valid config", () {
      final config = ChordsByTypeConfiguration(
        selectedChordType: ChordType.major,
        includeInversions: true,
        handSelection: HandSelection.right,
      );
      expect(config.validate().isSuccess, true);
    });
  });
}
