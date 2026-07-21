import "package:flutter/material.dart";
import "package:piano_fitness/application/state/metronome_state.dart";

/// Tempo display, +/- steppers, and a slider bound to [MetronomeState.bpm].
///
/// Shared between the full [MetronomePage] and the quick-access bottom
/// sheet opened from the app bar, so both surfaces stay in sync for free.
class MetronomeBpmControl extends StatelessWidget {
  /// Creates a BPM control bound to [state].
  const MetronomeBpmControl({required this.state, super.key});

  /// The metronome state to read and mutate.
  final MetronomeState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${state.bpm} BPM",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Row(
          children: [
            IconButton(
              key: const Key("metronome_bpm_decrement"),
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: "Decrease tempo",
              onPressed: state.bpm > state.minBpm
                  ? () => state.setBpm(state.bpm - 1)
                  : null,
            ),
            Expanded(
              child: Slider(
                key: const Key("metronome_bpm_slider"),
                value: state.bpm.toDouble(),
                min: state.minBpm.toDouble(),
                max: state.maxBpm.toDouble(),
                divisions: state.maxBpm - state.minBpm,
                label: "${state.bpm}",
                onChanged: (value) => state.setBpm(value.round()),
              ),
            ),
            IconButton(
              key: const Key("metronome_bpm_increment"),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: "Increase tempo",
              onPressed: state.bpm < state.maxBpm
                  ? () => state.setBpm(state.bpm + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
