import "package:flutter/material.dart";
import "package:piano_fitness/presentation/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/presentation/features/repertoire/widgets/duration/duration_chip_grid.dart";

/// Reusable widget for selecting practice duration in repertoire practice.
class RepertoireDurationSelector extends StatelessWidget {
  /// Creates a duration selector.
  const RepertoireDurationSelector({
    required this.availableDurations,
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.canInteract,
    this.isCompact = false,
    super.key,
  });

  /// Available duration options in minutes.
  final List<int> availableDurations;

  /// Currently selected duration in minutes.
  final int selectedDuration;

  /// Callback when duration selection changes.
  final ValueChanged<int> onDurationChanged;

  /// Whether the selector can be interacted with.
  final bool canInteract;

  /// Whether to use compact styling for smaller screens.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryConstrained =
            constraints.maxHeight <
            RepertoireUIConstants.durationVeryConstrainedHeight;

        final isHorizontalLayout =
            constraints.maxWidth <
            RepertoireUIConstants.durationHorizontalLayoutWidth;

        final padding = isVeryConstrained ? 8.0 : (isCompact ? 12.0 : 16.0);
        final headerSpacing = isVeryConstrained ? 6.0 : 12.0;
        final iconSize = isVeryConstrained ? 14.0 : (isCompact ? 16.0 : 18.0);
        final fontSize = isVeryConstrained ? 12.0 : (isCompact ? 13.0 : 14.0);

        final buttonPadding = isVeryConstrained
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : (isHorizontalLayout
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                  : EdgeInsets.symmetric(
                      horizontal: isCompact ? 16 : 20,
                      vertical: isCompact ? 8 : 10,
                    ));
        final buttonFontSize = isVeryConstrained
            ? 10.0
            : (isHorizontalLayout ? 11.0 : (isCompact ? 12.0 : 13.0));
        final starSize = isVeryConstrained
            ? 8.0
            : (isHorizontalLayout ? 9.0 : (isCompact ? 10.0 : 12.0));

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: colorScheme.primary,
                  size: iconSize,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isVeryConstrained ? "Duration" : "Practice Duration",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color: colorScheme.primary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: headerSpacing),
            Flexible(
              child: DurationChipGrid(
                availableDurations: availableDurations,
                selectedDuration: selectedDuration,
                onDurationChanged: onDurationChanged,
                canInteract: canInteract,
                isVeryConstrained: isVeryConstrained,
                isHorizontalLayout: isHorizontalLayout,
                buttonPadding: buttonPadding,
                buttonFontSize: buttonFontSize,
                starSize: starSize,
              ),
            ),
            if (!isVeryConstrained)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  selectedDuration ==
                          RepertoireUIConstants.recommendedDurationMinutes
                      ? "⭐ Recommended for focused practice"
                      : "",
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    color: colorScheme.tertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: content,
        );
      },
    );
  }
}
