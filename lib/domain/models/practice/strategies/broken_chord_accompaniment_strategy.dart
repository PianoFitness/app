import "package:piano_fitness/domain/models/music/broken_chord_pattern.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategy.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;

/// Builds a left-hand broken-chord accompaniment through a progression.
///
/// Each harmony lasts four quarter-note steps. The left hand plays the chosen
/// pattern; when both hands are selected, the right hand sounds the complete
/// chord on the first beat as a harmonic cue. Melody generation is deliberately
/// deferred to a later coordination exercise.
class BrokenChordAccompanimentStrategy implements PracticeStrategy {
  const BrokenChordAccompanimentStrategy({
    required this.key,
    required this.chordProgression,
    required this.handSelection,
    required this.startOctave,
    required this.pattern,
  });

  final music.Key key;
  final ChordProgression chordProgression;
  final HandSelection handSelection;
  final int startOctave;
  final BrokenChordPattern pattern;

  @override
  PracticeExercise initializeExercise() {
    final chords = chordProgression.generateChords(key);
    final steps = <PracticeStep>[];

    for (var chordIndex = 0; chordIndex < chords.length; chordIndex++) {
      final chord = chords[chordIndex];
      final leftHandTones = chord.getMidiNotes(startOctave - 1);
      final rightHandCue = chord
          .getMidiNotes(startOctave)
          .map((pitch) => PracticeNote(pitch: pitch, hand: PracticeHand.right))
          .toList(growable: false);

      for (
        var beatIndex = 0;
        beatIndex < pattern.chordToneIndexes.length;
        beatIndex++
      ) {
        final toneIndex = pattern.chordToneIndexes[beatIndex];
        if (toneIndex >= leftHandTones.length) {
          throw ArgumentError(
            "Broken-chord accompaniment requires a triad, but "
            "${chord.name} has only ${leftHandTones.length} tones.",
          );
        }

        final notes = <PracticeNote>[];
        if (handSelection != HandSelection.right) {
          notes.add(
            PracticeNote(
              pitch: leftHandTones[toneIndex],
              hand: PracticeHand.left,
            ),
          );
        }
        if (handSelection != HandSelection.left && beatIndex == 0) {
          notes.addAll(rightHandCue);
        }

        // Right-hand-only practice still needs a cue for every beat: repeat
        // the harmony rather than creating empty practice steps.
        if (notes.isEmpty) notes.addAll(rightHandCue);

        steps.add(
          PracticeStep(
            notes: notes,
            metadata: {
              "chordName": chord.name,
              "romanNumeral": chordProgression.romanNumerals[chordIndex],
              "chordPosition": chordIndex + 1,
              "beatInChord": beatIndex + 1,
              "pattern": pattern.name,
              "displayName":
                  "${chordProgression.romanNumerals[chordIndex]} · "
                  "beat ${beatIndex + 1}",
            },
          ),
        );
      }
    }

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "brokenChordAccompaniment",
        "key": key.displayName,
        "progressionName": chordProgression.name,
        "handSelection": handSelection.name,
        "pattern": pattern.name,
      },
    );
  }
}
