import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_exercise.dart";
import "package:piano_fitness/shared/models/practice_strategies/practice_strategy.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

/// Strategy for initializing chord progression practice sequences.
///
/// Generates chord progressions using roman numeral notation (e.g., I-IV-V-I)
/// in the selected key.
class ChordProgressionsStrategy implements PracticeStrategy {
  /// Creates a chord progressions strategy.
  ///
  /// Requires [key] for the tonal center, [chordProgression] defining the
  /// progression pattern, [handSelection] to specify which hand(s) to practice,
  /// and [startOctave] for the base pitch.
  ChordProgressionsStrategy({
    required this.key,
    required this.chordProgression,
    required this.handSelection,
    required this.startOctave,
  });

  /// The musical key for the progression.
  final music.Key key;

  /// The chord progression pattern to practice.
  final ChordProgression chordProgression;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the chords.
  final int startOctave;

  @override
  PracticeExercise initializeExercise() {
    final generatedChords = chordProgression.generateChords(key);

    // Convert chord progression to PracticeSteps
    final steps = <PracticeStep>[];

    for (var i = 0; i < generatedChords.length; i++) {
      final chord = generatedChords[i];
      final chordNotes = chord.getMidiNotesForHand(startOctave, handSelection);

      steps.add(
        PracticeStep(
          notes: chordNotes,
          type: StepType.simultaneous,
          metadata: {
            "chordName": chord.name,
            "rootNote": chord.rootNote.name,
            "chordType": chord.type.name,
            "inversion": chord.inversion.name,
            "position": i + 1,
            "romanNumeral": chordProgression.romanNumerals[i],
            "displayName":
                "${chordProgression.romanNumerals[i]}: ${chord.name}",
            "hand": handSelection.name,
          },
        ),
      );
    }

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "chordProgressions",
        "key": key.displayName,
        "progressionName": chordProgression.name,
        "difficulty": chordProgression.difficulty.name,
        "handSelection": handSelection.name,
      },
    );
  }
}
