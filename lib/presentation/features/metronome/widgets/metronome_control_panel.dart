import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/domain/models/metronome/beat_info.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_beat_indicator.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_bpm_control.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_time_signature_selector.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_transport_controls.dart";

/// The core metronome control stack: beat indicator, tempo, time signature,
/// and transport controls, in that order. Shared between `MetronomePage`
/// and `MetronomeQuickPanel` so both surfaces render identically and stay
/// in sync for free.
///
/// Each control is individually scoped with a [Selector] rather than
/// watching [MetronomeState] as a whole: [MetronomeState.currentBeat]
/// changes on every beat (several times a second while playing), and
/// without this, that would rebuild the tempo slider, time-signature
/// chips, and transport buttons on every beat even though none of the
/// values they render changed.
class MetronomeControlPanel extends StatelessWidget {
  /// Creates the control panel.
  const MetronomeControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<MetronomeState>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Selector<MetronomeState, BeatInfo?>(
          selector: (context, metronomeState) => metronomeState.currentBeat,
          builder: (context, beat, child) => MetronomeBeatIndicator(beat: beat),
        ),
        const SizedBox(height: Spacing.md),
        Selector<MetronomeState, ({int bpm, int minBpm, int maxBpm})>(
          selector: (context, metronomeState) => (
            bpm: metronomeState.bpm,
            minBpm: metronomeState.minBpm,
            maxBpm: metronomeState.maxBpm,
          ),
          builder: (context, value, child) => MetronomeBpmControl(state: state),
        ),
        const SizedBox(height: Spacing.lg),
        Selector<MetronomeState, TimeSignature>(
          selector: (context, metronomeState) => metronomeState.timeSignature,
          builder: (context, value, child) =>
              MetronomeTimeSignatureSelector(state: state),
        ),
        const SizedBox(height: Spacing.xl),
        Selector<MetronomeState, ({bool isMuted, bool isPlaying})>(
          selector: (context, metronomeState) => (
            isMuted: metronomeState.isMuted,
            isPlaying: metronomeState.isPlaying,
          ),
          builder: (context, value, child) =>
              MetronomeTransportControls(state: state),
        ),
      ],
    );
  }
}
