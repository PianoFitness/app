import "package:flutter/material.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/chords.dart";

/// A widget that displays progress information during active practice sessions.
///
/// Shows different progress indicators based on the practice mode:
/// - Scales/Arpeggios: Progress through note sequence with progress bar
/// - Chords/ChordProgressions: Current chord in progression with chord name display
///
/// Only visible when a practice session is active.
class PracticeProgressDisplay extends StatelessWidget {
  /// Creates a practice progress display with all required state information.
  const PracticeProgressDisplay({
    required this.practiceMode,
    required this.practiceActive,
    required this.currentSequence,
    required this.currentNoteIndex,
    required this.currentChordIndex,
    required this.currentChordProgression,
    super.key,
  });

  /// The current practice mode (determines display format).
  final PracticeMode practiceMode;

  /// Whether a practice session is currently active.
  final bool practiceActive;

  /// The current sequence of notes being practiced.
  final List<int> currentSequence;

  /// The index of the next note to be played in the sequence.
  final int currentNoteIndex;

  /// The index of the current chord in chord progression mode.
  final int currentChordIndex;

  /// The current chord progression for chord practice mode.
  final List<ChordInfo> currentChordProgression;

  @override
  Widget build(BuildContext context) {
    if (!practiceActive || currentSequence.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          if (practiceMode == PracticeMode.scales ||
              practiceMode == PracticeMode.arpeggios) ...[
            Text(
              "Progress: ${currentNoteIndex + 1}/${currentSequence.length}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentNoteIndex + 1) / currentSequence.length,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              semanticsLabel: practiceMode == PracticeMode.scales
                  ? "Scale practice progress"
                  : "Arpeggio practice progress",
              semanticsValue:
                  "${currentNoteIndex + 1} of ${currentSequence.length}",
            ),
          ] else if (practiceMode == PracticeMode.chordsByKey ||
              practiceMode == PracticeMode.chordsByType ||
              practiceMode == PracticeMode.chordProgressions) ...[
            Text(
              "${practiceMode == PracticeMode.chordProgressions ? "Progression" : "Chord"} ${currentChordIndex + 1}/${currentChordProgression.length}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            if (currentChordIndex < currentChordProgression.length) ...[
              const SizedBox(height: 4),
              Text(
                currentChordProgression[currentChordIndex].name,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentChordIndex + 1) / currentChordProgression.length,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              semanticsLabel: practiceMode == PracticeMode.chordsByKey
                  ? "Chord practice progress"
                  : practiceMode == PracticeMode.chordsByType
                  ? "Chord type practice progress"
                  : "Chord progression practice progress",
              semanticsValue:
                  "${currentChordIndex + 1} of ${currentChordProgression.length}",
            ),
          ],
        ],
      ),
    );
  }
}
