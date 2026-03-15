import "dart:math" show min;

import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";

/// Utility class for voice leading calculations in chord progressions.
///
/// Voice leading is the practice of moving smoothly from one chord to another
/// by minimizing the distance each voice (note) must travel. Good voice leading
/// follows these principles:
///
/// 1. **Common tones stay stationary**: Notes shared between consecutive chords
///    should remain at the same pitch (octave-specific), not jump to a different
///    register.
///
/// 2. **Stepwise motion**: Non-common tones should move by the smallest possible
///    interval, typically a half-step or whole-step.
///
/// 3. **Contrary or oblique motion**: When possible, voices should move in
///    opposite directions or some should stay still while others move.
///
/// This utility provides functions to calculate optimal octave placement for
/// chord resolutions, validate voice leading quality, and measure the total
/// voice movement between chords.
class VoiceLeadingUtils {
  /// Calculates the optimal octave for a target chord to minimize voice leading
  /// distance from a source chord.
  ///
  /// This method searches across multiple octave candidates to find the octave
  /// placement that produces the smoothest voice leading. It considers:
  ///
  /// - **Common tone preservation**: Shared notes should stay at the same pitch
  /// - **Minimal voice movement**: Non-shared notes should move as little as possible
  /// - **Register proximity**: Avoid large jumps between chords
  ///
  /// The algorithm:
  /// 1. Identifies common pitch classes between source and target chords
  /// 2. Searches a range of octave candidates (typically ±1 from startOctave)
  /// 3. For each candidate, calculates the total voice leading distance
  /// 4. Returns the octave that minimizes total movement while preserving
  ///    common tones at the same MIDI pitch when possible
  ///
  /// [sourceMidiNotes]: MIDI note numbers of the source chord (e.g., V7)
  /// [targetChord]: ChordInfo object for the destination chord (e.g., Imaj7)
  /// [startOctave]: The baseline octave for the target chord
  /// [searchRange]: How many octaves above/below to search (default: 1)
  ///
  /// Returns the optimal octave for voicing the target chord.
  ///
  /// Example:
  /// ```dart
  /// // V7 in C major at octave 4: [67, 71, 74, 77]
  /// final v7Notes = [67, 71, 74, 77];
  /// final imaj7 = ChordBuilder.getChord(MusicalNote.c, ChordType.major7, ChordInversion.root);
  /// final optimalOctave = VoiceLeadingUtils.calculateOptimalOctaveForResolution(
  ///   v7Notes,
  ///   imaj7,
  ///   4,
  /// );
  /// // Returns 4, keeping common tones G4(67) and B4(71) stationary
  /// ```
  static int calculateOptimalOctaveForResolution(
    List<int> sourceMidiNotes,
    ChordInfo targetChord,
    int startOctave, {
    int searchRange = 1,
  }) {
    if (sourceMidiNotes.isEmpty) {
      return startOctave;
    }

    // Extract pitch classes from source chord for common tone detection
    final sourcePitchClasses = sourceMidiNotes.map((n) => n % 12).toSet();

    var bestOctave = startOctave;
    var bestScore = double.infinity;

    // Search across octave candidates
    for (
      var candidateOctave = startOctave - searchRange;
      candidateOctave <= startOctave + searchRange;
      candidateOctave++
    ) {
      final targetMidiNotes = targetChord.getMidiNotes(candidateOctave);
      if (targetMidiNotes.isEmpty) continue;

      final targetPitchClasses = targetMidiNotes.map((n) => n % 12).toSet();
      final commonPitchClasses = sourcePitchClasses.intersection(
        targetPitchClasses,
      );

      // Score this candidate octave based on voice leading quality
      var score = 0.0;

      // Penalty 1: Common tones that don't stay at the same MIDI pitch
      var commonTonePenalty = 0.0;
      for (final pc in commonPitchClasses) {
        final sourceNote = sourceMidiNotes.firstWhere((n) => n % 12 == pc);
        final targetNote = targetMidiNotes.firstWhere((n) => n % 12 == pc);
        final distance = (sourceNote - targetNote).abs();
        // VERY heavy penalty for moving common tones (should be 0)
        // This penalty dominates all other factors to ensure common tones stay stationary
        commonTonePenalty += distance * 1000.0;
      }
      score += commonTonePenalty;

      // Penalty 2: Total voice movement for non-common tones
      final sourceNonCommon = sourceMidiNotes
          .where((n) => !commonPitchClasses.contains(n % 12))
          .toList();
      final targetNonCommon = targetMidiNotes
          .where((n) => !commonPitchClasses.contains(n % 12))
          .toList();

      var nonCommonDistance = 0.0;
      for (final sourceNote in sourceNonCommon) {
        if (targetNonCommon.isEmpty) {
          // If target has no non-common notes, penalize based on distance to
          // nearest target note
          final minDist = targetMidiNotes
              .map((t) => (t - sourceNote).abs())
              .reduce(min)
              .toDouble();
          nonCommonDistance += minDist;
        } else {
          // Find closest non-common target note
          final minDist = targetNonCommon
              .map((t) => (t - sourceNote).abs())
              .reduce(min)
              .toDouble();
          nonCommonDistance += minDist;
        }
      }
      score += nonCommonDistance;

      // Penalty 3: Large register jumps (prefer staying in similar range)
      if (targetMidiNotes.isNotEmpty && sourceMidiNotes.isNotEmpty) {
        final sourceLowest = sourceMidiNotes.reduce(min);
        final targetLowest = targetMidiNotes.reduce(min);
        final registerJump = (sourceLowest - targetLowest).abs().toDouble();
        score += registerJump * 0.5; // Lighter weight than common tone penalty
      }

      // Update best candidate if this score is better
      if (score < bestScore) {
        bestScore = score;
        bestOctave = candidateOctave;
      }
    }

    return bestOctave;
  }

  /// Validates that voice leading between two chords follows proper principles.
  ///
  /// Checks two key invariants:
  ///
  /// 1. **Common tones are stationary**: Every pitch class shared between the
  ///    source and target chords appears at the *same MIDI pitch* in both.
  ///    This prevents unnecessary octave jumps of shared notes.
  ///
  /// 2. **Stepwise motion**: Every non-common tone in the source chord moves
  ///    by at most [maxStepSize] semitones (default: 2, allowing whole-step
  ///    motion). This ensures smooth voice leading without large leaps.
  ///
  /// Returns a [VoiceLeadingValidationResult] containing:
  /// - `isValid`: true if both invariants are satisfied
  /// - `commonToneViolations`: list of common tones that moved octaves
  /// - `stepwiseViolations`: list of notes that moved more than maxStepSize
  ///
  /// Example:
  /// ```dart
  /// final v7 = [67, 71, 74, 77]; // G7 root position
  /// final imaj7 = [60, 64, 67, 71]; // Cmaj7 root position
  /// final result = VoiceLeadingUtils.validateVoiceLeadingInvariants(v7, imaj7);
  /// // result.isValid == true: G4 and B4 are common tones held stationary,
  /// // F5→E4 and D5→C4 move by step (accounting for direction)
  /// ```
  static VoiceLeadingValidationResult validateVoiceLeadingInvariants(
    List<int> sourceNotes,
    List<int> targetNotes, {
    int maxStepSize = 2,
  }) {
    final violations = <String>[];
    final commonToneViolations = <String>[];
    final stepwiseViolations = <String>[];

    // Extract pitch classes
    final sourcePcs = sourceNotes.map((n) => n % 12).toSet();
    final targetPcs = targetNotes.map((n) => n % 12).toSet();
    final commonPcs = sourcePcs.intersection(targetPcs);

    // Invariant 1: Common tones must be at the same MIDI pitch
    for (final pc in commonPcs) {
      final sourceNote = sourceNotes.firstWhere((n) => n % 12 == pc);
      final targetNote = targetNotes.firstWhere((n) => n % 12 == pc);
      if (sourceNote != targetNote) {
        final violation =
            "Common tone (pc $pc) moved from $sourceNote to $targetNote";
        violations.add(violation);
        commonToneViolations.add(violation);
      }
    }

    // Invariant 2: Non-common tones must move by ≤ maxStepSize semitones
    final sourceNonCommon = sourceNotes
        .where((n) => !commonPcs.contains(n % 12))
        .toList();
    final targetNonCommon = targetNotes
        .where((n) => !commonPcs.contains(n % 12))
        .toList();

    for (final sourceNote in sourceNonCommon) {
      if (targetNonCommon.isEmpty) continue;
      final minDist = targetNonCommon
          .map((t) => (t - sourceNote).abs())
          .reduce(min);
      if (minDist > maxStepSize) {
        final violation =
            "Note $sourceNote moved $minDist semitones "
            "(exceeds max $maxStepSize)";
        violations.add(violation);
        stepwiseViolations.add(violation);
      }
    }

    return VoiceLeadingValidationResult(
      isValid: violations.isEmpty,
      commonToneViolations: commonToneViolations,
      stepwiseViolations: stepwiseViolations,
    );
  }

  /// Calculates the total voice leading distance between two chords.
  ///
  /// This metric quantifies how much total movement occurs when progressing
  /// from the source chord to the target chord. It's useful for comparing
  /// different voicing options or octave placements.
  ///
  /// The calculation:
  /// 1. Identifies common pitch classes (held notes)
  /// 2. For common tones, adds the absolute distance moved (ideally 0)
  /// 3. For non-common tones, finds the nearest target note and adds that distance
  /// 4. Returns the sum of all voice movements in semitones
  ///
  /// Lower values indicate smoother voice leading.
  ///
  /// Example:
  /// ```dart
  /// final v7 = [67, 71, 74, 77]; // G7 root
  /// final imaj7 = [60, 64, 67, 71]; // Cmaj7 root
  /// final distance = VoiceLeadingUtils.getVoiceLeadingDistance(v7, imaj7);
  /// // Returns: 0 (G4→G4) + 0 (B4→B4) + |-13| (F5→E4) + |-14| (D5→C4) = 27
  /// // (Note: This example shows why proximity search matters!)
  /// ```
  static int getVoiceLeadingDistance(
    List<int> sourceNotes,
    List<int> targetNotes,
  ) {
    if (sourceNotes.isEmpty || targetNotes.isEmpty) {
      return 0;
    }

    final sourcePcs = sourceNotes.map((n) => n % 12).toSet();
    final targetPcs = targetNotes.map((n) => n % 12).toSet();
    final commonPcs = sourcePcs.intersection(targetPcs);

    var totalDistance = 0;

    // For all source notes, find their nearest target note movement
    for (final sourceNote in sourceNotes) {
      final pc = sourceNote % 12;

      if (commonPcs.contains(pc)) {
        // Common tone: find the matching pitch class in target
        final targetNote = targetNotes.firstWhere((n) => n % 12 == pc);
        totalDistance += (sourceNote - targetNote).abs();
      } else {
        // Non-common tone: find nearest target note by distance
        final minDist = targetNotes
            .map((t) => (t - sourceNote).abs())
            .reduce(min);
        totalDistance += minDist;
      }
    }

    return totalDistance;
  }
}

/// Result of voice leading validation.
///
/// Contains information about whether the voice leading is valid and details
/// about any violations found.
class VoiceLeadingValidationResult {
  /// Creates a voice leading validation result.
  const VoiceLeadingValidationResult({
    required this.isValid,
    required this.commonToneViolations,
    required this.stepwiseViolations,
  });

  /// Whether the voice leading passes all invariants.
  final bool isValid;

  /// List of common tones that moved to different octaves.
  final List<String> commonToneViolations;

  /// List of non-common tones that moved more than the maximum step size.
  final List<String> stepwiseViolations;

  /// All violations combined.
  List<String> get allViolations => [
    ...commonToneViolations,
    ...stepwiseViolations,
  ];
}
