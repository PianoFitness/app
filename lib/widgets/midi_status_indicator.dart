import "package:flutter/material.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:provider/provider.dart";

/// A visual indicator showing MIDI activity status.
/// 
/// Displays a circular indicator that changes color based on recent MIDI activity.
/// When tapped, it shows the most recent MIDI message in a snackbar for debugging.
/// Green indicates recent activity, gray indicates no recent activity.
class MidiStatusIndicator extends StatelessWidget {
  /// Creates a new MIDI status indicator widget.
  const MidiStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MidiState>(
      builder: (context, midiState, child) {
        return GestureDetector(
          onTap: () {
            if (midiState.lastNote.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("MIDI: ${midiState.lastNote}"),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: midiState.hasRecentActivity ? Colors.green : Colors.grey.shade400,
            ),
          ),
        );
      },
    );
  }
}
