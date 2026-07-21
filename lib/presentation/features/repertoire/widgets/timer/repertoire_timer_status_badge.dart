import "package:flutter/material.dart";
import "package:piano_fitness/presentation/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/repertoire_timer_display.dart";

/// A badge displaying the current status of the repertoire timer.
class RepertoireTimerStatusBadge extends StatelessWidget {
  /// Creates the timer status badge.
  const RepertoireTimerStatusBadge({
    required this.state,
    required this.statusFontSize,
    required this.isVeryConstrained,
    super.key,
  });

  /// The current state of the repertoire timer.
  final TimerState state;

  /// Font size for the status label and icon.
  final double statusFontSize;

  /// Layout constraint indicator.
  final bool isVeryConstrained;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVeryConstrained ? 8 : 12,
        vertical: isVeryConstrained ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: statusFontSize, color: statusColor),
          const SizedBox(width: 4),
          Semantics(
            label: _getTimerStatusDescription(),
            liveRegion: true,
            child: Text(
              _getTimerStatusText(),
              style: TextStyle(
                fontSize: statusFontSize,
                color: statusColor,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimerStatusText() {
    if (state.isRunning && !state.isPaused) {
      return "Timer Running";
    } else if (state.isPaused) {
      return "Timer Paused";
    } else if (state.remainingSeconds == 0) {
      return "Session Complete!";
    } else {
      return "Ready to Start";
    }
  }

  String _getTimerStatusDescription() {
    final status = _getTimerStatusText();
    final time = state.formattedTime;
    return "$status. $time remaining.";
  }

  Color _getStatusColor() {
    if (state.isRunning && !state.isPaused) {
      return RepertoireUIConstants.timerRunningColor;
    } else if (state.isPaused) {
      return RepertoireUIConstants.timerPausedColor;
    } else if (state.remainingSeconds == 0) {
      return RepertoireUIConstants.timerCompletedColor;
    } else {
      return RepertoireUIConstants.timerReadyColor;
    }
  }

  IconData _getStatusIcon() {
    if (state.isRunning && !state.isPaused) {
      return Icons.play_circle_filled;
    } else if (state.isPaused) {
      return Icons.pause_circle_filled;
    } else if (state.remainingSeconds == 0) {
      return Icons.celebration;
    } else {
      return Icons.schedule;
    }
  }
}
