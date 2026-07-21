import "package:flutter/material.dart";
import "package:piano_fitness/presentation/accessibility/services/musical_announcements_service.dart";
import "package:piano_fitness/presentation/features/repertoire/repertoire_constants.dart";

/// A grid/wrap of duration selection chips for repertoire timer.
class DurationChipGrid extends StatelessWidget {
  /// Creates a duration chip grid.
  const DurationChipGrid({
    required this.availableDurations,
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.canInteract,
    required this.isVeryConstrained,
    required this.isHorizontalLayout,
    required this.buttonPadding,
    required this.buttonFontSize,
    required this.starSize,
    super.key,
  });

  /// Available duration options in minutes.
  final List<int> availableDurations;

  /// Currently selected duration in minutes.
  final int selectedDuration;

  /// Callback when duration changes.
  final ValueChanged<int> onDurationChanged;

  /// Whether user can interact.
  final bool canInteract;

  /// Layout constraints flags and sizes.
  final bool isVeryConstrained;
  final bool isHorizontalLayout;
  final EdgeInsets buttonPadding;
  final double buttonFontSize;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Wrap(
        spacing: isVeryConstrained ? 4 : (isHorizontalLayout ? 6 : 10),
        runSpacing: isVeryConstrained ? 4 : (isHorizontalLayout ? 6 : 10),
        children: availableDurations.map((duration) {
          final isSelected = selectedDuration == duration;
          final isRecommended =
              duration == RepertoireUIConstants.recommendedDurationMinutes;

          final borderRadius = BorderRadius.circular(
            isVeryConstrained ? 14 : (isHorizontalLayout ? 16 : 20),
          );

          return Semantics(
            label: "$duration minutes${isRecommended ? ', recommended' : ''}",
            selected: isSelected,
            child: Material(
              elevation: isSelected ? 4 : 1,
              borderRadius: borderRadius,
              child: InkWell(
                borderRadius: borderRadius,
                onTap: canInteract
                    ? () {
                        onDurationChanged(duration);
                        MusicalAnnouncementsService.announceGeneral(
                          context,
                          "$duration minutes selected",
                        );
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: buttonPadding,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: borderRadius,
                    border: isRecommended && !isSelected
                        ? Border.all(
                            color: colorScheme.tertiary,
                            width: isVeryConstrained ? 1 : 2,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${duration}m",
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: buttonFontSize,
                        ),
                      ),
                      if (isRecommended && !isVeryConstrained) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: starSize,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.tertiary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
