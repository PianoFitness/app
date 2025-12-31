import "package:piano_fitness/shared/models/practice_strategy.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_type_configuration.dart";
import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/utils/chords.dart" as chords_utils;

/// Concrete strategy for chords by type practice mode.
class ChordsByTypeStrategy implements PracticeStrategy {
  ChordsByTypeStrategy(this.config) {
    // Use the chords_utils to generate the chord sequence for the selected type and inversions.
    final theoryChordType =
        chords_utils.ChordType.values[config.selectedChordType.index];
    final chords = chords_utils.ChordByTypeDefinitions.getChordTypeExercise(
      theoryChordType,
      includeInversions: config.includeInversions,
    ).generateChordSequence();
    _sequence = chords.expand((chord) => chord.getMidiNotes(4)).toList();
  }
  final ChordsByTypeConfiguration config;
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
