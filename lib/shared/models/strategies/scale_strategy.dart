import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/configurations/scale_configuration.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";

// TODO: Replace with actual scale generation logic from music theory utils.
class ScaleStrategy implements PracticeStrategy {
  ScaleStrategy(this.config) {
    // Placeholder: generate a C major scale (MIDI notes for C4-D4-E4-F4-G4-A4-B4-C5)
    _sequence = [60, 62, 64, 65, 67, 69, 71, 72];
  }
  final ScaleConfiguration config;
  late final List<int> _sequence;

  @override
  List<int> generateSequence() => _sequence;

  @override
  List<int> getHighlightedNotes(int currentIndex) {
    if (currentIndex < 0 || currentIndex >= _sequence.length) return [];
    return [_sequence[currentIndex]];
  }

  @override
  bool handleNotePressed(int midiNote, int currentIndex) {
    return currentIndex >= 0 &&
        currentIndex < _sequence.length &&
        midiNote == _sequence[currentIndex];
  }

  @override
  bool handleNoteReleased(int midiNote, int currentIndex) {
    // For scales, releasing the note is not strictly validated.
    return true;
  }

  @override
  PracticeConfiguration get configuration => config;
}
