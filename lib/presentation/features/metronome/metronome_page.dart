import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_beat_indicator.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_bpm_control.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_time_signature_selector.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_transport_controls.dart";

/// Full-screen metronome view: tempo/time-signature controls, a start/stop
/// toggle, and a visual beat pulse synchronized to a lookahead-scheduled
/// click, all bound to the app-wide [MetronomeState] (see
/// [main_navigation.dart]'s app bar icon for the quick-access equivalent
/// available on every page). See
/// docs/specifications/metronome-component.md for the timing design and its
/// realistic accuracy targets.
class MetronomePage extends StatelessWidget {
  /// Creates the metronome page.
  const MetronomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MetronomeState>();
    return Scaffold(
      key: const Key("metronome_page"),
      appBar: AppBar(title: const Text("Metronome")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            children: [
              const Spacer(),
              MetronomeBeatIndicator(beat: state.currentBeat),
              const Spacer(),
              MetronomeBpmControl(state: state),
              const SizedBox(height: Spacing.lg),
              MetronomeTimeSignatureSelector(state: state),
              const SizedBox(height: Spacing.xl),
              MetronomeTransportControls(state: state),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
