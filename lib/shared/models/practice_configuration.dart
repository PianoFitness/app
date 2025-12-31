import "package:piano_fitness/shared/models/result.dart";
import "package:piano_fitness/shared/models/validation_error.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";

/// Base interface for all practice configurations.
abstract class PracticeConfiguration {
  PracticeMode get mode;
  HandSelection get handSelection;

  /// Returns Success if valid, Failure with ValidationError otherwise.
  Result<void, ValidationError> validate();
}
