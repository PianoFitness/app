import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/strategies/chords_by_type_strategy.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_type_configuration.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/chord_type.dart"
    as model_chord_type;

void main() {
  test(
    "ChordsByTypeStrategy generates correct sequence for Major chords with inversions",
    () {
      final config = ChordsByTypeConfiguration(
        selectedChordType: model_chord_type.ChordType.major,
        includeInversions: true,
        handSelection: HandSelection.right,
      );
      final strategy = ChordsByTypeStrategy(config);
      final sequence = strategy.generateSequence();
      // Should contain at least the C major triad (C4, E4, G4)
      expect(sequence.contains(60), true); // C4
      expect(sequence.contains(64), true); // E4
      expect(sequence.contains(67), true); // G4
    },
  );

  test("ChordsByTypeStrategy handles note pressed and released", () {
    final config = ChordsByTypeConfiguration(
      selectedChordType: model_chord_type.ChordType.minor,
      includeInversions: false,
      handSelection: HandSelection.right,
    );
    final strategy = ChordsByTypeStrategy(config);
    final sequence = strategy.generateSequence();
    if (sequence.isNotEmpty) {
      expect(strategy.handleNotePressed(sequence[0], 0), true);
      expect(strategy.handleNoteReleased(sequence[0], 0), true);
    }
  });
}
