import "package:flutter/material.dart";
import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Mute toggle and start/stop button bound to [MetronomeState].
///
/// Shared between the full [MetronomePage] and the quick-access bottom
/// sheet opened from the app bar.
class MetronomeTransportControls extends StatelessWidget {
  /// Creates transport controls bound to [state].
  const MetronomeTransportControls({required this.state, super.key});

  /// The metronome state to read and mutate.
  final MetronomeState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key("metronome_mute_button"),
          icon: Icon(state.isMuted ? Icons.volume_off : Icons.volume_up),
          tooltip: state.isMuted ? "Unmute" : "Mute",
          onPressed: state.toggleMuted,
        ),
        const SizedBox(width: Spacing.lg),
        FilledButton.icon(
          key: const Key("metronome_start_stop_button"),
          onPressed: state.toggle,
          icon: Icon(state.isPlaying ? Icons.stop : Icons.play_arrow),
          label: Text(state.isPlaying ? "Stop" : "Start"),
        ),
      ],
    );
  }
}
