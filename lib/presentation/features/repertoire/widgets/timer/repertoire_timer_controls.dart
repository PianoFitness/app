import "package:flutter/material.dart";
import "package:piano_fitness/presentation/accessibility/services/musical_announcements_service.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/repertoire_timer_display.dart";

/// Action buttons widget (Start, Pause, Resume, Reset) for the repertoire timer.
class RepertoireTimerControls extends StatelessWidget {
  /// Creates the timer action control bar.
  const RepertoireTimerControls({
    required this.actions,
    required this.buttonSize,
    required this.buttonSpacing,
    required this.iconSize,
    required this.isCompact,
    required this.isVeryConstrained,
    required this.isExtremelyConstrained,
    required this.isLandscape,
    required this.selectedDurationMinutes,
    super.key,
  });

  /// Timer actions configuration callbacks.
  final TimerActions actions;

  /// Size of circular buttons.
  final double buttonSize;

  /// Spacing between buttons.
  final double buttonSpacing;

  /// Icon size inside buttons.
  final double iconSize;

  /// Layout constraints.
  final bool isCompact;
  final bool isVeryConstrained;
  final bool isExtremelyConstrained;
  final bool isLandscape;

  /// Selected duration in minutes for accessibility announcement on reset.
  final int selectedDurationMinutes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final actionButtons = [
      // Enhanced Start/Resume Button
      if (actions.canStart || actions.canResume)
        Semantics(
          button: true,
          label: actions.canStart ? "Start timer" : "Resume timer",
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.tertiary,
                  colorScheme.tertiary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.tertiary.withValues(
                    alpha: isLandscape ? 0.2 : 0.3,
                  ),
                  blurRadius: isLandscape ? 6 : 8,
                  offset: Offset(0, isLandscape ? 2 : 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: actions.canStart
                  ? () {
                      actions.onStart();
                      MusicalAnnouncementsService.announceTimerChange(
                        context,
                        "Timer started",
                      );
                    }
                  : () {
                      actions.onResume();
                      MusicalAnnouncementsService.announceTimerChange(
                        context,
                        "Timer resumed",
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colorScheme.onTertiary,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.all(
                  isExtremelyConstrained
                      ? 4
                      : (isVeryConstrained ? 6 : (isCompact ? 10 : 12)),
                ),
                minimumSize: Size(buttonSize, buttonSize),
                shape: const CircleBorder(),
              ),
              child: Icon(Icons.play_arrow, size: iconSize),
            ),
          ),
        ),

      // Enhanced Pause Button
      if (actions.canPause)
        Semantics(
          button: true,
          label: "Pause timer",
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondary,
                  colorScheme.secondary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withValues(
                    alpha: isLandscape ? 0.2 : 0.3,
                  ),
                  blurRadius: isLandscape ? 6 : 8,
                  offset: Offset(0, isLandscape ? 2 : 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                actions.onPause();
                MusicalAnnouncementsService.announceTimerChange(
                  context,
                  "Timer paused",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colorScheme.onSecondary,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.all(
                  isExtremelyConstrained
                      ? 4
                      : (isVeryConstrained ? 6 : (isCompact ? 10 : 12)),
                ),
                minimumSize: Size(buttonSize, buttonSize),
                shape: const CircleBorder(),
              ),
              child: Icon(Icons.pause, size: iconSize),
            ),
          ),
        ),

      // Enhanced Reset Button
      if (actions.canReset)
        Semantics(
          button: true,
          label: "Reset timer",
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(
                    alpha: isLandscape ? 0.15 : 0.2,
                  ),
                  blurRadius: isLandscape ? 4 : 6,
                  offset: Offset(0, isLandscape ? 1 : 2),
                ),
              ],
            ),
            child: OutlinedButton(
              onPressed: () {
                actions.onReset();
                MusicalAnnouncementsService.announceTimerChange(
                  context,
                  "Timer reset to $selectedDurationMinutes minutes",
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                side: BorderSide.none,
                padding: EdgeInsets.all(
                  isExtremelyConstrained
                      ? 4
                      : (isVeryConstrained ? 6 : (isCompact ? 10 : 12)),
                ),
                minimumSize: Size(buttonSize, buttonSize),
                shape: const CircleBorder(),
              ),
              child: Icon(Icons.refresh, size: iconSize),
            ),
          ),
        ),
    ];

    if (actionButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: actionButtons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            right: index < actionButtons.length - 1 ? buttonSpacing : 0,
          ),
          child: button,
        );
      }).toList(),
    );
  }
}
