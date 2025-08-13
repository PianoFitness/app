import "package:flutter/material.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/widgets/practice_settings_panel.dart";

/// A widget that displays progress information during active practice sessions.
///
/// Shows different progress indicators based on the practice mode:
/// - Scales/Arpeggios: Progress through note sequence with progress bar
/// - Chords: Current chord in progression with chord name display
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          if (practiceMode == PracticeMode.scales) ...[
            Text(
              "Progress: ${currentNoteIndex + 1}/${currentSequence.length}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentNoteIndex + 1) / currentSequence.length,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ] else if (practiceMode == PracticeMode.chords) ...[
            Text(
              "Chord ${currentChordIndex + 1}/${currentChordProgression.length}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (currentChordIndex < currentChordProgression.length) ...[
              const SizedBox(height: 4),
              Text(
                currentChordProgression[currentChordIndex].name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentChordIndex + 1) / currentChordProgression.length,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
