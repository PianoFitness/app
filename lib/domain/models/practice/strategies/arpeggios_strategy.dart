import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategy.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";

/// Strategy for initializing arpeggio practice sequences.
///
/// Generates arpeggio sequences based on the root note, arpeggio type,
/// octave range, and hand selection.
class ArpeggiosStrategy implements PracticeStrategy {
  /// Creates an arpeggios strategy.
  ///
  /// Requires [rootNote] for the starting pitch, [arpeggioType] for the
  /// chord quality, [arpeggioOctaves] for the range, [handSelection] for
  /// which hand(s) to practice, and [startOctave] for the base octave.
  const ArpeggiosStrategy({
    required this.rootNote,
    required this.arpeggioType,
    required this.arpeggioOctaves,
    required this.handSelection,
    required this.startOctave,
  });

  /// The root note for the arpeggio.
  final MusicalNote rootNote;

  /// The type of arpeggio (major, minor, diminished, augmented).
  final ArpeggioType arpeggioType;

  /// The number of octaves to span.
  final ArpeggioOctaves arpeggioOctaves;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the arpeggio.
  final int startOctave;

  @override
  PracticeExercise initializeExercise() {
    final arpeggio = ArpeggioDefinitions.getArpeggio(
      rootNote,
      arpeggioType,
      arpeggioOctaves,
    );
    final sequence = arpeggio.getHandSequence(startOctave, handSelection);

    // Convert the sequence to PracticeSteps based on hand selection
    final steps = <PracticeStep>[];

    if (handSelection == HandSelection.both) {
      // Validate even number of notes for paired hands
      if (sequence.length.isOdd) {
        throw ArgumentError(
          "Both hands mode requires an even number of notes in the sequence. "
          "Got ${sequence.length} notes for $rootNote ${arpeggioType.name} arpeggio "
          "(${arpeggioOctaves.name} octave(s)).",
        );
      }
      // Both hands: notes are paired [L1, R1, L2, R2, ...]
      // Each pair should be played simultaneously
      for (var i = 0; i < sequence.length; i += 2) {
        final position = (i ~/ 2) + 1;
        steps.add(
          PracticeStep(
            notes: [sequence[i], sequence[i + 1]],
            type: StepType.paired,
            metadata: {
              "hand": "both",
              "position": position,
              "displayName": "Note $position (Both Hands)",
            },
          ),
        );
      }
    } else {
      // Single hand: each note is played sequentially
      for (var i = 0; i < sequence.length; i++) {
        final position = i + 1;
        final handDisplay = handSelection == HandSelection.left
            ? "Left"
            : "Right";
        steps.add(
          PracticeStep(
            notes: [sequence[i]],
            type: StepType.sequential,
            metadata: {
              "hand": handSelection == HandSelection.left ? "left" : "right",
              "position": position,
              "displayName": "Note $position ($handDisplay Hand)",
            },
          ),
        );
      }
    }

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "arpeggio",
        "rootNote": rootNote.name,
        "arpeggioType": arpeggioType.name,
        "octaves": arpeggioOctaves.name,
        "handSelection": handSelection.name,
      },
    );
  }
}
