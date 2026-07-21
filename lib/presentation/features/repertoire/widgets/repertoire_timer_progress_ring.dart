import "package:flutter/material.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/repertoire_timer_display.dart";

/// A reusable progress ring for displaying the practice timer remaining time.
class RepertoireTimerProgressRing extends StatelessWidget {
  /// Creates a timer progress ring display.
  const RepertoireTimerProgressRing({
    required this.state,
    required this.circleSize,
    required this.timerFontSize,
    required this.isVeryConstrained,
    super.key,
  });

  /// The timer state containing formatted time and progress.
  final TimerState state;

  /// Diameter of the outer timer circle.
  final double circleSize;

  /// Font size for the timer text display.
  final double timerFontSize;

  /// Whether the UI space is severely constrained.
  final bool isVeryConstrained;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: circleSize + 16,
      height: circleSize + 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [colorScheme.surface, colorScheme.surfaceContainerHighest],
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
              CircularProgressIndicator(
                value: state.progress,
                strokeWidth: isVeryConstrained ? 4 : 6,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  state.isRunning ? colorScheme.tertiary : colorScheme.primary,
                ),
              ),
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
              Semantics(
                label: "Timer display: ${state.formattedTime} remaining",
                liveRegion: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isVeryConstrained)
                      Icon(
                        Icons.music_note,
                        size: timerFontSize * 0.8,
                        color: state.isRunning
                            ? colorScheme.tertiary
                            : colorScheme.primary,
                      ),
                    Text(
                      state.formattedTime,
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
  }
}
