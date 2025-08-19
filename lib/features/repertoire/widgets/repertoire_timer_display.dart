import "package:flutter/material.dart";
import "package:flutter/semantics.dart";

/// Reusable widget for displaying practice timer with controls.
class RepertoireTimerDisplay extends StatelessWidget {
  /// Creates a timer display widget.
  const RepertoireTimerDisplay({
    required this.formattedTime,
    required this.progress,
    required this.isRunning,
    required this.isPaused,
    required this.remainingSeconds,
    required this.canStart,
    required this.canResume,
    required this.canPause,
    required this.canReset,
    required this.onStart,
    required this.onResume,
    required this.onPause,
    required this.onReset,
    required this.selectedDurationMinutes,
    this.isCompact = false,
    super.key,
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

  /// Selected duration in minutes for semantic announcements.
  final int selectedDurationMinutes;

  /// Whether to use compact styling for smaller screens.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on available space
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final isVeryConstrained = availableHeight < 140 || availableWidth < 200;
        final isExtremelyConstrained = availableHeight < 100;
        final isLandscape = availableWidth > availableHeight;

        // Ultra-compact sizing for very constrained spaces
        final circleSize = isExtremelyConstrained
            ? 30.0
            : (isVeryConstrained
                  ? 40.0
                  : (isCompact ? 55.0 : (availableHeight > 150 ? 70.0 : 60.0)));
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
                        ? (isCompact
                              ? 14.0
                              : 20.0) // More generous spacing in landscape
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
                        ? (isCompact ? 8.0 : 12.0) // More space in landscape
                        : (isCompact ? 6.0 : 10.0)));

        // Create timer widget
        final timerWidget = Container(
          width: circleSize + 16,
          height: circleSize + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: circleSize,
              height: circleSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gradient Progress Ring
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: isVeryConstrained ? 4 : 6,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isRunning
                          ? colorScheme
                                .tertiary // Green when running
                          : colorScheme.primary, // Primary when paused/stopped
                    ),
                  ),
                  // Inner gradient circle
                  Container(
                    width: circleSize - 20,
                    height: circleSize - 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.surface,
                          colorScheme.primary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                  // Time Display
                  Semantics(
                    label: "Timer display: $formattedTime remaining",
                    liveRegion: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isVeryConstrained)
                          Icon(
                            Icons.music_note,
                            size: timerFontSize * 0.8,
                            color: isRunning
                                ? colorScheme.tertiary
                                : colorScheme.primary,
                          ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: timerFontSize,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Create action buttons
        final actionButtons = [
          // Enhanced Start/Resume Button
          if (canStart || canResume)
            Semantics(
              button: true,
              label: canStart ? "Start timer" : "Resume timer",
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
                  onPressed: canStart
                      ? () {
                          onStart();
                          SemanticsService.announce(
                            "Timer started",
                            Directionality.of(context),
                          );
                        }
                      : () {
                          onResume();
                          SemanticsService.announce(
                            "Timer resumed",
                            Directionality.of(context),
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
          if (canPause)
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
                    onPause();
                    SemanticsService.announce(
                      "Timer paused",
                      Directionality.of(context),
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
          if (canReset)
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
                    onReset();
                    SemanticsService.announce(
                      "Timer reset to $selectedDurationMinutes minutes",
                      Directionality.of(context),
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

        // Decide layout: horizontal (timer + buttons in row) for landscape, vertical otherwise
        final useHorizontalLayout = isLandscape && !isVeryConstrained;

        Widget content;
        if (useHorizontalLayout) {
          // Horizontal layout: timer, button1, button2 with elegant spacing
          content = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer widget
              timerWidget,

              // Spacer between timer and buttons (more generous)
              SizedBox(width: isCompact ? 28.0 : 40.0),

              // Action buttons with spacing between them
              if (actionButtons.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actionButtons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final button = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < actionButtons.length - 1
                            ? (isCompact ? 12.0 : 16.0)
                            : 0,
                      ),
                      child: button,
                    );
                  }).toList(),
                ),
            ],
          );
        } else {
          // Vertical layout: original stacked layout
          content = Column(
            mainAxisAlignment: isVeryConstrained
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer widget
              timerWidget,

              // Status indicator (hide in extremely constrained spaces)
              if (!isExtremelyConstrained) ...[
                SizedBox(height: verticalSpacing1),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVeryConstrained ? 8 : 12,
                    vertical: isVeryConstrained ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: statusFontSize,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Semantics(
                        label: _getTimerStatusDescription(),
                        liveRegion: true,
                        child: Text(
                          _getTimerStatusText(),
                          style: TextStyle(
                            fontSize: statusFontSize,
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(
                height: isExtremelyConstrained
                    ? verticalSpacing1
                    : verticalSpacing2,
              ),

              // Action buttons in a row
              if (actionButtons.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: actionButtons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final button = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < actionButtons.length - 1
                            ? buttonSpacing
                            : 0,
                      ),
                      child: button,
                    );
                  }).toList(),
                ),
            ],
          );
        }

        // Return content directly, relying on existing compact sizing logic
        return content;
      },
    );
  }

  String _getTimerStatusText() {
    if (isRunning && !isPaused) {
      return "Timer Running";
    } else if (isPaused) {
      return "Timer Paused";
    } else if (remainingSeconds == 0) {
      return "Session Complete!";
    } else {
      return "Ready to Start";
    }
  }

  String _getTimerStatusDescription() {
    final status = _getTimerStatusText();
    final time = formattedTime;
    return "$status. $time remaining.";
  }

  Color _getStatusColor() {
    // Use hardcoded colors in helper methods since we don't have access to context
    if (isRunning && !isPaused) {
      return const Color(0xFF4CAF50); // Green for running
    } else if (isPaused) {
      return const Color(0xFFFF9800); // Amber for paused
    } else if (remainingSeconds == 0) {
      return const Color(0xFF9C27B0); // Purple for completed
    } else {
      return const Color(0xFF3F51B5); // Indigo for ready
    }
  }

  IconData _getStatusIcon() {
    if (isRunning && !isPaused) {
      return Icons.play_circle_filled;
    } else if (isPaused) {
      return Icons.pause_circle_filled;
    } else if (remainingSeconds == 0) {
      return Icons.celebration;
    } else {
      return Icons.schedule;
    }
  }
}
