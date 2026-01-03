import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/practice_exercise.dart";
import "package:piano_fitness/shared/models/practice_strategies/practice_strategy.dart";
import "package:piano_fitness/shared/utils/chords.dart";

/// Strategy for initializing chord-by-type practice sequences.
///
/// Generates exercises that practice a specific chord type (major, minor,
/// diminished, augmented) through all 12 keys using smooth voice leading.
class ChordsByTypeStrategy implements PracticeStrategy {
  /// Creates a chords-by-type strategy.
  ///
  /// Requires [chordType] to specify which chord quality to practice,
  /// [includeInversions] to determine if inversions should be included,
  /// [handSelection] to specify which hand(s) to practice,
  /// and [startOctave] for the base pitch.
  ChordsByTypeStrategy({
    required this.chordType,
    required this.includeInversions,
    required this.handSelection,
    required this.startOctave,
  });

  /// The type of chord to practice (major, minor, diminished, augmented).
  final ChordType chordType;

  /// Whether to include chord inversions in the exercise.
  final bool includeInversions;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the chords.
  final int startOctave;

  @override
  PracticeExercise initializeExercise() {
    final exercise = ChordByTypeDefinitions.getChordTypeExercise(
      chordType,
      includeInversions: includeInversions,
    );

    final chordProgression = exercise.generateChordSequence();

    // Convert chord progression to PracticeSteps
    final steps = <PracticeStep>[];

    for (var i = 0; i < chordProgression.length; i++) {
      final chord = chordProgression[i];
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
            "displayName": chord.name,
            "hand": handSelection.name,
          },
        ),
      );
    }

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "chordsByType",
        "chordType": chordType.name,
        "includeInversions": includeInversions,
        "handSelection": handSelection.name,
      },
    );
  }
}
