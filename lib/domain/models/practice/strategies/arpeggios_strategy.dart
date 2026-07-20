import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/fingering_hints.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/tone_pattern.dart";

/// Strategy for initializing arpeggio practice sequences.
///
/// Generates arpeggio sequences based on the root note, arpeggio type,
/// octave range, hand selection, and chord-tone pattern.
class ArpeggiosStrategy implements PracticeStrategy {
  /// Creates an arpeggios strategy.
  ///
  /// Requires [rootNote] for the starting pitch, [arpeggioType] for the
  /// chord quality, [arpeggioOctaves] for the range, [handSelection] for
  /// which hand(s) to practice, [startOctave] for the base octave,
  /// [pattern] for the chord-tone pattern, and [includeLeftHandRoot] for
  /// whether the left hand taps the chord root once per rolling group
  /// (right-hand, rolling patterns only — a no-op otherwise).
  const ArpeggiosStrategy({
    required this.rootNote,
    required this.arpeggioType,
    required this.arpeggioOctaves,
    required this.handSelection,
    required this.startOctave,
    required this.pattern,
    required this.includeLeftHandRoot,
  });

  /// The root note for the arpeggio.
  final MusicalNote rootNote;

  /// The type of arpeggio (major, minor, diminished, augmented).
  final ArpeggioType arpeggioType;

  /// The number of octaves to span.
  final ArpeggioOctaves arpeggioOctaves;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the arpeggio.
  final int startOctave;

  /// Whether the arpeggio ascends in root position ([ChordTonePattern.straight])
  /// or continuously rotates through chord-tone inversions
  /// ([ChordTonePattern.rolling]).
  final ChordTonePattern pattern;

  /// Whether the left hand taps the chord root once per rolling group.
  /// Only applies when [handSelection] is [HandSelection.right] and
  /// [pattern] is [ChordTonePattern.rolling]; a no-op otherwise.
  final bool includeLeftHandRoot;

  @override
  PracticeExercise initializeExercise() {
    if (pattern == ChordTonePattern.rolling) {
      return _initializeRollingExercise();
    }

    final arpeggio = ArpeggioDefinitions.getArpeggio(
      rootNote,
      arpeggioType,
      arpeggioOctaves,
    );
    final sequence = arpeggio.getHandSequence(startOctave, handSelection);

    final rightFingers = FingeringHints.arpeggio(
      rootNote: rootNote,
      arpeggioType: arpeggioType,
      octaves: arpeggioOctaves,
      rightHand: true,
    );
    final leftFingers = FingeringHints.arpeggio(
      rootNote: rootNote,
      arpeggioType: arpeggioType,
      octaves: arpeggioOctaves,
      rightHand: false,
    );

    // Convert the sequence to PracticeSteps based on hand selection
    final steps = <PracticeStep>[];

    if (handSelection == HandSelection.both) {
      // Validate even number of notes for paired hands
      if (sequence.length.isOdd) {
        throw ArgumentError(
          "Both hands mode requires an even number of notes in the sequence. "
          "Got ${sequence.length} notes for $rootNote ${arpeggioType.name} arpeggio "
          "(${arpeggioOctaves.name} octave(s)).",
        );
      }
      // Both hands: notes are paired [L1, R1, L2, R2, ...]
      // Each pair should be played simultaneously
      for (var i = 0; i < sequence.length; i += 2) {
        final position = (i ~/ 2) + 1;
        steps.add(
          PracticeStep(
            notes: [
              PracticeNote(
                pitch: MidiNote(sequence[i]),
                hand: PracticeHand.left,
                fingerNumber: leftFingers[i ~/ 2],
              ),
              PracticeNote(
                pitch: MidiNote(sequence[i + 1]),
                hand: PracticeHand.right,
                fingerNumber: rightFingers[i ~/ 2],
              ),
            ],
            metadata: {
              "position": position,
              "displayName": "Note $position (Both Hands)",
            },
          ),
        );
      }
    } else {
      // Single hand: each note is played sequentially
      final fingers = handSelection == HandSelection.left
          ? leftFingers
          : rightFingers;
      for (var i = 0; i < sequence.length; i++) {
        final position = i + 1;
        final handDisplay = handSelection == HandSelection.left
            ? "Left"
            : "Right";
        steps.add(
          PracticeStep(
            notes: [
              PracticeNote(
                pitch: MidiNote(sequence[i]),
                hand: handSelection == HandSelection.left
                    ? PracticeHand.left
                    : PracticeHand.right,
                fingerNumber: fingers[i],
              ),
            ],
            metadata: {
              "position": position,
              "displayName": "Note $position ($handDisplay Hand)",
            },
          ),
        );
      }
    }

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "arpeggio",
        "rootNote": rootNote.name,
        "arpeggioType": arpeggioType.name,
        "octaves": arpeggioOctaves.name,
        "handSelection": handSelection.name,
        "pattern": pattern.name,
      },
    );
  }

  /// Builds a rolling-pattern arpeggio exercise via the shared
  /// [TonePattern] engine: overlapping chord-tone-degree groups that
  /// continuously rotate through inversions as they climb, flattened to
  /// singleton (broken) steps.
  PracticeExercise _initializeRollingExercise() {
    if ((handSelection == HandSelection.both || includeLeftHandRoot) &&
        startOctave < 1) {
      throw ArgumentError(
        "startOctave must be >= 1 for both hands or left-hand root taps "
        "(left hand plays at startOctave - 1), got: $startOctave",
      );
    }

    final coreIntervals = ArpeggioDefinitions.coreIntervals(arpeggioType);
    final n = coreIntervals.length;

    var tokens = TonePattern.rollingBroken(
      n: n,
      octaves: arpeggioOctaves.count,
    );
    final tapsLeftHandRoot =
        handSelection == HandSelection.right && includeLeftHandRoot;
    if (tapsLeftHandRoot) {
      tokens = TonePattern.withLeftHandRootTap(tokens, n);
    }
    if (handSelection == HandSelection.both) {
      tokens = TonePattern.bothHands(tokens);
    }
    final ascendingStepCount = tokens.length;
    tokens = TonePattern.mirrored(tokens);

    final defaultHand = handSelection == HandSelection.left
        ? PracticeHand.left
        : PracticeHand.right;
    final rightRootMidi = NoteUtils.noteToMidiNumber(rootNote, startOctave);
    final leftRootMidi = NoteUtils.noteToMidiNumber(
      rootNote,
      startOctave - 1,
    );
    int rootMidiForHand(PracticeHand hand) =>
        hand == PracticeHand.left ? leftRootMidi : rightRootMidi;

    // Mirror the *finger list* itself (not re-derive it from step position),
    // matching FingeringHints.arpeggio's convention: descending notes
    // retrace the same fingers used ascending, in reverse.
    List<int?> mirroredFingers(List<int>? shape) {
      if (shape == null) {
        return List<int?>.filled(tokens.length, null);
      }
      final ascending = List<int?>.generate(
        ascendingStepCount,
        (i) => shape[i % shape.length],
      );
      return [...ascending, ...ascending.reversed.skip(1)];
    }

    final rightFingerByStep = mirroredFingers(
      FingeringHints.chordVoicing(rightHand: true, noteCount: n),
    );
    final leftFingerByStep = mirroredFingers(
      FingeringHints.chordVoicing(rightHand: false, noteCount: n),
    );

    int? fingerFor(PracticeHand hand, int stepIndex, int positionInHand) {
      if (tapsLeftHandRoot && hand == PracticeHand.left) {
        return 5;
      }
      return hand == PracticeHand.right
          ? rightFingerByStep[stepIndex]
          : leftFingerByStep[stepIndex];
    }

    final steps = TonePattern.toPracticeSteps(
      tokens: tokens,
      coreIntervals: coreIntervals,
      rootMidiForHand: rootMidiForHand,
      defaultHand: defaultHand,
      fingerFor: fingerFor,
      metadataFor: (i) => {"position": i + 1, "displayName": "Note ${i + 1}"},
    );

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "arpeggio",
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
