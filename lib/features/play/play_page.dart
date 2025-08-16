import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/features/play/play_page_view_model.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/piano_range_utils.dart";
import "package:provider/provider.dart";

/// The main page of the Piano Fitness application.
///
/// This page serves as the home screen and primary interface for piano interaction.
/// It provides access to practice modes, MIDI settings, and displays an interactive
/// piano keyboard for both MIDI input and virtual note playing.
class PlayPage extends StatefulWidget {
  /// Creates the main play page with optional MIDI channel configuration.
  ///
  /// The [midiChannel] parameter sets the default MIDI channel for input/output.
  const PlayPage({super.key, this.midiChannel = 0});

  /// The MIDI channel to use for input and output operations (0-15).
  final int midiChannel;

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late final PlayPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PlayPageViewModel(initialChannel: widget.midiChannel);

    // Initialize the MIDI channel in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final midiState = Provider.of<MidiState>(context, listen: false);
      _viewModel.setMidiState(midiState);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.piano, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text("Piano Fitness"),
          ],
        ),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
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
            },
            tooltip: "MIDI Settings",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Educational Content Area
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.piano,
                            size: 32,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Free Play Mode",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Explore and play freely with the interactive piano. "
                            "Connect a MIDI keyboard for enhanced experience or use the virtual keys below.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.deepPurple.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.deepPurple.shade600,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Looking for structured practice? Visit the Practice tab!",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.deepPurple.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MidiState>(
              builder: (context, midiState, child) {
                // Define a fixed 49-key range for consistent layout
                final fixed49KeyRange = PianoRangeUtils.standard49KeyRange;

                // Calculate dynamic key width based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final dynamicKeyWidth =
                    PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);

                return InteractivePiano(
                  highlightedNotes: midiState.highlightedNotePositions,
                  keyWidth: dynamicKeyWidth.clamp(
                    PianoRangeUtils.minKeyWidth,
                    PianoRangeUtils.maxKeyWidth,
                  ),
                  noteRange: fixed49KeyRange,
                  onNotePositionTapped: (position) {
                    final midiNote = NoteUtils.convertNotePositionToMidi(
                      position,
                    );
                    _viewModel.playVirtualNote(midiNote);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
