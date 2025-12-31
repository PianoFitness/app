import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/configurations/arpeggio_configuration.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart" as arpeggio_utils;
import "package:piano_fitness/shared/models/hand_selection.dart";

/// Concrete strategy for arpeggio practice mode.
class ArpeggioStrategy implements PracticeStrategy {
  ArpeggioStrategy(this.config) {
    // Use the ArpeggioDefinitions utility to generate the sequence.
    final arpeggio = arpeggio_utils.ArpeggioDefinitions.getArpeggio(
      config.selectedRootNote,
      config.selectedArpeggioType,
      config.selectedArpeggioOctaves,
    );
    // Start at octave 4 for right hand, 3 for left, 4 for both (right hand at 4, left at 3)
    // This is a convention; can be parameterized if needed.
    final startOctave = 4;
    _sequence = arpeggio.getHandSequence(startOctave, config.handSelection);
  }
  final ArpeggioConfiguration config;
  late final List<int> _sequence;

  @override
  List<int> generateSequence() => _sequence;

  @override
  List<int> getHighlightedNotes(int currentIndex) {
    if (currentIndex < 0 || currentIndex >= _sequence.length) return [];
    // For both hands, notes are paired: [L1, R1, L2, R2, ...]
    if (config.handSelection == HandSelection.both) {
      // Each step is a pair: even index = left, odd = right
      if (currentIndex % 2 == 0 && currentIndex + 1 < _sequence.length) {
        return [_sequence[currentIndex], _sequence[currentIndex + 1]];
      }
      return [];
    }
    return [_sequence[currentIndex]];
  }

  @override
  bool handleNotePressed(int midiNote, int currentIndex) {
    if (currentIndex < 0 || currentIndex >= _sequence.length) return false;
    if (config.handSelection == HandSelection.both) {
      // Both hands: expect two notes at each step (even index)
      if (currentIndex % 2 == 0 && currentIndex + 1 < _sequence.length) {
        return midiNote == _sequence[currentIndex] ||
            midiNote == _sequence[currentIndex + 1];
      }
      return false;
    }
    return midiNote == _sequence[currentIndex];
  }

  @override
  bool handleNoteReleased(int midiNote, int currentIndex) {
    // For arpeggios, releasing the note is not strictly validated.
    return true;
  }

  @override
  PracticeConfiguration get configuration => config;
}
