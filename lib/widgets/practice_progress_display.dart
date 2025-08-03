import 'package:flutter/material.dart';
import '../utils/chords.dart';
import '../widgets/practice_settings_panel.dart';

class PracticeProgressDisplay extends StatelessWidget {
  final PracticeMode practiceMode;
  final bool practiceActive;
  final List<int> currentSequence;
  final int currentNoteIndex;
  final int currentChordIndex;
  final List<ChordInfo> currentChordProgression;

  const PracticeProgressDisplay({
    super.key,
    required this.practiceMode,
    required this.practiceActive,
    required this.currentSequence,
    required this.currentNoteIndex,
    required this.currentChordIndex,
    required this.currentChordProgression,
  });

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
              'Progress: ${currentNoteIndex + 1}/${currentSequence.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentNoteIndex + 1) / currentSequence.length,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue.shade600,
              ),
            ),
          ] else if (practiceMode == PracticeMode.chords) ...[
            Text(
              'Chord ${currentChordIndex + 1}/${currentChordProgression.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}