import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/shared/constants/typography_constants.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";

/// Layout modes for different screen sizes and orientations.
enum RepertoireLayoutMode {
  /// Mobile portrait: time selection above timer
  mobilePortrait,

  /// Mobile landscape: time selection to left of timer
  mobileLandscape,

  /// Tablet portrait: time selection above timer with wider spacing
  tabletPortrait,

  /// Tablet landscape: time selection to left of timer with ample spacing
  tabletLandscape,
}

/// Determines appropriate layout mode based on constraints.
RepertoireLayoutMode _getLayoutMode(BoxConstraints constraints) {
  final width = constraints.maxWidth;
  final height = constraints.maxHeight;
  final isLandscape = width > height;
  final isTablet =
      width >= ResponsiveBreakpoints.tablet ||
      height >= ResponsiveBreakpoints.tablet;

  if (isTablet) {
    return isLandscape
        ? RepertoireLayoutMode.tabletLandscape
        : RepertoireLayoutMode.tabletPortrait;
  } else {
    return isLandscape
        ? RepertoireLayoutMode.mobileLandscape
        : RepertoireLayoutMode.mobilePortrait;
  }
}

/// Responsive layout wrapper for repertoire timer components.
///
/// Automatically adapts the layout of duration selector and timer display
/// based on screen size and orientation:
///
/// - Mobile Portrait: Duration selector above timer (vertical stack)
/// - Mobile Landscape: Duration selector to left of timer (horizontal layout)
/// - Tablet Portrait: Duration selector above timer with wider spacing
/// - Tablet Landscape: Duration selector to left with ample spacing
class RepertoireResponsiveLayout extends StatelessWidget {
  /// Creates a responsive layout wrapper.
  const RepertoireResponsiveLayout({
    required this.durationSelector,
    required this.timerDisplay,
    this.instructions,
    super.key,
  });

  /// Widget for selecting practice duration.
  final Widget durationSelector;

  /// Widget for displaying timer and controls.
  final Widget timerDisplay;

  /// Optional instructions text to display at bottom.
  final Widget? instructions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.05),
            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            blurRadius: ShadowConfig.mediumBlur,
            offset: ShadowConfig.mediumOffset,
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer Header
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: const Color(0xFF6366F1),
                size: ComponentDimensions.iconSizeMedium,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                "Practice Timer",
                style: TextStyle(
                  fontSize: FontSizes.bodyLarge,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                  letterSpacing: RepertoireUIConstants.headerLetterSpacing,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),

          // Responsive Content Layout
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layoutMode = _getLayoutMode(constraints);

                return _buildContent(layoutMode);
              },
            ),
          ),

          // Instructions at bottom
          if (instructions != null) ...[
            const SizedBox(height: Spacing.sm),
            instructions!,
          ],
        ],
      ),
    );
  }

  Widget _buildContent(RepertoireLayoutMode layoutMode) {
    switch (layoutMode) {
      case RepertoireLayoutMode.mobilePortrait:
        return _buildVerticalLayout(spacing: Spacing.md);

      case RepertoireLayoutMode.mobileLandscape:
        return _buildHorizontalLayout(spacing: Spacing.md);

      case RepertoireLayoutMode.tabletPortrait:
        return _buildVerticalLayout(spacing: Spacing.lg);

      case RepertoireLayoutMode.tabletLandscape:
        return _buildHorizontalLayout(spacing: Spacing.xl);
    }
  }

  Widget _buildVerticalLayout({required double spacing}) {
    return Column(
      children: [
        // Duration selector at top
        durationSelector,
        SizedBox(height: spacing),

        // Timer display takes remaining space
        Expanded(child: timerDisplay),
      ],
    );
  }

  Widget _buildHorizontalLayout({required double spacing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration selector - generous space allocation to prevent wrapping
        Flexible(
          flex: RepertoireUIConstants.durationSelectorFlex,
          child: durationSelector,
        ),
        SizedBox(width: spacing),

        // Timer display - takes remaining space with elegant spacing
        Expanded(
          flex: RepertoireUIConstants.timerDisplayFlex,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing >= Spacing.lg ? Spacing.md : Spacing.sm,
            ),
            child: timerDisplay,
          ),
        ),
      ],
    );
  }
}
