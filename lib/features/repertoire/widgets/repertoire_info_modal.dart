import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/features/repertoire/widgets/app_recommendation_card.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Modal bottom sheet displaying repertoire practice information.
///
/// Shows guidance on repertoire practice, app recommendations, and
/// practice timer information in a scrollable draggable sheet.
class RepertoireInfoModal extends StatelessWidget {
  /// Creates a repertoire info modal.
  const RepertoireInfoModal({required this.onLaunchUrl, super.key});

  /// Callback to launch a URL when an app recommendation is tapped.
  final void Function(String url) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.size.width > mediaQuery.size.height;
    final isTablet =
        mediaQuery.size.width >= ResponsiveBreakpoints.tablet ||
        mediaQuery.size.height >= ResponsiveBreakpoints.tablet;

    return DraggableScrollableSheet(
      initialChildSize: isLandscape
          ? RepertoireUIConstants.modalInitialSizeLandscape
          : (isTablet
                ? RepertoireUIConstants.modalInitialSizeTablet
                : RepertoireUIConstants.modalInitialSizeMobile),
      maxChildSize: RepertoireUIConstants.modalMaxSize,
      minChildSize: isLandscape
          ? RepertoireUIConstants.modalMinSizeLandscape
          : RepertoireUIConstants.modalMinSizePortrait,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: Spacing.md),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroCard(context),
                      const SizedBox(height: Spacing.xl),
                      _buildAppRecommendations(context),
                      const SizedBox(height: Spacing.xl),
                      _buildPracticeTimerInfo(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the modal header with title and close button.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          Icons.library_music,
          color: colorScheme.primary,
          size: ComponentDimensions.iconSizeLarge,
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          "About Repertoire Practice",
          style: TextStyle(
            fontSize: theme.textTheme.headlineLarge?.fontSize,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: RepertoireUIConstants.titleLetterSpacing,
          ),
        ),
        const Spacer(),
        Semantics(
          button: true,
          label: "Close information modal",
          hint: "Returns to repertoire practice page",
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: "Close",
          ),
        ),
      ],
    );
  }

  /// Builds the introduction card explaining repertoire practice.
  Widget _buildIntroCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: colorScheme.tertiary.withValues(
            alpha: OpacityValues.backgroundLight,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(
            color: colorScheme.tertiary.withValues(
              alpha: OpacityValues.borderSubtle,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.tertiary),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                "Piano Fitness builds technical skills, but repertoire practice completes your musical journey. Use these apps for interactive sheet music and guided learning:",
                style: TextStyle(
                  fontSize: theme.textTheme.bodyLarge?.fontSize,
                  color: colorScheme.tertiary,
                  height: RepertoireUIConstants.introTextLineHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the app recommendations section with cards.
  Widget _buildAppRecommendations(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            "Recommended Apps",
            style: TextStyle(
              fontSize: theme.textTheme.headlineMedium?.fontSize,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: Spacing.md),
        AppRecommendationCard(
          name: "Flowkey",
          description:
              "Learn popular songs with interactive lessons and real-time feedback",
          url: "https://www.flowkey.com",
          icon: Icons.play_circle_filled,
          color: colorScheme.tertiary,
          onOpenUrl: () => onLaunchUrl("https://www.flowkey.com"),
        ),
        const SizedBox(height: Spacing.md),
        AppRecommendationCard(
          name: "Simply Piano",
          description:
              "Practice with your favorite songs using acoustic recognition",
          url: "https://www.joytunes.com/simply-piano",
          icon: Icons.music_note,
          color: colorScheme.secondary,
          onOpenUrl: () => onLaunchUrl("https://www.joytunes.com/simply-piano"),
        ),
      ],
    );
  }

  /// Builds the practice timer information card.
  Widget _buildPracticeTimerInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(
            alpha: OpacityValues.backgroundLight,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(
            color: colorScheme.primary.withValues(
              alpha: OpacityValues.borderSubtle,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  "Practice Timer",
                  style: TextStyle(
                    fontSize: theme.textTheme.headlineMedium?.fontSize,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              "Use the timer below to set focused practice sessions. Start the timer, then switch to your repertoire app or sheet music for distraction-free practice.",
              style: TextStyle(
                fontSize: theme.textTheme.bodyLarge?.fontSize,
                height: RepertoireUIConstants.descriptionLineHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
