import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/practice_note.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// Creates a foundational accompaniment voicing for a chord.
///
/// The left hand plays the chord root as a bass note and the right hand plays
/// the complete chord voicing. This separates harmonic foundation from chord
/// shape, rather than asking both hands to duplicate the same chord.
abstract final class ChordAccompanimentVoicing {
  /// Creates practice targets for [chord] according to [handSelection].
  ///
  /// [preferredBassOctave] is adjusted downward when needed so the bass never
  /// duplicates or sits above a right-hand chord tone.
  static List<PracticeNote> create({
    required ChordInfo chord,
    required HandSelection handSelection,
    required int rightHandOctave,
    required int preferredBassOctave,
  }) {
    final rightHandNotes = chord.getMidiNotes(rightHandOctave);

    if (handSelection == HandSelection.left) {
      return [_bassNote(chord, preferredBassOctave)];
    }

    final rightHandTargets = rightHandNotes
        .map((pitch) => PracticeNote(pitch: pitch, hand: PracticeHand.right))
        .toList(growable: false);
    if (handSelection == HandSelection.right) {
      return rightHandTargets;
    }

    final lowestRightHandPitch = rightHandNotes
        .map((note) => note.value)
        .reduce((lowest, pitch) => pitch < lowest ? pitch : lowest);
    var bassPitch = NoteUtils.noteToMidiNumber(
      chord.rootNote,
      preferredBassOctave,
    );
    while (bassPitch >= lowestRightHandPitch && bassPitch >= 12) {
      bassPitch -= 12;
    }

    return [
      PracticeNote(pitch: MidiNote(bassPitch), hand: PracticeHand.left),
      ...rightHandTargets,
    ];
  }

  static PracticeNote _bassNote(ChordInfo chord, int octave) {
    return PracticeNote(
      pitch: MidiNote(NoteUtils.noteToMidiNumber(chord.rootNote, octave)),
      hand: PracticeHand.left,
    );
  }
}
