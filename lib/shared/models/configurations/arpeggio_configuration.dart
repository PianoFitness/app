import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/result.dart";
import "package:piano_fitness/shared/models/validation_error.dart";
import "package:piano_fitness/shared/utils/note_utils.dart" as note_utils;
import "package:piano_fitness/shared/utils/arpeggios.dart" as arpeggio_utils;

class ArpeggioConfiguration implements PracticeConfiguration {
  const ArpeggioConfiguration({
    required this.selectedRootNote,
    required this.selectedArpeggioType,
    required this.selectedArpeggioOctaves,
    required this.handSelection,
  });
  final note_utils.MusicalNote selectedRootNote;
  final arpeggio_utils.ArpeggioType selectedArpeggioType;
  final arpeggio_utils.ArpeggioOctaves selectedArpeggioOctaves;
  @override
  final HandSelection handSelection;

  @override
  PracticeMode get mode => PracticeMode.arpeggios;

  @override
  Result<void, ValidationError> validate() {
    return const Success<void, ValidationError>(null);
  }
}
