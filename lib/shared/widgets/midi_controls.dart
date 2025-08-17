import "package:flutter/material.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_page.dart";

/// A MIDI controls widget that provides access to MIDI settings.
///
/// This widget provides a consistent way to access MIDI functionality across all pages.
/// Since each page now manages its own local MIDI state, this widget focuses on
/// providing access to global MIDI settings and device management.
class MidiControls extends StatelessWidget {
  /// Creates a new MIDI controls widget.
  const MidiControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MIDI Settings Button
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            // Open MIDI settings with default channel
            await Navigator.of(context).push<int>(
              MaterialPageRoute(builder: (context) => const MidiSettingsPage()),
            );
          },
          tooltip: "MIDI Settings",
        ),
      ],
    );
  }
}
