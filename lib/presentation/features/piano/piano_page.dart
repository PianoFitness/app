import "package:flutter/material.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/play/play_page.dart";
import "package:piano_fitness/presentation/features/reference/reference_page.dart";

/// The shared piano surface for free exploration and musical reference.
class PianoPage extends StatefulWidget {
  /// Creates the combined piano page.
  const PianoPage({super.key});

  @override
  State<PianoPage> createState() => _PianoPageState();
}

enum _PianoMode { play, reference }

class _PianoPageState extends State<PianoPage> {
  _PianoMode _mode = _PianoMode.play;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.sm,
                Spacing.xs,
                Spacing.sm,
                0,
              ),
              child: Center(
                child: SegmentedButton<_PianoMode>(
                  key: const Key("piano_mode_switch"),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _PianoMode.play,
                      icon: Icon(Icons.piano),
                      label: Text("Play"),
                    ),
                    ButtonSegment(
                      value: _PianoMode.reference,
                      icon: Icon(Icons.library_music_outlined),
                      label: Text("Reference"),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) {
                    setState(() => _mode = selection.single);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Expanded(
            child: IndexedStack(
              index: _mode.index,
              children: const [PlayPage(), ReferencePage()],
            ),
          ),
        ],
      ),
    );
  }
}
