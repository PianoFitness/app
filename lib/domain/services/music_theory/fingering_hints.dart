import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// Standard piano fingering hints for the app's practice exercises.
///
/// Fingerings are provided for:
/// - Scales: all 12 keys and all 8 [ScaleType]s. Major and natural minor
///   (Aeolian) use fingerings taken from standard method-book charts.
///   The other modes (Dorian, Phrygian, Lydian, Mixolydian, Locrian) have
///   no established textbook convention, so their fingering is derived
///   algorithmically from the same rule real teachers use for an
///   unfamiliar scale: the thumb (finger 1) never plays a black key, and
///   the remaining notes are grouped into runs of 3 or 4 starting from
///   each thumb landing. This is a sound general method but, unlike the
///   major/minor tables, it isn't cross-checked against a published chart.
/// - Arpeggios: all 12 roots, all 7 [ArpeggioType]s, one through four
///   octaves, for the "straight" (root-position) pattern only. One-octave
///   fingering is a uniform 1-2-3-5 (RH) / 5-3-2-1 (LH) shape for
///   white-key roots, with documented per-key exceptions for the 5
///   black-key roots (where the shape depends on which chord tones are
///   also black). Multi-octave fingering is derived by repeating the
///   one-octave shape's core (root-3rd-5th, or root-3rd-5th-7th) once per
///   additional octave.
/// - Chords: triad/seventh-chord voicings by note count, applied
///   uniformly regardless of key or inversion (a common simplified
///   teaching convention for blocked chords, since the fingering only
///   depends on the chord's shape, not its key). The "rolling" arpeggio
///   and block-chord patterns (see `tone_pattern.dart`) reuse this same
///   uniform-shape convention per chord-tone group, rather than a
///   dedicated rolling-pattern fingering table.
class FingeringHints {
  const FingeringHints._();

  // ---------------------------------------------------------------------
  // Scales
  // ---------------------------------------------------------------------

  /// Finger numbers for a one-octave scale played ascending then
  /// descending, aligned index-for-index with `Scale.getFullScaleSequence`.
  ///
  /// [notes] must be the scale's ascending note sequence as returned by
  /// `Scale.getNotes()` (8 notes: the root through its octave repeat).
  static List<int> scale({
    required Key key,
    required ScaleType scaleType,
    required List<MusicalNote> notes,
    required bool rightHand,
  }) => _mirrored(
    _ascendingScaleFingers(
      key: key,
      scaleType: scaleType,
      notes: notes,
      rightHand: rightHand,
    ),
  );

  static List<int> _ascendingScaleFingers({
    required Key key,
    required ScaleType scaleType,
    required List<MusicalNote> notes,
    required bool rightHand,
  }) {
    switch (scaleType) {
      case ScaleType.major:
        final entry = _majorScaleFingerings[key]!;
        return rightHand ? entry.rh : entry.lh;
      case ScaleType.minor:
      case ScaleType.aeolian:
        final entry = _naturalMinorScaleFingerings[key]!;
        return rightHand ? entry.rh : entry.lh;
      case ScaleType.dorian:
      case ScaleType.phrygian:
      case ScaleType.lydian:
      case ScaleType.mixolydian:
      case ScaleType.locrian:
        final isBlack = notes
            .map((note) => _isBlackPitchClass(note.index))
            .toList();
        return rightHand
            ? _deriveRightHandScale(isBlack)
            : _deriveLeftHandScale(isBlack);
    }
  }

  /// Standard one-octave major-scale fingerings, ascending, by key.
  static const Map<Key, ({List<int> rh, List<int> lh})>
  _majorScaleFingerings = {
    Key.c: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.cSharp: (rh: [2, 3, 1, 2, 3, 4, 1, 2], lh: [3, 2, 1, 4, 3, 2, 1, 3]),
    Key.d: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.dSharp: (rh: [3, 1, 2, 3, 4, 1, 2, 3], lh: [3, 2, 1, 4, 3, 2, 1, 3]),
    Key.e: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.f: (rh: [1, 2, 3, 4, 1, 2, 3, 4], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.fSharp: (rh: [2, 3, 4, 1, 2, 3, 1, 2], lh: [4, 3, 2, 1, 3, 2, 1, 4]),
    Key.g: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.gSharp: (rh: [3, 4, 1, 2, 3, 1, 2, 3], lh: [3, 2, 1, 4, 3, 2, 1, 3]),
    Key.a: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.aSharp: (rh: [2, 1, 2, 3, 1, 2, 3, 4], lh: [3, 2, 1, 4, 3, 2, 1, 3]),
    Key.b: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [4, 3, 2, 1, 4, 3, 2, 1]),
  };

  /// Standard one-octave natural minor (Aeolian) scale fingerings,
  /// ascending, by key.
  static const Map<Key, ({List<int> rh, List<int> lh})>
  _naturalMinorScaleFingerings = {
    Key.c: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.cSharp: (rh: [3, 4, 1, 2, 3, 1, 2, 3], lh: [3, 2, 1, 4, 3, 2, 1, 3]),
    Key.d: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.dSharp: (rh: [3, 1, 2, 3, 4, 1, 2, 3], lh: [2, 1, 4, 3, 2, 1, 3, 2]),
    Key.e: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.f: (rh: [1, 2, 3, 4, 1, 2, 3, 4], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.fSharp: (rh: [2, 3, 1, 2, 3, 1, 2, 3], lh: [4, 3, 2, 1, 3, 2, 1, 4]),
    Key.g: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.gSharp: (rh: [3, 4, 1, 2, 3, 1, 2, 3], lh: [3, 2, 1, 3, 2, 1, 4, 3]),
    Key.a: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [5, 4, 3, 2, 1, 3, 2, 1]),
    Key.aSharp: (rh: [2, 1, 2, 3, 1, 2, 3, 4], lh: [2, 1, 3, 2, 1, 4, 3, 2]),
    Key.b: (rh: [1, 2, 3, 1, 2, 3, 4, 5], lh: [4, 3, 2, 1, 4, 3, 2, 1]),
  };

  static bool _isBlackPitchClass(int pitchClass) =>
      const {1, 3, 6, 8, 10}.contains(pitchClass % 12);

  /// Derives right-hand ascending fingering for an 8-note scale (root
  /// through its octave repeat) using the standard rule: the thumb
  /// (finger 1) never lands on a black key. Leading black keys before the
  /// first thumb landing get consecutive fingers starting at 2; from each
  /// thumb landing, the run extends to 4 notes if doing so is needed to
  /// keep the *next* thumb landing off a black key, otherwise it's 3.
  static List<int> _deriveRightHandScale(List<bool> isBlack) {
    final fingers = List<int>.filled(8, 0);
    var i = 0;
    var prefixFinger = 2;
    while (i < 7 && isBlack[i]) {
      fingers[i] = prefixFinger;
      prefixFinger++;
      i++;
    }
    while (i < 7) {
      fingers[i] = 1;
      final boundary = i + 3;
      if (boundary > 6) {
        var finger = 2;
        for (var j = i + 1; j <= 6; j++) {
          fingers[j] = finger;
          finger++;
        }
        i = 7;
      } else if (isBlack[boundary]) {
        fingers[i + 1] = 2;
        fingers[i + 2] = 3;
        fingers[i + 3] = 4;
        i += 4;
      } else {
        fingers[i + 1] = 2;
        fingers[i + 2] = 3;
        i += 3;
      }
    }
    fingers[7] = fingers[6] + 1;
    return fingers;
  }

  /// Derives left-hand ascending fingering by applying the right-hand
  /// rule to the reversed note sequence and reversing the result back —
  /// left-hand ascending fingering mirrors right-hand descending
  /// fingering, a well-known symmetry of standard scale fingering.
  static List<int> _deriveLeftHandScale(List<bool> isBlack) =>
      _deriveRightHandScale(isBlack.reversed.toList()).reversed.toList();

  // ---------------------------------------------------------------------
  // Arpeggios
  // ---------------------------------------------------------------------

  /// Finger numbers for an arpeggio played ascending then descending,
  /// aligned index-for-index with `Arpeggio.getFullArpeggioSequence`.
  static List<int> arpeggio({
    required MusicalNote rootNote,
    required ArpeggioType arpeggioType,
    required ArpeggioOctaves octaves,
    required bool rightHand,
  }) {
    final isSeventh =
        arpeggioType == ArpeggioType.dominant7 ||
        arpeggioType == ArpeggioType.minor7 ||
        arpeggioType == ArpeggioType.major7;
    final shape = isSeventh
        ? _seventhArpeggioShape(rootNote, arpeggioType)
        : _triadArpeggioShape(rootNote, arpeggioType);
    final oneOctave = rightHand ? shape.rh : shape.lh;
    final ascending = _extendToOctaves(oneOctave, octaves.count);
    return _mirrored(ascending);
  }

  // Named finger shapes, shared across the roots/qualities that use them.
  static const ({List<int> rh, List<int> lh}) _white3 = (
    rh: [1, 2, 3, 5],
    lh: [5, 3, 2, 1],
  );
  static const ({List<int> rh, List<int> lh}) _blackA3 = (
    rh: [4, 1, 2, 4],
    lh: [2, 1, 4, 2],
  );
  static const ({List<int> rh, List<int> lh}) _blackB3 = (
    rh: [4, 1, 2, 4],
    lh: [3, 2, 1, 3],
  );
  static const ({List<int> rh, List<int> lh}) _blackC3 = (
    rh: [2, 3, 1, 2],
    lh: [3, 2, 1, 3],
  );

  static const ({List<int> rh, List<int> lh}) _white4 = (
    rh: [1, 2, 3, 4, 5],
    lh: [5, 4, 3, 2, 1],
  );
  static const ({List<int> rh, List<int> lh}) _blackA4 = (
    rh: [4, 1, 2, 3, 4],
    lh: [2, 1, 4, 3, 2],
  );
  static const ({List<int> rh, List<int> lh}) _blackB4 = (
    rh: [2, 3, 4, 1, 2],
    lh: [4, 3, 2, 1, 4],
  );
  static const ({List<int> rh, List<int> lh}) _blackC4 = (
    rh: [4, 1, 2, 3, 4],
    lh: [3, 2, 1, 4, 3],
  );
  static const ({List<int> rh, List<int> lh}) _blackD4 = (
    rh: [3, 4, 1, 2, 3],
    lh: [3, 2, 1, 4, 3],
  );

  /// One-octave root-position triad arpeggio fingering shape by root and
  /// quality. White-key roots (C,D,E,F,G,A,B) use the uniform 1-2-3-5 /
  /// 5-3-2-1 shape for every quality. The 5 black-key roots each have
  /// per-quality exceptions, including two "all-black" chords (F# major,
  /// D#/Eb minor) where every chord tone is a black key and the thumb has
  /// no white-key option, so standard pedagogy just falls back to 1-2-3-5.
  static ({List<int> rh, List<int> lh}) _triadArpeggioShape(
    MusicalNote root,
    ArpeggioType type,
  ) {
    switch (root) {
      case MusicalNote.cSharp: // Db
        switch (type) {
          case ArpeggioType.major:
          case ArpeggioType.minor:
            return _blackA3;
          case ArpeggioType.diminished:
          case ArpeggioType.augmented:
            return _blackB3;
          default:
            return _white3;
        }
      case MusicalNote.dSharp: // Eb
        switch (type) {
          case ArpeggioType.major:
            return _blackA3;
          case ArpeggioType.minor:
            return _white3; // all-black exception
          case ArpeggioType.diminished:
            return _blackC3;
          case ArpeggioType.augmented:
            return _blackB3;
          default:
            return _white3;
        }
      case MusicalNote.fSharp: // Gb/F#
        switch (type) {
          case ArpeggioType.major:
            return _white3; // all-black exception
          case ArpeggioType.minor:
            return _blackA3;
          case ArpeggioType.diminished:
            return _blackB3;
          case ArpeggioType.augmented:
            return _blackC3;
          default:
            return _white3;
        }
      case MusicalNote.gSharp: // Ab
        switch (type) {
          case ArpeggioType.major:
          case ArpeggioType.minor:
            return _blackA3;
          case ArpeggioType.diminished:
          case ArpeggioType.augmented:
            return _blackB3;
          default:
            return _white3;
        }
      case MusicalNote.aSharp: // Bb
        switch (type) {
          case ArpeggioType.major:
            return _blackB3;
          case ArpeggioType.minor:
          case ArpeggioType.diminished:
            return _blackC3;
          case ArpeggioType.augmented:
            return _blackA3;
          default:
            return _white3;
        }
      default: // White-key roots: C, D, E, F, G, A, B
        return _white3;
    }
  }

  /// One-octave seventh-chord arpeggio fingering shape by root and
  /// quality (dominant7/minor7/major7 only — triad qualities never reach
  /// this method). White-key roots use the uniform 1-2-3-4-5 / 5-4-3-2-1
  /// shape. D#/Eb minor7 is the seventh-chord "all-black" exception
  /// (Eb-Gb-Bb-Db are all black keys).
  static ({List<int> rh, List<int> lh}) _seventhArpeggioShape(
    MusicalNote root,
    ArpeggioType type,
  ) {
    switch (root) {
      case MusicalNote.cSharp: // Db/C#
        return _blackA4;
      case MusicalNote.dSharp: // Eb
        return type == ArpeggioType.minor7
            ? _white4
            : _blackA4; // all-black exception
      case MusicalNote.fSharp: // Gb/F#
        return type == ArpeggioType.minor7 ? _blackA4 : _blackB4;
      case MusicalNote.gSharp: // Ab
        return _blackA4;
      case MusicalNote.aSharp: // Bb
        return type == ArpeggioType.minor7 ? _blackD4 : _blackC4;
      default: // White-key roots: C, D, E, F, G, A, B
        return _white4;
    }
  }

  /// Extends a one-octave arpeggio shape (root-3rd-5th[-7th]-octave) to
  /// [octaveCount] octaves by repeating the core chord-tone cell
  /// (everything but the final octave note) once per additional octave
  /// before that final note, matching how multi-octave arpeggios are
  /// conventionally fingered: the same hand shape lands on each new root.
  static List<int> _extendToOctaves(List<int> oneOctave, int octaveCount) {
    final core = oneOctave.sublist(0, oneOctave.length - 1);
    return [for (var i = 0; i < octaveCount; i++) ...core, oneOctave.last];
  }

  // ---------------------------------------------------------------------
  // Chords
  // ---------------------------------------------------------------------

  static const List<int> _triadFingersRight = [1, 3, 5];
  static const List<int> _triadFingersLeft = [5, 3, 1];
  static const List<int> _seventhChordFingersRight = [1, 2, 3, 5];
  static const List<int> _seventhChordFingersLeft = [5, 3, 2, 1];

  /// Finger numbers for a single triad or seventh-chord voicing, by note
  /// count, in bottom-to-top position order. Applied uniformly regardless
  /// of key or inversion (a common simplified teaching convention for
  /// blocked chords), so it's only an approximation once voicings move
  /// out of root position.
  static List<int>? chordVoicing({
    required bool rightHand,
    required int noteCount,
  }) {
    switch (noteCount) {
      case 3:
        return rightHand ? _triadFingersRight : _triadFingersLeft;
      case 4:
        return rightHand ? _seventhChordFingersRight : _seventhChordFingersLeft;
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

  // ---------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------

  /// Mirrors [ascending] into an ascending-then-descending sequence,
  /// matching the note-sequence construction used by [Scale] and
  /// [Arpeggio] (`[...ascending, ...ascending.reversed.skip(1)]`), so the
  /// resulting list always has one finger per note.
  static List<int> _mirrored(List<int> ascending) => [
    ...ascending,
    ...ascending.reversed.skip(1),
  ];
}
