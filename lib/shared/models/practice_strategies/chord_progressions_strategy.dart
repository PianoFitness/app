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
  /// If [chordProgression] is null, defaults to I-V progression.
  ChordProgressionsStrategy({
    required this.key,
    required this.chordProgression,
    required this.handSelection,
    required this.startOctave,
  });

  /// The musical key for the progression.
  final music.Key key;

  /// The chord progression pattern to practice.
  /// If null, will default to I-V.
  ChordProgression? chordProgression;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the chords.
  final int startOctave;

  @override
  PracticeExercise initializeExercise() {
    // Default to I-V if no progression selected
    final progression =
        chordProgression ??
        ChordProgressionLibrary.getProgressionByName("I - V");

    if (progression == null) {
      // Fallback to empty exercise if default progression not found
      return const PracticeExercise(steps: []);
    }

    // Update the stored progression if we used the default
    chordProgression = progression;

    final generatedChords = progression.generateChords(key);

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
            "romanNumeral": progression.romanNumerals[i],
            "displayName": "${progression.romanNumerals[i]}: ${chord.name}",
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
        "progressionName": progression.name,
        "difficulty": progression.difficulty.name,
        "handSelection": handSelection.name,
      },
    );
  }
}
