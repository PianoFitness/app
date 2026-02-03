import "package:flutter/material.dart";
import "package:piano_fitness/domain/constants/practice_constants.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";
import "package:piano_fitness/shared/utils/practice_accessibility_utils.dart";

/// A widget that displays progress information during active practice sessions.
///
/// Shows a unified progress display with "Step X/Y" format and optional
/// step display names (e.g., "Degree 1 (Right Hand)", "C Major", "I: C Major").
///
/// Only visible when a practice session is active.
class PracticeProgressDisplay extends StatelessWidget {
  /// Creates a practice progress display with all required state information.
  const PracticeProgressDisplay({
    required this.practiceMode,
    required this.practiceActive,
    required this.currentExercise,
    required this.currentStepIndex,
    super.key,
  });

  /// The current practice mode (determines accessibility labels).
  final PracticeMode practiceMode;

  /// Whether a practice session is currently active.
  final bool practiceActive;

  /// The current exercise being practiced.
  final PracticeExercise? currentExercise;

  /// The index of the current step in the exercise.
  final int currentStepIndex;

  @override
  Widget build(BuildContext context) {
    // Don't show if practice isn't active or exercise is null/empty
    if (!practiceActive ||
        currentExercise == null ||
        currentExercise!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exercise = currentExercise!;
    final totalSteps = exercise.length;

    // Get step display name if available
    String? stepDisplayName;
    if (currentStepIndex < exercise.steps.length) {
      stepDisplayName =
          exercise.steps[currentStepIndex].metadata?["displayName"] as String?;
    }

    // Generate accessibility label
    final accessibilityLabel = currentStepIndex < exercise.steps.length
        ? PracticeAccessibilityUtils.getStepSemanticLabel(
            exercise.steps[currentStepIndex],
            currentStepIndex + 1,
            totalSteps,
          )
        : _getPracticeModeLabel(practiceMode);

    return Container(
      key: const Key("ppd_container"),
      padding: PracticeUIConstants.progressPadding,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            "Step ${currentStepIndex + 1}/$totalSteps",
            style:
                theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ) ??
                TextStyle(color: colorScheme.onSurface),
          ),
          if (stepDisplayName != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              stepDisplayName,
              style:
                  theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ) ??
                  TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          LinearProgressIndicator(
            value: ((currentStepIndex + 1).clamp(0, totalSteps)) / totalSteps,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            semanticsLabel: accessibilityLabel,
            semanticsValue: "${currentStepIndex + 1} of $totalSteps",
          ),
        ],
      ),
    );
  }

  /// Returns a human-readable label for the practice mode.
  String _getPracticeModeLabel(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.scales:
        return "Scale practice progress";
      case PracticeMode.arpeggios:
        return "Arpeggio practice progress";
      case PracticeMode.chordsByKey:
        return "Chord practice progress";
      case PracticeMode.chordsByType:
        return "Chord type practice progress";
      case PracticeMode.chordProgressions:
        return "Chord progression practice progress";
    }
  }
}
