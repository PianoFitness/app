import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/features/repertoire/widgets/app_recommendation_card.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              // Modal Header
              Row(
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
              ),
              const SizedBox(height: Spacing.md),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction
                      Semantics(
                        container: true,
                        child: Container(
                          padding: const EdgeInsets.all(Spacing.md),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withValues(
                              alpha: OpacityValues.backgroundLight,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.medium,
                            ),
                            border: Border.all(
                              color: colorScheme.tertiary.withValues(
                                alpha: OpacityValues.borderSubtle,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.tertiary,
                              ),
                              const SizedBox(width: Spacing.sm),
                              Expanded(
                                child: Text(
                                  "Piano Fitness builds technical skills, but repertoire practice completes your musical journey. Use these apps for interactive sheet music and guided learning:",
                                  style: TextStyle(
                                    fontSize:
                                        theme.textTheme.bodyLarge?.fontSize,
                                    color: colorScheme.tertiary,
                                    height: RepertoireUIConstants
                                        .introTextLineHeight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),

                      // App Recommendations
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
                        onOpenUrl: () => onLaunchUrl(
                          "https://www.joytunes.com/simply-piano",
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),

                      // Practice Timer Info
                      Semantics(
                        container: true,
                        child: Container(
                          padding: const EdgeInsets.all(Spacing.md),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(
                              alpha: OpacityValues.backgroundLight,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.medium,
                            ),
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
                                      fontSize: theme
                                          .textTheme
                                          .headlineMedium
                                          ?.fontSize,
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
                                  height: RepertoireUIConstants
                                      .descriptionLineHeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
}
