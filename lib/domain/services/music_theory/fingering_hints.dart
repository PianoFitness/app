import "package:piano_fitness/domain/models/music/hand_selection.dart";

/// Approximate, single-position piano fingering hints for the app's
/// starter exercises (C major scale, triads/sevenths rooted on C, and the
/// one-octave C major arpeggio).
///
/// This is deliberately not a general fingering engine — real fingering
/// depends on key signature, inversion, and hand span in ways this doesn't
/// model. It exists to seed the [PianoKeyboard] annotation channel
/// (`PianoKeyVisual.label`) with real data for the exercises a new player
/// sees first; other keys/types simply have no fingering metadata yet.
class FingeringHints {
  const FingeringHints._();

  static const List<int> _cMajorScaleAscendingRight = [1, 2, 3, 1, 2, 3, 4, 5];
  static const List<int> _cMajorScaleAscendingLeft = [5, 4, 3, 2, 1, 3, 2, 1];
  static const List<int> _majorArpeggioAscendingRight = [1, 2, 3, 5];
  static const List<int> _majorArpeggioAscendingLeft = [5, 3, 2, 1];
  static const List<int> _triadFingersRight = [1, 3, 5];
  static const List<int> _triadFingersLeft = [5, 3, 1];
  static const List<int> _seventhChordFingersRight = [1, 2, 3, 5];
  static const List<int> _seventhChordFingersLeft = [5, 3, 2, 1];

  /// Finger numbers for a one-octave C major scale played ascending then
  /// descending, aligned index-for-index with
  /// `Scale.getFullScaleSequence`'s note order.
  static List<int> cMajorScale({required bool rightHand}) => _mirrored(
    rightHand ? _cMajorScaleAscendingRight : _cMajorScaleAscendingLeft,
  );

  /// Finger numbers for a one-octave major arpeggio played ascending then
  /// descending, aligned index-for-index with
  /// `Arpeggio.getFullArpeggioSequence`'s note order (one-octave case only).
  static List<int> majorArpeggioOneOctave({required bool rightHand}) =>
      _mirrored(
        rightHand
            ? _majorArpeggioAscendingRight
            : _majorArpeggioAscendingLeft,
      );

  /// Finger numbers for a single triad or seventh-chord voicing, by note
  /// count, in bottom-to-top position order. Applied uniformly regardless
  /// of inversion (a common simplified teaching convention), so it's only
  /// an approximation once voicings move out of root position.
  static List<int>? chordVoicing({
    required bool rightHand,
    required int noteCount,
  }) {
    switch (noteCount) {
      case 3:
        return rightHand ? _triadFingersRight : _triadFingersLeft;
      case 4:
        return rightHand
            ? _seventhChordFingersRight
            : _seventhChordFingersLeft;
      default:
        return null;
    }
  }

  /// Finger numbers for a chord voicing as returned by
  /// `Chord.getMidiNotesForHand`, aligned index-for-index with its note
  /// order: a single hand's voicing for [HandSelection.left]/[.right], or
  /// the left hand's full voicing followed by the right hand's for
  /// [HandSelection.both] (matching `getMidiNotesForHand`'s
  /// left-notes-then-right-notes concatenation). Returns `null` if
  /// [totalNoteCount] doesn't correspond to a known voicing shape.
  static List<int>? chordFingersForHand({
    required HandSelection hand,
    required int totalNoteCount,
  }) {
    if (hand == HandSelection.both) {
      final coreCount = totalNoteCount ~/ 2;
      final left = chordVoicing(rightHand: false, noteCount: coreCount);
      final right = chordVoicing(rightHand: true, noteCount: coreCount);
      if (left == null || right == null) return null;
      return [...left, ...right];
    }
    return chordVoicing(
      rightHand: hand == HandSelection.right,
      noteCount: totalNoteCount,
    );
  }

  /// Mirrors [ascending] into an ascending-then-descending sequence,
  /// matching the note-sequence construction used by [Scale] and
  /// [Arpeggio] (`[...ascending, ...ascending.reversed.skip(1)]`), so the
  /// resulting list always has one finger per note.
  static List<int> _mirrored(List<int> ascending) => [
    ...ascending,
    ...ascending.reversed.skip(1),
  ];
}
