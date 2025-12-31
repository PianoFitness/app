import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/strategies/arpeggio_strategy.dart";
import "package:piano_fitness/shared/models/configurations/arpeggio_configuration.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart" as arpeggio_utils;
import "package:piano_fitness/shared/utils/note_utils.dart" as note_utils;

void main() {
  group("ArpeggioStrategy", () {
    test("generates correct sequence for right hand, C major, 1 octave", () {
      final config = ArpeggioConfiguration(
        selectedRootNote: note_utils.MusicalNote.c,
        selectedArpeggioType: arpeggio_utils.ArpeggioType.major,
        selectedArpeggioOctaves: arpeggio_utils.ArpeggioOctaves.one,
        handSelection: HandSelection.right,
      );
      final strategy = ArpeggioStrategy(config);
      final sequence = strategy.generateSequence();
      // C major arpeggio, 1 octave, right hand, starting at C4 (MIDI 60)
      // Up: C4 E4 G4 C5 (60, 64, 67, 72), Down: G4 E4 C4 (67, 64, 60)
      expect(sequence, <int>[60, 64, 67, 72, 67, 64, 60]);
    });

    test("getHighlightedNotes returns correct note for right hand", () {
      final config = ArpeggioConfiguration(
        selectedRootNote: note_utils.MusicalNote.c,
        selectedArpeggioType: arpeggio_utils.ArpeggioType.major,
        selectedArpeggioOctaves: arpeggio_utils.ArpeggioOctaves.one,
        handSelection: HandSelection.right,
      );
      final strategy = ArpeggioStrategy(config);
      expect(strategy.getHighlightedNotes(0), <int>[60]);
      expect(strategy.getHighlightedNotes(3), <int>[72]);
      expect(strategy.getHighlightedNotes(10), <int>[]); // out of range
    });

    test("handleNotePressed returns true for correct note", () {
      final config = ArpeggioConfiguration(
        selectedRootNote: note_utils.MusicalNote.c,
        selectedArpeggioType: arpeggio_utils.ArpeggioType.major,
        selectedArpeggioOctaves: arpeggio_utils.ArpeggioOctaves.one,
        handSelection: HandSelection.right,
      );
      final strategy = ArpeggioStrategy(config);
      expect(strategy.handleNotePressed(60, 0), true);
      expect(strategy.handleNotePressed(64, 1), true);
      expect(strategy.handleNotePressed(61, 1), false);
    });

    test("generates correct sequence for both hands", () {
      final config = ArpeggioConfiguration(
        selectedRootNote: note_utils.MusicalNote.c,
        selectedArpeggioType: arpeggio_utils.ArpeggioType.major,
        selectedArpeggioOctaves: arpeggio_utils.ArpeggioOctaves.one,
        handSelection: HandSelection.both,
      );
      final strategy = ArpeggioStrategy(config);
      final sequence = strategy.generateSequence();
      // Both hands: left hand at octave 3, right hand at 4
      // Interleaved: [L1, R1, L2, R2, ...]
      expect(sequence.length % 2, 0);
      // Check first pair: C3 (48), C4 (60)
      expect(sequence[0], 48);
      expect(sequence[1], 60);
    });
  });
}
