import "package:flutter/material.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:provider/provider.dart";

/// A complete MIDI controls widget that includes both status indicator and settings button.
///
/// This widget combines the MIDI activity indicator with the settings gear icon,
/// providing a consistent way to access MIDI functionality across all pages.
/// The status indicator shows recent MIDI activity (green = active, gray = inactive)
/// and can be tapped to show the last received MIDI message. The settings button
/// opens the MIDI configuration page.
class MidiControls extends StatelessWidget {
  /// Creates a new MIDI controls widget.
  const MidiControls({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if MidiState provider is available
    try {
      Provider.of<MidiState>(context, listen: false);
    } catch (e) {
      // Provider not available, return empty widget or fallback
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MIDI Activity Indicator
        Consumer<MidiState>(
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
                margin: const EdgeInsets.only(right: 8),
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
        ),
        // MIDI Settings Button
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            try {
              final midiState = Provider.of<MidiState>(context, listen: false);
              final result = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                  builder: (context) => MidiSettingsPage(
                    initialChannel: midiState.selectedChannel,
                  ),
                ),
              );
              if (result != null && result != midiState.selectedChannel) {
                // Channel changed, update the provider
                midiState.setSelectedChannel(result);
              }
            } catch (e) {
              // Handle case where MidiState provider is not available
              debugPrint("MidiState provider not found: $e");
            }
          },
          tooltip: "MIDI Settings",
        ),
      ],
    );
  }
}
