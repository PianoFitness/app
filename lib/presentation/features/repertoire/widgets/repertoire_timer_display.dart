import "package:flutter/material.dart";
import "package:piano_fitness/presentation/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/repertoire_timer_progress_ring.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/timer/repertoire_timer_controls.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/timer/repertoire_timer_status_badge.dart";

/// Configuration object for timer state.
class TimerState {
  /// Creates a timer state configuration.
  const TimerState({
    required this.formattedTime,
    required this.progress,
    required this.isRunning,
    required this.isPaused,
    required this.remainingSeconds,
    required this.selectedDurationMinutes,
  });

  /// Formatted time display string.
  final String formattedTime;

  /// Timer progress (0.0 to 1.0).
  final double progress;

  /// Whether timer is currently running.
  final bool isRunning;

  /// Whether timer is paused.
  final bool isPaused;

  /// Remaining seconds.
  final int remainingSeconds;

  /// Selected duration in minutes for semantic announcements.
  final int selectedDurationMinutes;
}

/// Configuration object for timer actions.
class TimerActions {
  /// Creates a timer actions configuration.
  const TimerActions({
    required this.canStart,
    required this.canResume,
    required this.canPause,
    required this.canReset,
    required this.onStart,
    required this.onResume,
    required this.onPause,
    required this.onReset,
  });

  /// Whether start action is available.
  final bool canStart;

  /// Whether resume action is available.
  final bool canResume;

  /// Whether pause action is available.
  final bool canPause;

  /// Whether reset action is available.
  final bool canReset;

  /// Callback for start action.
  final VoidCallback onStart;

  /// Callback for resume action.
  final VoidCallback onResume;

  /// Callback for pause action.
  final VoidCallback onPause;

  /// Callback for reset action.
  final VoidCallback onReset;
}

/// Reusable widget for displaying practice timer with controls.
class RepertoireTimerDisplay extends StatelessWidget {
  /// Creates a timer display widget.
  const RepertoireTimerDisplay({
    required this.state,
    required this.actions,
    this.isCompact = false,
    super.key,
  });

  /// Timer state configuration.
  final TimerState state;

  /// Timer actions configuration.
  final TimerActions actions;

  /// Whether to use compact styling for smaller screens.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        final isVeryConstrained =
            availableHeight <
                RepertoireUIConstants.timerVeryConstrainedHeight ||
            availableWidth < RepertoireUIConstants.timerVeryConstrainedWidth;
        final isExtremelyConstrained =
            availableHeight <
            RepertoireUIConstants.timerExtremelyConstrainedHeight;
        final isLandscape = availableWidth > availableHeight;

        final circleSize = isExtremelyConstrained
            ? 30.0
            : (isVeryConstrained
                  ? 40.0
                  : (isCompact
                        ? 55.0
                        : (availableHeight >
                                  RepertoireUIConstants.timerComfortableHeight
                              ? 70.0
                              : 60.0)));
        final timerFontSize = isExtremelyConstrained
            ? 10.0
            : (isVeryConstrained ? 11.0 : (isCompact ? 14.0 : 16.0));
        final statusFontSize = isExtremelyConstrained
            ? 9.0
            : (isVeryConstrained ? 10.0 : (isCompact ? 11.0 : 13.0));
        final buttonSize = isExtremelyConstrained
            ? 28.0
            : (isVeryConstrained ? 32.0 : (isCompact ? 40.0 : 48.0));
        final buttonSpacing = isExtremelyConstrained
            ? 6.0
            : (isVeryConstrained
                  ? 8.0
                  : (isLandscape
                        ? (isCompact ? 14.0 : 20.0)
                        : (isCompact ? 12.0 : 16.0)));
        final iconSize = isExtremelyConstrained
            ? 14.0
            : (isVeryConstrained ? 16.0 : (isCompact ? 20.0 : 24.0));
        final verticalSpacing1 = isExtremelyConstrained
            ? 1.0
            : (isVeryConstrained ? 2.0 : (isCompact ? 4.0 : 8.0));
        final verticalSpacing2 = isExtremelyConstrained
            ? 1.0
            : (isVeryConstrained
                  ? 2.0
                  : (isLandscape
                        ? (isCompact ? 8.0 : 12.0)
                        : (isCompact ? 6.0 : 10.0)));

        final timerWidget = RepertoireTimerProgressRing(
          state: state,
          circleSize: circleSize,
          timerFontSize: timerFontSize,
          isVeryConstrained: isVeryConstrained,
        );

        final timerControls = RepertoireTimerControls(
          actions: actions,
          buttonSize: buttonSize,
          buttonSpacing: buttonSpacing,
          iconSize: iconSize,
          isCompact: isCompact,
          isVeryConstrained: isVeryConstrained,
          isExtremelyConstrained: isExtremelyConstrained,
          isLandscape: isLandscape,
          selectedDurationMinutes: state.selectedDurationMinutes,
        );

        final useHorizontalLayout = isLandscape && !isVeryConstrained;

        if (useHorizontalLayout) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              timerWidget,
              SizedBox(width: isCompact ? 28.0 : 40.0),
              timerControls,
            ],
          );
        }

        return Column(
          mainAxisAlignment: isVeryConstrained
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            timerWidget,
            if (!isExtremelyConstrained) ...[
              SizedBox(height: verticalSpacing1),
              RepertoireTimerStatusBadge(
                state: state,
                statusFontSize: statusFontSize,
                isVeryConstrained: isVeryConstrained,
              ),
            ],
            SizedBox(
              height: isExtremelyConstrained
                  ? verticalSpacing1
                  : verticalSpacing2,
            ),
            timerControls,
          ],
        );
      },
    );
  }
}
