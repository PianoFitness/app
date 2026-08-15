import "package:flutter/material.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" hide Key;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/practice/practice_page_view_model.dart";

/// Compact identity and controls for a curriculum-launched practice session.
class FocusedSessionHeader extends StatelessWidget {
  const FocusedSessionHeader({
    required this.viewModel,
    required this.showConfiguration,
    required this.onReset,
    required this.onToggleConfiguration,
    super.key,
  });

  final PracticePageViewModel viewModel;
  final bool showConfiguration;
  final VoidCallback onReset;
  final VoidCallback onToggleConfiguration;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        final session = viewModel.practiceSession;
        if (session == null) return const LinearProgressIndicator();
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          key: const Key("focused_practice_header"),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          child: Row(
            children: [
              Icon(
                session.practiceActive
                    ? Icons.graphic_eq
                    : Icons.play_circle_outline,
                color: colorScheme.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _configurationTitle(session.config),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      session.practiceActive
                          ? "Keep going"
                          : "Play the highlighted notes to begin",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key("practice_reset_button"),
                tooltip: "Reset exercise",
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                key: const Key("practice_configuration_button"),
                tooltip: showConfiguration
                    ? "Hide configuration"
                    : "Configure exercise",
                onPressed: onToggleConfiguration,
                icon: Icon(
                  showConfiguration ? Icons.tune : Icons.tune_outlined,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _configurationTitle(ExerciseConfiguration configuration) {
  final hand = switch (configuration.handSelection) {
    HandSelection.left => "Left hand",
    HandSelection.right => "Right hand",
    HandSelection.both => "Hands together",
  };
  final subject = switch (configuration.practiceMode) {
    PracticeMode.scales =>
      "${configuration.key?.displayName ?? ""} ${configuration.scaleType?.name ?? ""} scale",
    PracticeMode.chordsByKey =>
      "${configuration.key?.displayName ?? ""} chords",
    PracticeMode.chordsByType =>
      "${configuration.chordType?.name ?? "Chord"} chords",
    PracticeMode.arpeggios => "Arpeggio",
    PracticeMode.blockChords => "Block chords",
    PracticeMode.chordProgressions => "Chord progression",
    PracticeMode.brokenChordAccompaniment => "Broken-chord accompaniment",
    PracticeMode.dominantCadence =>
      "${configuration.key?.displayName ?? ""} dominant cadence",
  };
  return "${subject.trim()} · $hand";
}
