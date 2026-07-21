import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/fingering_hints.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/tone_pattern.dart";

/// Strategy for initializing block-chord practice sequences.
///
/// Generates a single root's chord tones stepped across octaves — either
/// staying in root position each octave ([ChordTonePattern.straight]) or
/// continuously rotating through inversions as the pattern climbs
/// ([ChordTonePattern.rolling]) — with every chord-tone group played as one
/// simultaneous (blocked) step. This is the blocked-texture counterpart to
/// [ArpeggiosStrategy]'s broken texture, sharing the same
/// [TonePattern] generator.
class BlockChordsStrategy implements PracticeStrategy {
  /// Creates a block chords strategy.
  ///
  /// Requires [rootNote] for the chord root, [arpeggioType] for the chord
  /// quality, [arpeggioOctaves] for the range, [handSelection] for which
  /// hand(s) to practice, [startOctave] for the base octave, [pattern] for
  /// the chord-tone pattern, and [includeLeftHandRoot] for whether the
  /// left hand taps the chord root on every step (right hand only — a
  /// no-op otherwise).
  const BlockChordsStrategy({
    required this.rootNote,
    required this.arpeggioType,
    required this.arpeggioOctaves,
    required this.handSelection,
    required this.startOctave,
    required this.pattern,
    required this.includeLeftHandRoot,
  });

  /// The root note for the chord.
  final MusicalNote rootNote;

  /// The type/quality of the chord (major, minor, diminished, augmented,
  /// or a seventh chord quality).
  final ArpeggioType arpeggioType;

  /// The number of octaves to span.
  final ArpeggioOctaves arpeggioOctaves;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the chord.
  final int startOctave;

  /// Whether each octave stays in root position ([ChordTonePattern.straight])
  /// or the chord continuously rotates through inversions
  /// ([ChordTonePattern.rolling]).
  final ChordTonePattern pattern;

  /// Whether the left hand taps the chord root on every step. Only applies
  /// when [handSelection] is [HandSelection.right]; a no-op otherwise.
  final bool includeLeftHandRoot;

  @override
  PracticeExercise initializeExercise() {
    validateLeftHandStartOctave(
      startOctave,
      handSelection: handSelection,
      includeLeftHandRoot: includeLeftHandRoot,
    );

    final coreIntervals = ArpeggioDefinitions.coreIntervals(arpeggioType);
    final n = coreIntervals.length;

    var tokens = pattern == ChordTonePattern.straight
        ? TonePattern.straightBlocked(n: n, octaves: arpeggioOctaves.count)
        : TonePattern.rollingBlocked(n: n, octaves: arpeggioOctaves.count);

    final tapsLeftHandRoot =
        handSelection == HandSelection.right && includeLeftHandRoot;
    if (tapsLeftHandRoot) {
      // Every blocked token is already its own chord-tone group.
      tokens = TonePattern.withLeftHandRootTap(tokens, 1);
    }
    if (handSelection == HandSelection.both) {
      tokens = TonePattern.bothHands(tokens);
    }
    tokens = TonePattern.mirrored(tokens);

    final defaultHand = handSelection == HandSelection.left
        ? PracticeHand.left
        : PracticeHand.right;
    final rightRootMidi = NoteUtils.noteToMidiNumber(rootNote, startOctave);
    final leftRootMidi = NoteUtils.noteToMidiNumber(rootNote, startOctave - 1);
    int rootMidiForHand(PracticeHand hand) =>
        hand == PracticeHand.left ? leftRootMidi : rightRootMidi;

    final rightShape = FingeringHints.chordVoicing(
      rightHand: true,
      noteCount: n,
    );
    final leftShape = FingeringHints.chordVoicing(
      rightHand: false,
      noteCount: n,
    );

    int? fingerFor(PracticeHand hand, int stepIndex, int positionInHand) {
      if (tapsLeftHandRoot && hand == PracticeHand.left) {
        return 5;
      }
      final shape = hand == PracticeHand.right ? rightShape : leftShape;
      if (shape == null || positionInHand >= shape.length) return null;
      return shape[positionInHand];
    }

    final steps = TonePattern.toPracticeSteps(
      tokens: tokens,
      coreIntervals: coreIntervals,
      rootMidiForHand: rootMidiForHand,
      defaultHand: defaultHand,
      fingerFor: fingerFor,
      metadataFor: (i) => {"position": i + 1, "displayName": "Chord ${i + 1}"},
    );

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "blockChords",
        "rootNote": rootNote.name,
        "arpeggioType": arpeggioType.name,
        "octaves": arpeggioOctaves.name,
        "handSelection": handSelection.name,
        "pattern": pattern.name,
        if (includeLeftHandRoot) "includeLeftHandRoot": includeLeftHandRoot,
      },
    );
  }
}
