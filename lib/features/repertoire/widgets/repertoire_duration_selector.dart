import "package:flutter/material.dart";
import "package:flutter/semantics.dart";

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we're in a very constrained space
        final isVeryConstrained = constraints.maxHeight < 120;

        // Check if we're in a horizontal layout (landscape) where space is more constrained
        final isHorizontalLayout = constraints.maxWidth < 300;

        // Adaptive styling based on available space
        final padding = isVeryConstrained ? 8.0 : (isCompact ? 12.0 : 16.0);
        final headerSpacing = isVeryConstrained ? 6.0 : 12.0;
        final iconSize = isVeryConstrained ? 14.0 : (isCompact ? 16.0 : 18.0);
        final fontSize = isVeryConstrained ? 12.0 : (isCompact ? 13.0 : 14.0);

        // Make buttons wider for better usability
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
            // Header row
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: const Color(0xFF6366F1),
                  size: iconSize,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isVeryConstrained ? "Duration" : "Practice Duration",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color: const Color(0xFF6366F1),
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: headerSpacing),

            // Duration buttons - scrollable if needed
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: isVeryConstrained
                      ? 4
                      : (isHorizontalLayout ? 6 : 10),
                  runSpacing: isVeryConstrained
                      ? 4
                      : (isHorizontalLayout ? 6 : 10),
                  children: availableDurations.map((duration) {
                    final isSelected = selectedDuration == duration;
                    final isRecommended = duration == 15;

                    return Semantics(
                      label:
                          "$duration minutes${isRecommended ? ', recommended' : ''}",
                      selected: isSelected,
                      child: Material(
                        elevation: isSelected ? 4 : 1,
                        borderRadius: BorderRadius.circular(
                          isVeryConstrained
                              ? 14
                              : (isHorizontalLayout ? 16 : 20),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            isVeryConstrained
                                ? 14
                                : (isHorizontalLayout ? 16 : 20),
                          ),
                          onTap: canInteract
                              ? () {
                                  onDurationChanged(duration);
                                  SemanticsService.announce(
                                    "$duration minutes selected",
                                    TextDirection.ltr,
                                  );
                                }
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: buttonPadding,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(
                                isVeryConstrained
                                    ? 14
                                    : (isHorizontalLayout ? 16 : 20),
                              ),
                              border: isRecommended && !isSelected
                                  ? Border.all(
                                      color: const Color(0xFFF59E0B),
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
                                        ? Colors.white
                                        : const Color(0xFF6366F1),
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
                                        ? Colors.white
                                        : const Color(0xFFF59E0B),
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
              ),
            ),

            // Recommendation text - always reserve space to prevent size jumping
            if (!isVeryConstrained)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  selectedDuration == 15
                      ? "⭐ Recommended for focused practice"
                      : "", // Empty text maintains space
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    color: const Color(0xFFF59E0B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.05),
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
