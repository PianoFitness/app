import "package:flutter/material.dart";

import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/metronome/metronome_page.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_control_panel.dart";

/// Quick-access metronome controls, shown in a bottom sheet from the app
/// bar on every page (see `main_navigation.dart`) - the same controls as
/// [MetronomePage], just reachable without leaving whatever the student is
/// doing (Free Play, Reference, a Practice session, ...).
class MetronomeQuickPanel extends StatelessWidget {
  /// Creates the quick panel content for a modal bottom sheet.
  const MetronomeQuickPanel({super.key});

  @override
  Widget build(BuildContext context) {
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
            const MetronomeControlPanel(),
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
