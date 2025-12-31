import "package:piano_fitness/shared/models/practice_configuration.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/result.dart";
import "package:piano_fitness/shared/models/validation_error.dart";
import "package:piano_fitness/shared/models/musical_note.dart";
import "package:piano_fitness/shared/models/arpeggio_type.dart";
import "package:piano_fitness/shared/models/arpeggio_octaves.dart";

class ArpeggioConfiguration implements PracticeConfiguration {
  const ArpeggioConfiguration({
    required this.selectedRootNote,
    required this.selectedArpeggioType,
    required this.selectedArpeggioOctaves,
    required this.handSelection,
  });
  final MusicalNote selectedRootNote;
  final ArpeggioType selectedArpeggioType;
  final ArpeggioOctaves selectedArpeggioOctaves;
  @override
  final HandSelection handSelection;

  @override
  PracticeMode get mode => PracticeMode.arpeggios;

  @override
  Result<void, ValidationError> validate() {
    return const Success<void, ValidationError>(null);
  }
}
