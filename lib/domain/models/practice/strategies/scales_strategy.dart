import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/fingering_hints.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

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
    final scaleNotes = scale.getNotes();

    final rightFingers = FingeringHints.scale(
      key: key,
      scaleType: scaleType,
      notes: scaleNotes,
      rightHand: true,
    );
    final leftFingers = FingeringHints.scale(
      key: key,
      scaleType: scaleType,
      notes: scaleNotes,
      rightHand: false,
    );

    // Convert the sequence to PracticeSteps based on hand selection
    final steps = <PracticeStep>[];

    if (handSelection == HandSelection.both) {
      // Validate even number of notes for paired hands
      if (sequence.length.isOdd) {
        throw ArgumentError(
          "Both hands mode requires an even number of notes in the sequence. "
          "Got ${sequence.length} notes for $key ${scaleType.name} scale.",
        );
      }
      // Both hands: notes are paired [L1, R1, L2, R2, ...]
      // Each pair should be played simultaneously
      for (var i = 0; i < sequence.length; i += 2) {
        if (i + 1 < sequence.length) {
          final degree = (i ~/ 2) + 1;
          steps.add(
            PracticeStep(
              notes: [
                PracticeNote(
                  pitch: MidiNote(sequence[i]),
                  hand: PracticeHand.left,
                  fingerNumber: leftFingers[i ~/ 2],
                ),
                PracticeNote(
                  pitch: MidiNote(sequence[i + 1]),
                  hand: PracticeHand.right,
                  fingerNumber: rightFingers[i ~/ 2],
                ),
              ],
              metadata: {
                "degree": degree,
                "displayName": "Degree $degree (Both Hands)",
              },
            ),
          );
        }
      }
    } else {
      // Single hand: each note is played sequentially
      final fingers = handSelection == HandSelection.left
          ? leftFingers
          : rightFingers;
      for (var i = 0; i < sequence.length; i++) {
        final degree = i + 1;
        final handDisplay = handSelection == HandSelection.left
            ? "Left"
            : "Right";
        steps.add(
          PracticeStep(
            notes: [
              PracticeNote(
                pitch: MidiNote(sequence[i]),
                hand: handSelection == HandSelection.left
                    ? PracticeHand.left
                    : PracticeHand.right,
                fingerNumber: fingers[i],
              ),
            ],
            metadata: {
              "degree": degree,
              "displayName": "Degree $degree ($handDisplay Hand)",
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
