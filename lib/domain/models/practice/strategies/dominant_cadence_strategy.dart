import "dart:math" show min;

import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/practice_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/chord_builder.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;
import "package:piano_fitness/domain/services/music_theory/voice_leading_utils.dart";

/// A pair of (V chord inversion, I chord inversion) for one cadence exercise step.
typedef _CadencePair = ({ChordInversion vInv, ChordInversion iInv});

/// Strategy for dominant cadence (V→I) practice.
///
/// Generates pairs of dominant → tonic chords across all inversions, organised
/// by the **target I chord** (destination-first framing). For each pair the
/// student plays the V approach chord first, then resolves to the labelled I target.
///
/// **Triad mode** (`includeSeventhChords = false`): 3 pairs, 6 steps total.
/// Each pair is one rotation of the same three voice motions — common tone
/// held, leading tone up by half-step, supertonic up by whole-step — covering
/// all three inversions of both V and I across the three pairs.
///
/// **Seventh chord mode** (`includeSeventhChords = true`): 4 pairs, 8 steps total.
/// The V chord becomes V7 (`ChordType.dominant7`) and the I chord becomes Imaj7
/// (`ChordType.major7`). V7 and Imaj7 share two common tones, so the symmetric
/// inversion pairing (root→root, 1st→1st, 2nd→2nd, 3rd→3rd) produces excellent
/// voice leading throughout.
class DominantCadenceStrategy implements PracticeStrategy {
  /// Creates a dominant cadence strategy.
  ///
  /// Requires [key] for the tonal centre, [handSelection] for which hand(s)
  /// to practice, [startOctave] for the base pitch, and [includeSeventhChords]
  /// to toggle between triad pairs (V→I) and seventh chord pairs (V7→Imaj7).
  const DominantCadenceStrategy({
    required this.key,
    required this.handSelection,
    required this.startOctave,
    required this.includeSeventhChords,
  });

  /// The musical key (determines tonic and dominant notes).
  final music.Key key;

  /// Which hand(s) to practice (left, right, or both).
  final HandSelection handSelection;

  /// The starting octave for the chords.
  final int startOctave;

  /// Whether to use seventh chords (V7 → Imaj7) instead of triads (V → I).
  final bool includeSeventhChords;

  // ---------------------------------------------------------------------------
  // Predefined voice-leading pairs
  // ---------------------------------------------------------------------------

  /// Triad pairs — each is one "rotation" of the same three voice movements:
  /// common tone held (0), leading tone up (+1 semitone), supertonic up (+2).
  ///
  /// In C major: G→G (hold), B→C (+1), D→E (+2), regardless of inversion.
  ///
  /// - Pair 1: V 1st inv → I Root   (common tone G at top of both chords)
  /// - Pair 2: V Root   → I 2nd inv (common tone G at bottom of both chords)
  /// - Pair 3: V 2nd inv → I 1st inv (common tone G in middle of both chords)
  static const List<_CadencePair> _triadPairs = [
    (vInv: ChordInversion.first, iInv: ChordInversion.root),
    (vInv: ChordInversion.root, iInv: ChordInversion.second),
    (vInv: ChordInversion.second, iInv: ChordInversion.first),
  ];

  /// Seventh chord pairs — symmetric mapping (root→root, 1st→1st, …).
  ///
  /// V7 and Imaj7 share two common tones (G and B in C major), making each pair
  /// very smooth. The third inversion is valid because Imaj7 has four notes.
  static const List<_CadencePair> _seventhPairs = [
    (vInv: ChordInversion.root, iInv: ChordInversion.root),
    (vInv: ChordInversion.first, iInv: ChordInversion.first),
    (vInv: ChordInversion.second, iInv: ChordInversion.second),
    (vInv: ChordInversion.third, iInv: ChordInversion.third),
  ];

  // ---------------------------------------------------------------------------
  // PracticeStrategy implementation
  // ---------------------------------------------------------------------------

  @override
  PracticeExercise initializeExercise() {
    final scaleNotes = music.ScaleDefinitions.getScale(
      key,
      music.ScaleType.major,
    ).getNotes();
    final tonicNote = scaleNotes[0]; // Scale degree I
    final dominantNote = scaleNotes[4]; // Scale degree V (7 semitones up)

    final pairs = includeSeventhChords ? _seventhPairs : _triadPairs;
    final vChordType = includeSeventhChords
        ? ChordType.dominant7
        : ChordType.major;
    final iChordType = includeSeventhChords
        ? ChordType.major7
        : ChordType.major;

    final steps = <PracticeStep>[];

    for (var pairIndex = 0; pairIndex < pairs.length; pairIndex++) {
      final pair = pairs[pairIndex];

      // Build V approach chord.
      final vChord = ChordBuilder.getChord(dominantNote, vChordType, pair.vInv);
      final vNotes = vChord.getMidiNotesForHand(startOctave, handSelection);
      // Use the right-hand (canonical) register of V to choose the I chord octave.
      final vBaseNotes = vChord.getMidiNotes(startOctave);

      steps.add(
        PracticeStep(
          notes: vNotes.values,
          type: StepType.simultaneous,
          metadata: {
            "chordName": vChord.name,
            "rootNote": vChord.rootNote.name,
            "chordType": vChord.type.name,
            "inversion": vChord.inversion.name,
            "position": pairIndex * 2 + 1,
            "displayName": vChord.name,
            "hand": handSelection.name,
            "stepRole": "dominant",
            "pairIndex": pairIndex,
          },
        ),
      );

      // Build I target chord, choosing the octave that keeps it in the same
      // register as V for smooth voice leading.
      final iChord = ChordBuilder.getChord(tonicNote, iChordType, pair.iInv);
      final iOctave = _selectIChordOctave(iChord, vBaseNotes);
      final iNotes = iChord.getMidiNotesForHand(iOctave, handSelection);

      steps.add(
        PracticeStep(
          notes: iNotes.values,
          type: StepType.simultaneous,
          metadata: {
            "chordName": iChord.name,
            "rootNote": iChord.rootNote.name,
            "chordType": iChord.type.name,
            "inversion": iChord.inversion.name,
            "position": pairIndex * 2 + 2,
            "displayName": _iTargetDisplayName(pair.iInv, includeSeventhChords),
            "hand": handSelection.name,
            "stepRole": "tonic",
            "pairIndex": pairIndex,
          },
        ),
      );
    }

    return PracticeExercise(
      steps: steps,
      metadata: {
        "exerciseType": "dominantCadence",
        "key": key.displayName,
        "handSelection": handSelection.name,
        "includeSeventhChords": includeSeventhChords,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Selects the octave for the I chord so it lands in the same register as V.
  ///
  /// **Triad mode**: Tries [startOctave - 1], [startOctave], and [startOctave + 1]
  /// for the I chord and picks whichever keeps I's lowest note closest to V's lowest
  /// note. Searching three candidates is necessary because register mismatches can
  /// occur in two directions:
  ///
  /// - *I too low*: `getMidiNotes` may bump the V chord up an octave when its
  ///   inversion bass wraps below the root in pitch-class order (e.g. G major 2nd
  ///   inversion: D=2 < G=7 → bumps to octave 5). Without adjustment, I Root at
  ///   octave 4 would be a full octave below V.
  /// - *I too high*: For some keys the tonic's 3rd scale degree sits above the
  ///   dominant root at the same octave (e.g. F major pair 2: A4=69 vs V root
  ///   C4=60, gap 9 semitones). Here I needs to drop to octave 3 to stay close.
  ///
  /// A static offset cannot handle both directions across all 12 keys; proximity
  /// search across three candidates is the robust solution.
  ///
  /// **Seventh chord mode**: Uses [VoiceLeadingUtils.calculateOptimalOctaveForResolution]
  /// to preserve common tones (G and B in C major) at the same MIDI pitch and ensure
  /// smooth voice leading. The voice leading utility accounts for auto-bump behavior
  /// in `getMidiNotes()` and finds the octave that minimizes total voice movement
  /// while keeping common tones stationary.
  int _selectIChordOctave(ChordInfo iChord, List<MidiNote> vBaseNotes) {
    if (vBaseNotes.isEmpty) {
      return startOctave;
    }

    // For seventh chords, use voice leading utility to handle auto-bump complexity
    if (includeSeventhChords) {
      return VoiceLeadingUtils.calculateOptimalOctaveForResolution(
        vBaseNotes,
        iChord,
        startOctave,
        searchRange: 2, // Wider search to handle auto-bump edge cases
      );
    }

    final vMin = vBaseNotes.values.reduce(min);

    var bestOctave = startOctave;
    var bestGap = double.maxFinite;

    for (
      var candidate = startOctave - 1;
      candidate <= startOctave + 1;
      candidate++
    ) {
      final iNotes = iChord.getMidiNotes(candidate);
      if (iNotes.isEmpty) continue;
      final gap = (iNotes.values.reduce(min) - vMin).abs().toDouble();
      if (gap < bestGap) {
        bestGap = gap;
        bestOctave = candidate;
      }
    }

    return bestOctave;
  }

  /// Returns a human-readable destination label for the I (tonic) step.
  static String _iTargetDisplayName(ChordInversion inversion, bool isSeventh) {
    final chordSymbol = isSeventh ? "Imaj7" : "I";
    switch (inversion) {
      case ChordInversion.root:
        return "Target: $chordSymbol Root";
      case ChordInversion.first:
        return "Target: $chordSymbol 1st Inv";
      case ChordInversion.second:
        return "Target: $chordSymbol 2nd Inv";
      case ChordInversion.third:
        return "Target: $chordSymbol 3rd Inv";
    }
  }
}
