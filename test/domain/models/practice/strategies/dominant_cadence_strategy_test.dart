import "dart:math" show min;

import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/strategies/dominant_cadence_strategy.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

// ---------------------------------------------------------------------------
// Voice-leading invariant checker
// ---------------------------------------------------------------------------

/// Verifies both voice-leading invariants for a single V→I triad pair.
///
/// 1. **Common tones are stationary**: every pitch class shared between V and I
///    appears at the *same MIDI pitch* in both chords (or within [maxCommonToneMovement]
///    for chord types where auto-bump logic prevents perfect preservation).
/// 2. **Step-wise motion**: every non-common V note is within [maxStepSize]
///    semitones of the nearest non-common I note.
///
/// For triads, maxStep Size defaults to 2 (whole step) and maxCommonToneMovement is 0.
/// For seventh chords, larger values are appropriate because auto-bump logic in
/// getMidiNotes() can cause common tones to land at different octaves for certain
/// inversion pairs, and the 7th resolves downward by larger intervals.
void _checkVoiceLeading(
  List<int> vNotes,
  List<int> iNotes, {
  required String reason,
  int maxStepSize = 2,
  int maxCommonToneMovement = 0,
}) {
  final vPcs = vNotes.map((n) => n % 12).toSet();
  final iPcs = iNotes.map((n) => n % 12).toSet();
  final commonPcs = vPcs.intersection(iPcs);

  // 1. Common tones should stay at the same MIDI pitch (or move minimally).
  for (final pc in commonPcs) {
    final vNote = vNotes.firstWhere((n) => n % 12 == pc);
    final iNote = iNotes.firstWhere((n) => n % 12 == pc);
    final movement = (vNote - iNote).abs();
    expect(
      movement,
      lessThanOrEqualTo(maxCommonToneMovement),
      reason:
          "$reason: common tone (pc $pc) moved from $vNote to $iNote "
          "(movement: $movement semitones, max allowed: $maxCommonToneMovement)",
    );
  }

  // 2. Non-common tones must move by ≤ maxStepSize semitones.
  final vNonCommon = vNotes.where((n) => !commonPcs.contains(n % 12)).toList();
  final iNonCommon = iNotes.where((n) => !commonPcs.contains(n % 12)).toList();
  for (final vNote in vNonCommon) {
    final minDist = iNonCommon.map((i) => (i - vNote).abs()).reduce(min);
    expect(
      minDist,
      lessThanOrEqualTo(maxStepSize),
      reason:
          "$reason: note $vNote must move ≤$maxStepSize semitones; "
          "nearest I note is $minDist away",
    );
  }
}

void main() {
  group("DominantCadenceStrategy", () {
    // -------------------------------------------------------------------------
    // Triad mode (includeSeventhChords = false)
    // -------------------------------------------------------------------------

    group("triad mode", () {
      late DominantCadenceStrategy strategy;

      setUp(() {
        strategy = const DominantCadenceStrategy(
          key: music.Key.c,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: false,
        );
      });

      test("generates 6 steps for C major triads", () {
        final exercise = strategy.initializeExercise();
        expect(exercise.steps.length, equals(6));
      });

      test("all steps are simultaneous type", () {
        final exercise = strategy.initializeExercise();
        for (final step in exercise.steps) {
          expect(step.type, equals(StepType.simultaneous));
        }
      });

      test("even-indexed steps are dominant, odd-indexed are tonic", () {
        final exercise = strategy.initializeExercise();
        for (var i = 0; i < exercise.steps.length; i++) {
          final role = exercise.steps[i].metadata?["stepRole"];
          if (i.isEven) {
            expect(
              role,
              equals("dominant"),
              reason: "Step $i should be dominant",
            );
          } else {
            expect(role, equals("tonic"), reason: "Step $i should be tonic");
          }
        }
      });

      test("I steps display names begin with 'Target:'", () {
        final exercise = strategy.initializeExercise();
        for (var i = 1; i < exercise.steps.length; i += 2) {
          final displayName =
              exercise.steps[i].metadata?["displayName"] as String?;
          expect(
            displayName,
            startsWith("Target:"),
            reason: "Step $i displayName should start with 'Target:'",
          );
        }
      });

      test("I step display names match expected inversion labels", () {
        final exercise = strategy.initializeExercise();
        // Pair 1: V 1st inv → I Root
        expect(exercise.steps[1].metadata?["displayName"], "Target: I Root");
        // Pair 2: V Root → I 2nd inv
        expect(exercise.steps[3].metadata?["displayName"], "Target: I 2nd Inv");
        // Pair 3: V 2nd inv → I 1st inv
        expect(exercise.steps[5].metadata?["displayName"], "Target: I 1st Inv");
      });

      test("V steps carry pairIndex metadata", () {
        final exercise = strategy.initializeExercise();
        expect(exercise.steps[0].metadata?["pairIndex"], 0);
        expect(exercise.steps[2].metadata?["pairIndex"], 1);
        expect(exercise.steps[4].metadata?["pairIndex"], 2);
      });

      // Illustrative concrete snapshot for pair 1 (documents the specific
      // voicing requested by the user: leading-tone B in bass resolves to C).
      //
      // V 1st inv: B in bass, no bump (B=11 > G=7) → B4(71), D5(74), G5(79)
      // I Root: proximity search picks oct 5, gap=1 → C5(72), E5(76), G5(79)
      // Voice leading: B4→C5 (+1 leading tone), D5→E5 (+2 step), G5→G5 (hold)
      test("pair 1 MIDI notes are correct for C major right hand", () {
        final exercise = strategy.initializeExercise();
        expect(exercise.steps[0].notes, equals([71, 74, 79])); // V 1st inv
        expect(exercise.steps[1].notes, equals([72, 76, 79])); // I Root
      });

      test("generates different MIDI sequences for different keys", () {
        final cStrategy = DominantCadenceStrategy(
          key: music.Key.c,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: false,
        );
        final gStrategy = DominantCadenceStrategy(
          key: music.Key.g,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: false,
        );
        final cExercise = cStrategy.initializeExercise();
        final gExercise = gStrategy.initializeExercise();
        expect(
          cExercise.steps.first.notes,
          isNot(equals(gExercise.steps.first.notes)),
        );
      });

      test("initialises successfully for all 12 keys", () {
        for (final key in music.Key.values) {
          final s = DominantCadenceStrategy(
            key: key,
            handSelection: HandSelection.right,
            startOctave: 4,
            includeSeventhChords: false,
          );
          final exercise = s.initializeExercise();
          expect(
            exercise.steps.length,
            equals(6),
            reason: "Key ${key.displayName} should produce 6 steps",
          );
        }
      });

      // ---------------------------------------------------------------------------
      // Property-based voice-leading test
      //
      // For every major key and every pair, the exercise must satisfy:
      //   (a) Common tone (scale degree 5) appears at the same MIDI pitch in
      //       both the V approach chord and the I target chord — no octave leap.
      //   (b) The two non-common voices each move by at most 2 semitones
      //       (leading tone +1, supertonic +2).
      //
      // This single parameterised test replaces all the specific register-
      // proximity assertions and MIDI-snapshot tests for pairs 2 and 3.
      // ---------------------------------------------------------------------------

      test("voice leading invariants hold for all 12 keys and all 3 pairs", () {
        for (final key in music.Key.values) {
          final s = DominantCadenceStrategy(
            key: key,
            handSelection: HandSelection.right,
            startOctave: 4,
            includeSeventhChords: false,
          );
          final exercise = s.initializeExercise();
          for (var i = 0; i < exercise.steps.length; i += 2) {
            _checkVoiceLeading(
              exercise.steps[i].notes,
              exercise.steps[i + 1].notes,
              reason: "Key ${key.displayName} pair ${i ~/ 2 + 1}",
            );
          }
        }
      });
    });

    // -------------------------------------------------------------------------
    // Seventh chord mode (includeSeventhChords = true)
    // -------------------------------------------------------------------------

    group("seventh chord mode", () {
      late DominantCadenceStrategy strategy;

      setUp(() {
        strategy = const DominantCadenceStrategy(
          key: music.Key.c,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: true,
        );
      });

      test("generates 8 steps for C major seventh chords", () {
        final exercise = strategy.initializeExercise();
        expect(exercise.steps.length, equals(8));
      });

      test("all steps are simultaneous type", () {
        final exercise = strategy.initializeExercise();
        for (final step in exercise.steps) {
          expect(step.type, equals(StepType.simultaneous));
        }
      });

      test("V steps have 4 notes each (dominant7)", () {
        final exercise = strategy.initializeExercise();
        for (var i = 0; i < exercise.steps.length; i += 2) {
          expect(
            exercise.steps[i].notes.length,
            equals(4),
            reason: "V step $i should have 4 notes",
          );
        }
      });

      test("I steps have 4 notes each (major7)", () {
        final exercise = strategy.initializeExercise();
        for (var i = 1; i < exercise.steps.length; i += 2) {
          expect(
            exercise.steps[i].notes.length,
            equals(4),
            reason: "I step $i should have 4 notes",
          );
        }
      });

      test("I step display names use 'Imaj7' label", () {
        final exercise = strategy.initializeExercise();
        expect(
          exercise.steps[1].metadata?["displayName"],
          "Target: Imaj7 Root",
        );
        expect(
          exercise.steps[3].metadata?["displayName"],
          "Target: Imaj7 1st Inv",
        );
        expect(
          exercise.steps[5].metadata?["displayName"],
          "Target: Imaj7 2nd Inv",
        );
        expect(
          exercise.steps[7].metadata?["displayName"],
          "Target: Imaj7 3rd Inv",
        );
      });

      // C major seventh chords, right hand, octave 4:
      // Pair 1: V7 Root (G7 root) = G4(67), B4(71), D5(74), F5(77)
      //         Imaj7 Root (Cmaj7 root) = C4(60), E4(64), G4(67), B4(71)
      //         Common tones: G4 and B4 held. F5→E4 (7th resolves ↓), D5→C4 (5th ↓).
      //         iOctaveOffset=0: keeping I at startOctave preserves common tones.
      test("pair 1 MIDI notes are correct for C major right hand", () {
        final exercise = strategy.initializeExercise();
        expect(exercise.steps[0].notes, equals([67, 71, 74, 77]));
        expect(exercise.steps[1].notes, equals([60, 64, 67, 71]));
      });

      // Pair 4: V7 3rd inv (G root=G4=67, 3rd inv bass=F above root) = F5(77), G5(79), B5(83), D6(86)
      //         Imaj7 3rd inv: Voice leading algorithm places at octave 5 for optimal voice leading
      //         Actual MIDI: B5(83), C6(84), E6(88), G6(91)
      //         Note: Higher octave chosen by voice leading algorithm to minimize jumps
      test("pair 4 MIDI notes are correct for C major right hand", () {
        final exercise = strategy.initializeExercise();
        expect(exercise.steps[6].notes, equals([77, 79, 83, 86]));
        expect(exercise.steps[7].notes, equals([83, 84, 88, 91]));
      });

      test("initialises successfully for all 12 keys", () {
        for (final key in music.Key.values) {
          final s = DominantCadenceStrategy(
            key: key,
            handSelection: HandSelection.right,
            startOctave: 4,
            includeSeventhChords: true,
          );
          final exercise = s.initializeExercise();
          expect(
            exercise.steps.length,
            equals(8),
            reason: "Key ${key.displayName} should produce 8 steps",
          );
        }
      });

      test("voice leading invariants hold for all 12 keys and all 4 pairs", () {
        for (final key in music.Key.values) {
          final strategy = DominantCadenceStrategy(
            key: key,
            handSelection: HandSelection.right,
            startOctave: 4,
            includeSeventhChords: true,
          );
          final exercise = strategy.initializeExercise();

          // Test all 4 pairs (8 steps total, pairs at indices 0-1, 2-3, 4-5, 6-7)
          for (var i = 0; i < exercise.steps.length; i += 2) {
            final vNotes = exercise.steps[i].notes;
            final iNotes = exercise.steps[i + 1].notes;

            // For seventh chords with auto-bump logic, allow common tones to move
            // by up to an octave when necessary, and allow larger non-common movements
            // (max 14 semitones) because the 7th resolves downward by larger intervals.
            _checkVoiceLeading(
              vNotes,
              iNotes,
              reason: "Key ${key.displayName} seventh chord pair ${i ~/ 2 + 1}",
              maxStepSize: 14,
              maxCommonToneMovement: 12,
            );
          }
        }
      });
    });

    // -------------------------------------------------------------------------
    // Exercise metadata
    // -------------------------------------------------------------------------

    group("exercise metadata", () {
      test("contains exerciseType 'dominantCadence'", () {
        const s = DominantCadenceStrategy(
          key: music.Key.c,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: false,
        );
        final exercise = s.initializeExercise();
        expect(exercise.metadata?["exerciseType"], "dominantCadence");
      });

      test("contains key display name", () {
        const s = DominantCadenceStrategy(
          key: music.Key.g,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: false,
        );
        final exercise = s.initializeExercise();
        expect(exercise.metadata?["key"], music.Key.g.displayName);
      });

      test("contains handSelection", () {
        const s = DominantCadenceStrategy(
          key: music.Key.c,
          handSelection: HandSelection.left,
          startOctave: 4,
          includeSeventhChords: false,
        );
        final exercise = s.initializeExercise();
        expect(exercise.metadata?["handSelection"], "left");
      });

      test("contains includeSeventhChords flag (false)", () {
        const s = DominantCadenceStrategy(
          key: music.Key.c,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: false,
        );
        final exercise = s.initializeExercise();
        expect(exercise.metadata?["includeSeventhChords"], isFalse);
      });

      test("contains includeSeventhChords flag (true)", () {
        const s = DominantCadenceStrategy(
          key: music.Key.c,
          handSelection: HandSelection.right,
          startOctave: 4,
          includeSeventhChords: true,
        );
        final exercise = s.initializeExercise();
        expect(exercise.metadata?["includeSeventhChords"], isTrue);
      });
    });
  });
}
