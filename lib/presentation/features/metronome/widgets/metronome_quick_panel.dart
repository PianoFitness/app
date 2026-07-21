import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/metronome/metronome_page.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_beat_indicator.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_bpm_control.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_time_signature_selector.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_transport_controls.dart";

/// Quick-access metronome controls, shown in a bottom sheet from the app
/// bar on every page (see `main_navigation.dart`) - the same controls as
/// [MetronomePage], just reachable without leaving whatever the student is
/// doing (Free Play, Reference, a Practice session, ...).
class MetronomeQuickPanel extends StatelessWidget {
  /// Creates the quick panel content for a modal bottom sheet.
  const MetronomeQuickPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MetronomeState>();
    return SafeArea(
      child: Padding(
        key: const Key("metronome_quick_panel"),
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppBorderRadius.xs),
                ),
              ),
            ),
            Text("Metronome", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.md),
            MetronomeBeatIndicator(beat: state.currentBeat),
            const SizedBox(height: Spacing.md),
            MetronomeBpmControl(state: state),
            const SizedBox(height: Spacing.md),
            MetronomeTimeSignatureSelector(state: state),
            const SizedBox(height: Spacing.lg),
            MetronomeTransportControls(state: state),
            const SizedBox(height: Spacing.sm),
            TextButton(
              key: const Key("metronome_open_full_page"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const MetronomePage(),
                  ),
                );
              },
              child: const Text("Open full view"),
            ),
          ],
        ),
      ),
    );
  }
}
