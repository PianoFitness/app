import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/midi_state.dart';

class MidiStatusIndicator extends StatelessWidget {
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
                  content: Text('MIDI: ${midiState.lastNote}'),
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
              color: midiState.hasRecentActivity
                  ? Colors.green
                  : Colors.grey.shade400,
            ),
          ),
        );
      },
    );
  }
}