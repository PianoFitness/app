import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";

/// One note within a [PatternToken]: a 1-based chord-tone degree and,
/// optionally, an explicit hand.
///
/// Degree 1 is the chord root; degree `n + 1` is the root one octave up
/// (`n` = the chord's tone count, e.g. 3 for a triad, 4 for a seventh
/// chord). Degrees wrap across octaves via `(degree - 1) % n` for the
/// chord tone and `(degree - 1) ~/ n` for the octave offset — the same
/// numbering used by the Nashville number system for scale/chord degrees,
/// extended past the chord size to reach higher octaves.
///
/// An unset [hand] resolves to a caller-supplied default hand when the
/// pattern is rendered via [TonePattern.toPracticeSteps].
@immutable
class DegreeNote {
  /// Creates a chord-tone degree reference, optionally tagged with a hand.
  const DegreeNote(this.degree, [this.hand]);

  /// The 1-based chord-tone degree.
  final int degree;

  /// The hand that plays this note, or `null` to use the default hand.
  final PracticeHand? hand;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DegreeNote && other.degree == degree && other.hand == hand;

  @override
  int get hashCode => Object.hash(degree, hand);

  @override
  String toString() => "DegreeNote($degree${hand != null ? ", $hand" : ""})";
}

/// One onset: a single [DegreeNote] played alone, or several played
/// simultaneously as a blocked group.
typedef PatternToken = List<DegreeNote>;

/// A small pattern engine for chord-tone-degree exercises, shared by broken
/// (arpeggio) and blocked (chord) practice strategies.
///
/// A pattern is a list of [PatternToken]s. Each token becomes one
/// [PracticeStep]: a bare degree is a singleton onset, a group of degrees
/// is a simultaneous (blocked) onset. See the four canonical generators
/// below for the patterns this app currently offers, and [parse] for the
/// compact string syntax those generators' output could equally be written
/// in by hand.
class TonePattern {
  const TonePattern._();

  /// Parses a compact pattern string into tokens, e.g. `"1,2,3,2,3,1'"` or
  /// `"1,(2,3),4,2,(3,4),5"`, with optional per-degree hand suffixes `L`/`R`,
  /// e.g. `"(1L,1),2,3,(1L,2),3,4"`.
  ///
  /// A digit may carry trailing apostrophe octave marks, ABC-notation
  /// style: `'` = one octave up, `''` = two octaves up, and so on — e.g.
  /// for a triad (`n: 3`), `1'` means degree 4 (the root, one octave up),
  /// keeping every bare digit in the readable `1..n` range instead of
  /// growing without bound. Octave marks come before any hand suffix, e.g.
  /// `"1'L"`. [n] is the chord's tone count, needed to resolve marks to
  /// absolute degrees.
  ///
  /// Not wired to any UI yet — this exists as a tested capability for a
  /// future custom-pattern mode. Untagged degrees carry a `null` hand, to
  /// be resolved later via [toPracticeSteps]'s `defaultHand`.
  static List<PatternToken> parse(String pattern, {required int n}) {
    final tokens = <PatternToken>[];
    var i = 0;
    final trimmed = pattern.trim();
    while (i < trimmed.length) {
      if (trimmed[i] == "," || trimmed[i] == " ") {
        i++;
        continue;
      }
      if (trimmed[i] == "(") {
        final close = trimmed.indexOf(")", i);
        if (close == -1) {
          throw FormatException("Unclosed group in pattern", trimmed, i);
        }
        final inner = trimmed.substring(i + 1, close);
        tokens.add(
          inner
              .split(",")
              .map((atom) => _parseDegreeAtom(atom.trim(), n))
              .toList(),
        );
        i = close + 1;
      } else {
        final next = trimmed.indexOf(",", i);
        final end = next == -1 ? trimmed.length : next;
        final atom = trimmed.substring(i, end).trim();
        if (atom.isNotEmpty) {
          tokens.add([_parseDegreeAtom(atom, n)]);
        }
        i = end;
      }
    }
    return tokens;
  }

  static DegreeNote _parseDegreeAtom(String atom, int n) {
    if (atom.isEmpty) {
      throw FormatException("Empty degree token in pattern");
    }
    var rest = atom;
    PracticeHand? hand;
    final handChar = rest[rest.length - 1];
    if (handChar == "L") {
      hand = PracticeHand.left;
      rest = rest.substring(0, rest.length - 1);
    } else if (handChar == "R") {
      hand = PracticeHand.right;
      rest = rest.substring(0, rest.length - 1);
    }

    var octaveMarks = 0;
    while (rest.isNotEmpty && rest[rest.length - 1] == "'") {
      octaveMarks++;
      rest = rest.substring(0, rest.length - 1);
    }

    final baseDegree = int.tryParse(rest);
    if (baseDegree == null) {
      throw FormatException("Invalid degree token '$atom' in pattern");
    }
    return DegreeNote(baseDegree + n * octaveMarks, hand);
  }

  // --- Canonical generators (ascending only; see `mirrored`) ---------------

  /// Root-position broken (arpeggiated) pattern: each octave restarts on
  /// the root. Degrees 1 through `n * octaves + 1` in order, one per
  /// singleton step — e.g. n=3, octaves=1: `1,2,3,4` (root, 3rd, 5th, root
  /// an octave up).
  static List<PatternToken> straightBroken({
    required int n,
    required int octaves,
  }) => [for (var d = 1; d <= n * octaves + 1; d++) [DegreeNote(d)]];

  /// Rolling broken (arpeggiated) pattern: overlapping n-note windows over
  /// the ascending degree sequence, each window one degree further than
  /// the last, flattened to singleton steps — e.g. n=3, octaves=1:
  /// `1,2,3,2,3,4`.
  static List<PatternToken> rollingBroken({
    required int n,
    required int octaves,
  }) => [
    for (final group in _rollingGroups(n: n, octaves: octaves))
      for (final d in group) [DegreeNote(d)],
  ];

  /// Root-position blocked (chord) pattern: one step per octave, each
  /// containing all `n` chord tones simultaneously — e.g. n=3, octaves=3:
  /// `(1,2,3),(4,5,6),(7,8,9)`.
  static List<PatternToken> straightBlocked({
    required int n,
    required int octaves,
  }) => [
    for (var o = 0; o < octaves; o++)
      [for (var d = 1; d <= n; d++) DegreeNote(o * n + d)],
  ];

  /// Rolling blocked (chord) pattern: the same overlapping windows as
  /// [rollingBroken], but each window is one blocked step instead of `n`
  /// singleton steps — e.g. n=3, octaves=1: `(1,2,3),(2,3,4)`.
  static List<PatternToken> rollingBlocked({
    required int n,
    required int octaves,
  }) => [
    for (final group in _rollingGroups(n: n, octaves: octaves))
      [for (final d in group) DegreeNote(d)],
  ];

  static List<List<int>> _rollingGroups({
    required int n,
    required int octaves,
  }) {
    final seqLength = n * octaves + 1;
    final degrees = List<int>.generate(seqLength, (i) => i + 1);
    return [
      for (var g = 0; g + n <= seqLength; g++) degrees.sublist(g, g + n),
    ];
  }

  /// Ascending tokens followed by the mirrored descent (excludes the
  /// duplicated top token), matching the ascend-then-descend convention
  /// used elsewhere in this app's scale and arpeggio generators.
  static List<PatternToken> mirrored(List<PatternToken> ascending) => [
    ...ascending,
    ...ascending.reversed.skip(1),
  ];

  // --- Composable transforms -------------------------------------------

  /// Merges a left-hand tap on chord-tone degree 1 into the first token of
  /// every [groupSize] consecutive tokens ([groupSize] = `n` for broken
  /// rolling patterns' n-note groups, `1` for blocked patterns where every
  /// token is already one group).
  ///
  /// Apply this before [mirrored], so the descending half mirrors
  /// symmetrically.
  static List<PatternToken> withLeftHandRootTap(
    List<PatternToken> tokens,
    int groupSize,
  ) => [
    for (var i = 0; i < tokens.length; i++)
      i % groupSize == 0
          ? [const DegreeNote(1, PracticeHand.left), ...tokens[i]]
          : tokens[i],
  ];

  /// Duplicates every entry into both hands, for fully-mirrored two-hand
  /// practice ([HandSelection.both]-style) — distinct from the sparse
  /// [withLeftHandRootTap]. A pattern should only ever have one of these
  /// two transforms applied, never both.
  static List<PatternToken> bothHands(List<PatternToken> tokens) => [
    for (final token in tokens)
      [
        for (final note in token) ...[
          DegreeNote(note.degree, PracticeHand.left),
          DegreeNote(note.degree, PracticeHand.right),
        ],
      ],
  ];

  // --- Resolution to PracticeSteps ---------------------------------------

  /// Resolves [tokens] to [PracticeStep]s.
  ///
  /// [rootMidiForHand] supplies the hand-specific MIDI root (e.g. right
  /// hand at `startOctave`, left hand at `startOctave - 1`). Notes with no
  /// explicit hand resolve to [defaultHand]. [fingerFor], if given, assigns
  /// a finger number from the resolved hand, the note's step index, and its
  /// position among same-hand notes within that step. Blocked patterns
  /// (multiple notes per hand in one step) typically key off
  /// `positionInHand`; broken patterns (one note per hand per step, where
  /// `positionInHand` is always 0) typically key off `stepIndex % n`
  /// instead, since consecutive steps cycle through a chord-tone group's
  /// positions one step at a time — both match the existing "uniform shape
  /// per group" fingering convention already used for blocked chords.
  /// [metadataFor] attaches step-level metadata by step index.
  static List<PracticeStep> toPracticeSteps({
    required List<PatternToken> tokens,
    required List<int> coreIntervals,
    required int Function(PracticeHand hand) rootMidiForHand,
    required PracticeHand defaultHand,
    int? Function(PracticeHand hand, int stepIndex, int positionInHand)?
    fingerFor,
    Map<String, dynamic> Function(int stepIndex)? metadataFor,
  }) {
    final n = coreIntervals.length;
    final steps = <PracticeStep>[];
    for (var stepIndex = 0; stepIndex < tokens.length; stepIndex++) {
      final token = tokens[stepIndex];
      final notesByHand = <PracticeHand, List<int>>{};
      final orderedNotes = <PracticeNote>[];
      for (final degreeNote in token) {
        final hand = degreeNote.hand ?? defaultHand;
        final zeroBased = degreeNote.degree - 1;
        final pitch =
            rootMidiForHand(hand) +
            coreIntervals[zeroBased % n] +
            12 * (zeroBased ~/ n);
        final positionInHand = notesByHand.putIfAbsent(hand, () => []).length;
        notesByHand[hand]!.add(pitch);
        orderedNotes.add(
          PracticeNote(
            pitch: MidiNote(pitch),
            hand: hand,
            fingerNumber: fingerFor?.call(hand, stepIndex, positionInHand),
          ),
        );
      }
      steps.add(
        PracticeStep(
          notes: orderedNotes,
          metadata: metadataFor?.call(stepIndex),
        ),
      );
    }
    return steps;
  }
}
