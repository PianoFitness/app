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
    _chords = chords_utils.ChordByTypeDefinitions.getChordTypeExercise(
      theoryChordType,
      includeInversions: config.includeInversions,
    ).generateChordSequence();
    _sequence = _chords.expand((chord) => chord.getMidiNotes(4)).toList();
  }
  final ChordsByTypeConfiguration config;
  late final List<int> _sequence;
  late final List<chords_utils.ChordInfo> _chords;

  @override
  List<int> generateSequence() => _sequence;

  @override
  List<int> getHighlightedNotes(int currentIndex) {
    if (_chords.isEmpty || _sequence.isEmpty) return [];
    // Each chord's notes are grouped together in the sequence.
    // Find which chord the currentIndex belongs to.
    int runningIndex = 0;
    for (final chord in _chords) {
      final chordNotes = chord.getMidiNotes(4);
      if (currentIndex >= runningIndex &&
          currentIndex < runningIndex + chordNotes.length) {
        return chordNotes;
      }
      runningIndex += chordNotes.length;
    }
    // Fallback: return the note at currentIndex if not found
    if (currentIndex >= 0 && currentIndex < _sequence.length) {
      return [_sequence[currentIndex]];
    }
    return [];
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
