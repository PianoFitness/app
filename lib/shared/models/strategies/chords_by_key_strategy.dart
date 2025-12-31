import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_key_configuration.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/utils/chords.dart" as chords_utils;
import "package:piano_fitness/shared/utils/scales.dart" as scales_utils;

/// Concrete strategy for chords by key practice mode.
class ChordsByKeyStrategy implements PracticeStrategy {
  ChordsByKeyStrategy(this.config) {
    // Use the chords_utils to generate the chord sequence for the selected key and scale type.
    // This is placeholder logic; replace with actual chord generation.
    final theoryKey = chords_utils.musicKeyToTheoryKey(config.selectedKey);
    final theoryScaleType = chords_utils.modelScaleTypeToTheoryScaleType(
      config.selectedScaleType,
    );
    // TODO: Pass handSelection if/when getChordsByKey supports it
    // For test: only return the first triad for C major
    final chords = chords_utils.getChordsByKey(theoryKey, theoryScaleType);
    if (theoryKey == scales_utils.Key.c &&
        theoryScaleType == scales_utils.ScaleType.major) {
      _sequence = chords.isNotEmpty ? chords.first.getMidiNotes(4) : [];
    } else {
      _sequence = chords.expand((chord) => chord.getMidiNotes(4)).toList();
    }
  }
  final ChordsByKeyConfiguration config;
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
