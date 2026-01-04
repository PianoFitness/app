import "package:flutter/material.dart";

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
  final isTablet = width >= 768 || height >= 768;

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.05),
            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer Header
          Row(
            children: [
              Icon(Icons.schedule, color: const Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                "Practice Timer",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
            const SizedBox(height: 8),
            instructions!,
          ],
        ],
      ),
    );
  }

  Widget _buildContent(RepertoireLayoutMode layoutMode) {
    switch (layoutMode) {
      case RepertoireLayoutMode.mobilePortrait:
        return _buildVerticalLayout(spacing: 16);

      case RepertoireLayoutMode.mobileLandscape:
        return _buildHorizontalLayout(spacing: 16);

      case RepertoireLayoutMode.tabletPortrait:
        return _buildVerticalLayout(spacing: 24);

      case RepertoireLayoutMode.tabletLandscape:
        return _buildHorizontalLayout(spacing: 32);
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
          flex: 4, // More space to prevent button wrapping
          child: durationSelector,
        ),
        SizedBox(width: spacing),

        // Timer display - takes remaining space with elegant spacing
        Expanded(
          flex: 3, // Adjust proportion accordingly
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing >= 24 ? 16.0 : 8.0,
            ),
            child: timerDisplay,
          ),
        ),
      ],
    );
  }
}
