import "package:flutter/material.dart";

import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_control_panel.dart";

/// Full-screen metronome view: tempo/time-signature controls, a start/stop
/// toggle, and a visual beat pulse synchronized to a lookahead-scheduled
/// click, all bound to the app-wide `MetronomeState` (see
/// [main_navigation.dart]'s app bar icon for the quick-access equivalent
/// available on every page). See
/// docs/specifications/metronome-component.md for the timing design and its
/// realistic accuracy targets.
class MetronomePage extends StatelessWidget {
  /// Creates the metronome page.
  const MetronomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("metronome_page"),
      appBar: AppBar(title: const Text("Metronome")),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Spacing.md),
          child: Column(
            children: [Spacer(), MetronomeControlPanel(), Spacer()],
          ),
        ),
      ),
    );
  }
}
