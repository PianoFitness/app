import "package:piano_fitness/shared/models/scale_type.dart"
    as model_scale_type;
import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/configurations/chord_progression_configuration.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/utils/chords.dart" as chords_utils;

/// Concrete strategy for chord progression practice mode.
class ChordProgressionStrategy implements PracticeStrategy {
  ChordProgressionStrategy(this.config) {
    // Use the chord progression utilities to generate the sequence for the selected progression type and key.
    // This is a placeholder; replace with actual progression logic as needed.
    final theoryKey = chords_utils.musicKeyToTheoryKey(config.selectedKey);
    // Fallback: always use major scale type until ChordProgression has scaleType
    final theoryScaleType = chords_utils.modelScaleTypeToTheoryScaleType(
      model_scale_type.ScaleType.major,
    );
    // TODO: Use config.selectedChordProgression for more advanced progressions
    final chords = chords_utils.getChordsByKey(theoryKey, theoryScaleType);
    _sequence = chords.expand((chord) => chord.getMidiNotes(4)).toList();
  }
  final ChordProgressionConfiguration config;
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
    // For chords, releasing the note is not strictly validated.
    return true;
  }

  @override
  PracticeConfiguration get configuration => config;
}
