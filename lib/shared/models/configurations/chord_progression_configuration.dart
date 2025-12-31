import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/result.dart";
import "package:piano_fitness/shared/models/validation_error.dart";
import "package:piano_fitness/shared/models/chord_progression.dart";
import "package:piano_fitness/shared/models/music_key.dart";

class ChordProgressionConfiguration implements PracticeConfiguration {
  const ChordProgressionConfiguration({
    required this.selectedChordProgression,
    required this.selectedKey,
    required this.handSelection,
  });
  final ChordProgression? selectedChordProgression;
  final MusicKey selectedKey;
  @override
  final HandSelection handSelection;

  @override
  PracticeMode get mode => PracticeMode.chordProgressions;

  @override
  Result<void, ValidationError> validate() {
    return const Success<void, ValidationError>(null);
  }
}
