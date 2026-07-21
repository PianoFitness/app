import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:piano_fitness/domain/repositories/metronome_audio_service.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/metronome/metronome_page_view_model.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_beat_indicator.dart";

/// Metronome page: tempo/time-signature controls, a start/stop toggle, and
/// a visual beat pulse synchronized to a lookahead-scheduled click. See
/// docs/specifications/metronome-component.md for the timing design and its
/// realistic accuracy targets.
class MetronomePage extends StatelessWidget {
  /// Creates the metronome page.
  const MetronomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MetronomePageViewModel(
        audioService: context.read<IMetronomeAudioService>(),
      ),
      child: const _MetronomeView(),
    );
  }
}

class _MetronomeView extends StatelessWidget {
  const _MetronomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("metronome_page"),
      appBar: AppBar(title: const Text("Metronome")),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: context.watch<MetronomePageViewModel>(),
          builder: (context, child) {
            final viewModel = context.read<MetronomePageViewModel>();
            return Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                children: [
                  const Spacer(),
                  MetronomeBeatIndicator(beat: viewModel.currentBeat),
                  const Spacer(),
                  _BpmControl(viewModel: viewModel),
                  const SizedBox(height: Spacing.lg),
                  _TimeSignatureSelector(viewModel: viewModel),
                  const SizedBox(height: Spacing.xl),
                  _TransportControls(viewModel: viewModel),
                  const SizedBox(height: Spacing.md),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BpmControl extends StatelessWidget {
  const _BpmControl({required this.viewModel});

  final MetronomePageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${viewModel.bpm} BPM",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Row(
          children: [
            IconButton(
              key: const Key("metronome_bpm_decrement"),
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: "Decrease tempo",
              onPressed: viewModel.bpm > viewModel.minBpm
                  ? () => viewModel.setBpm(viewModel.bpm - 1)
                  : null,
            ),
            Expanded(
              child: Slider(
                key: const Key("metronome_bpm_slider"),
                value: viewModel.bpm.toDouble(),
                min: viewModel.minBpm.toDouble(),
                max: viewModel.maxBpm.toDouble(),
                divisions: viewModel.maxBpm - viewModel.minBpm,
                label: "${viewModel.bpm}",
                onChanged: (value) => viewModel.setBpm(value.round()),
              ),
            ),
            IconButton(
              key: const Key("metronome_bpm_increment"),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: "Increase tempo",
              onPressed: viewModel.bpm < viewModel.maxBpm
                  ? () => viewModel.setBpm(viewModel.bpm + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeSignatureSelector extends StatelessWidget {
  const _TimeSignatureSelector({required this.viewModel});

  final MetronomePageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key("metronome_time_signature_selector"),
      spacing: Spacing.sm,
      children: [
        for (final signature in viewModel.availableTimeSignatures)
          ChoiceChip(
            key: Key(
              "metronome_time_signature_${signature.numerator}_${signature.denominator}",
            ),
            label: Text(signature.label),
            selected: viewModel.timeSignature == signature,
            onSelected: (_) => viewModel.setTimeSignature(signature),
          ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({required this.viewModel});

  final MetronomePageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key("metronome_mute_button"),
          icon: Icon(viewModel.isMuted ? Icons.volume_off : Icons.volume_up),
          tooltip: viewModel.isMuted ? "Unmute" : "Mute",
          onPressed: viewModel.toggleMuted,
        ),
        const SizedBox(width: Spacing.lg),
        FilledButton.icon(
          key: const Key("metronome_start_stop_button"),
          onPressed: viewModel.toggle,
          icon: Icon(viewModel.isPlaying ? Icons.stop : Icons.play_arrow),
          label: Text(viewModel.isPlaying ? "Stop" : "Start"),
        ),
      ],
    );
  }
}
