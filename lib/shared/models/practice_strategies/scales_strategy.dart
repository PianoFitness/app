import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_exercise.dart";
import "package:piano_fitness/shared/models/practice_strategies/practice_strategy.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

/// Strategy for initializing scale practice exercises.
///
/// Generates scale exercises based on the selected key, scale type,
/// and hand selection (left, right, or both hands).
class ScalesStrategy implements PracticeStrategy {
  /// Creates a scales strategy.
  ///
  /// Requires [key] and [scaleType] to define the scale, [handSelection]
  /// to specify which hand(s) to practice, and [startOctave] for the
  /// starting pitch.
  const ScalesStrategy({
    required this.key,
    required this.scaleType,
    required this.handSelection,
    required this.startOctave,
  });

  /// The musical key for the scale.
  final music.Key key;

  /// The type of scale (major, minor, modal, etc.).
  final music.ScaleType scaleType;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the scale.
  final int startOctave;

  @override
  PracticeExercise initializeExercise() {
    final scale = music.ScaleDefinitions.getScale(key, scaleType);
    final sequence = scale.getHandSequence(startOctave, handSelection);

    // Convert the sequence to PracticeSteps based on hand selection
    final steps = <PracticeStep>[];

    if (handSelection == HandSelection.both) {
      // Both hands: notes are paired [L1, R1, L2, R2, ...]
      // Each pair should be played simultaneously
      for (var i = 0; i < sequence.length; i += 2) {
        if (i + 1 < sequence.length) {
          steps.add(
            PracticeStep(
              notes: [sequence[i], sequence[i + 1]],
              type: StepType.paired,
              metadata: {"hand": "both", "degree": (i ~/ 2) + 1},
            ),
          );
        }
      }
    } else {
      // Single hand: each note is played sequentially
      for (var i = 0; i < sequence.length; i++) {
        steps.add(
          PracticeStep(
            notes: [sequence[i]],
            type: StepType.sequential,
            metadata: {
              "hand": handSelection == HandSelection.left ? "left" : "right",
              "degree": i + 1,
            },
          ),
        );
      }
    }

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "scale",
        "key": key.displayName,
        "scaleType": scaleType.name,
        "handSelection": handSelection.name,
      },
    );
  }
}
