import "package:flutter/material.dart";
import "package:piano_fitness/presentation/constants/practice_constants.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Widget displaying exercise active/ready status and reset exercise button.
class PracticeSettingsStatusControl extends StatelessWidget {
  /// Creates the practice status and reset control.
  const PracticeSettingsStatusControl({
    required this.practiceActive,
    required this.onResetPractice,
    super.key,
  });

  /// Key for the practice status container.
  static const Key statusKey = Key("practiceStatusContainer");

  /// Whether practice session is currently active.
  final bool practiceActive;

  /// Callback to reset the exercise.
  final VoidCallback onResetPractice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Semantics(
          liveRegion: true,
          label: practiceActive
              ? "Practice Active - Keep Playing!"
              : "Ready - Play Any Note to Start",
          child: Container(
            key: statusKey,
            padding: PracticeUIConstants.statusContainerPadding,
            decoration: BoxDecoration(
              color: practiceActive
                  ? colorScheme.primaryContainer
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
              border: Border.all(
                color: practiceActive
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.secondary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  practiceActive ? Icons.music_note : Icons.piano,
                  color: practiceActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                  size: PracticeUIConstants.statusIconSize,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  practiceActive
                      ? "Practice Active - Keep Playing!"
                      : "Ready - Play Any Note to Start",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: practiceActive
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ElevatedButton.icon(
          onPressed: onResetPractice,
          icon: const Icon(Icons.refresh),
          label: const Text("Reset Exercise"),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
        ),
      ],
    );
  }
}
