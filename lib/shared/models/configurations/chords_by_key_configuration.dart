import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/result.dart";
import "package:piano_fitness/shared/models/validation_error.dart";
import "package:piano_fitness/shared/models/music_key.dart";
import "package:piano_fitness/shared/models/scale_type.dart";

class ChordsByKeyConfiguration implements PracticeConfiguration {
  const ChordsByKeyConfiguration({
    required this.selectedKey,
    required this.selectedScaleType,
    required this.handSelection,
  });
  final MusicKey selectedKey;
  final ScaleType selectedScaleType;
  @override
  final HandSelection handSelection;

  @override
  PracticeMode get mode => PracticeMode.chordsByKey;

  @override
  Result<void, ValidationError> validate() {
    return const Success<void, ValidationError>(null);
  }
}
