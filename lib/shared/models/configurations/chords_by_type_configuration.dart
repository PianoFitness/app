import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/result.dart";
import "package:piano_fitness/shared/models/validation_error.dart";
import "package:piano_fitness/shared/models/chord_type.dart";

class ChordsByTypeConfiguration implements PracticeConfiguration {
  const ChordsByTypeConfiguration({
    required this.selectedChordType,
    required this.includeInversions,
    required this.handSelection,
  });
  final ChordType selectedChordType;
  final bool includeInversions;
  @override
  final HandSelection handSelection;

  @override
  PracticeMode get mode => PracticeMode.chordsByType;

  @override
  Result<void, ValidationError> validate() {
    return const Success<void, ValidationError>(null);
  }
}
