import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

/// Strategy for initializing chord-by-key practice sequences.
///
/// Generates smooth chord progressions through all chords in a key
/// (e.g., I, ii, iii, IV, V, vi, vii° in C major).
/// Can generate either triad or seventh chord progressions based on configuration.
class ChordsByKeyStrategy implements PracticeStrategy {
  /// Creates a chords-by-key strategy.
  ///
  /// Requires [key] and [scaleType] to determine which chords belong
  /// to the key, [handSelection] to specify which hand(s) to practice,
  /// [startOctave] for the base pitch, and [includeSeventhChords] to
  /// toggle between triads (3 notes) and seventh chords (4 notes).
  const ChordsByKeyStrategy({
    required this.key,
    required this.scaleType,
    required this.handSelection,
    required this.startOctave,
    required this.includeSeventhChords,
  });

  /// The musical key for the chord progression.
  final music.Key key;

  /// The scale type (major, minor, etc.) that determines chord qualities.
  final music.ScaleType scaleType;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the chords.
  final int startOctave;

  /// Whether to use seventh chords (4 notes) instead of triads (3 notes).
  final bool includeSeventhChords;

  @override
  PracticeExercise initializeExercise() {
    // Generate either triad or seventh chord progression based on toggle
    final chordProgression = includeSeventhChords
        ? ChordBuilder.getSmoothKeySeventhChordProgression(key, scaleType)
        : ChordBuilder.getSmoothKeyTriadProgression(key, scaleType);

    // Convert chord progression to PracticeSteps
    // Each chord is a simultaneous step
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
        "exerciseType": "chordsByKey",
        "key": key.displayName,
        "scaleType": scaleType.name,
        "handSelection": handSelection.name,
      },
    );
  }
}
