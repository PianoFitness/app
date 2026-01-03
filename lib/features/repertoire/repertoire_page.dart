import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/features/repertoire/repertoire_page_view_model.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_duration_selector.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_responsive_layout.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_timer_display.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";
import "package:url_launcher/url_launcher.dart";

/// Repertoire page for practicing pieces with time management.
///
/// This page provides guidance on repertoire practice and recommends
/// dedicated apps for piece study while offering a practice timer.
/// It follows the MVVM pattern with logic handled by RepertoirePageViewModel.
class RepertoirePage extends StatefulWidget {
  /// Creates the repertoire page.
  const RepertoirePage({super.key});

  @override
  State<RepertoirePage> createState() => _RepertoirePageState();
}

class _RepertoirePageState extends State<RepertoirePage> {
  late final RepertoirePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RepertoirePageViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallHeight =
                constraints.maxHeight <
                RepertoireUIConstants.compactHeightThreshold;

            // Responsive padding and spacing
            final padding = isSmallHeight
                ? RepertoireUIConstants.pagePaddingCompact
                : RepertoireUIConstants.pagePadding;
            final sectionSpacing = isSmallHeight
                ? RepertoireUIConstants.sectionSpacingCompact
                : RepertoireUIConstants.sectionSpacing;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Header
                  Semantics(
                    container: true,
                    child: Container(
                      padding: EdgeInsets.all(
                        isSmallHeight
                            ? RepertoireUIConstants.headerPaddingCompact
                            : RepertoireUIConstants.headerPadding,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(
                              alpha: RepertoireUIConstants.gradientPrimaryAlpha,
                            ),
                            colorScheme.secondary.withValues(
                              alpha:
                                  RepertoireUIConstants.gradientSecondaryAlpha,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.large,
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withValues(
                            alpha: RepertoireUIConstants.borderAlpha,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              RepertoireUIConstants.iconContainerPadding,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: RepertoireUIConstants.shadowAlpha,
                                  ),
                                  blurRadius: Spacing.sm,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.library_music,
                              color: colorScheme.primary,
                              size: isSmallHeight
                                  ? RepertoireUIConstants.headerIconSizeCompact
                                  : RepertoireUIConstants.headerIconSize,
                            ),
                          ),
                          SizedBox(
                            width: isSmallHeight ? Spacing.sm : Spacing.md,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Repertoire Practice",
                                  style: TextStyle(
                                    fontSize: isSmallHeight
                                        ? RepertoireUIConstants
                                              .headerTitleFontSizeCompact
                                        : RepertoireUIConstants
                                              .headerTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                    letterSpacing: RepertoireUIConstants
                                        .titleLetterSpacing,
                                  ),
                                ),
                                if (!isSmallHeight)
                                  Text(
                                    "Build your musical repertoire",
                                    style: TextStyle(
                                      fontSize: RepertoireUIConstants
                                          .subtitleFontSize,
                                      color: colorScheme.primary.withValues(
                                        alpha:
                                            RepertoireUIConstants.subtitleAlpha,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: Spacing.sm),
                                Text(
                                  "Switch to your repertoire app for focused practice",
                                  style: TextStyle(
                                    fontSize: isSmallHeight
                                        ? RepertoireUIConstants
                                              .helperFontSizeCompact
                                        : RepertoireUIConstants.helperFontSize,
                                    color: colorScheme.tertiary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.xLarge,
                            ),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.xLarge,
                              ),
                              onTap: () => _showRepertoireInfoModal(context),
                              child: Semantics(
                                button: true,
                                label:
                                    "About repertoire practice and recommended apps",
                                hint:
                                    "Opens modal with practice guidance and app recommendations",
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    RepertoireUIConstants.helpButtonPadding,
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    color: colorScheme.primary,
                                    size: isSmallHeight
                                        ? RepertoireUIConstants
                                              .helpIconSizeCompact
                                        : RepertoireUIConstants.helpIconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),

                  // Responsive Timer Section
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        return RepertoireResponsiveLayout(
                          durationSelector: RepertoireDurationSelector(
                            availableDurations:
                                RepertoirePageViewModel.timerDurations,
                            selectedDuration:
                                _viewModel.selectedDurationMinutes,
                            onDurationChanged: _viewModel.setDuration,
                            canInteract: _viewModel.canStart,
                            isCompact: isSmallHeight,
                          ),
                          timerDisplay: RepertoireTimerDisplay(
                            formattedTime: _viewModel.formattedTime,
                            progress: _viewModel.progress,
                            isRunning: _viewModel.isRunning,
                            isPaused: _viewModel.isPaused,
                            remainingSeconds: _viewModel.remainingSeconds,
                            canStart: _viewModel.canStart,
                            canResume: _viewModel.canResume,
                            canPause: _viewModel.canPause,
                            canReset: _viewModel.canReset,
                            onStart: _viewModel.startTimer,
                            onResume: _viewModel.resumeTimer,
                            onPause: _viewModel.pauseTimer,
                            onReset: _viewModel.resetTimer,
                            selectedDurationMinutes:
                                _viewModel.selectedDurationMinutes,
                            isCompact: isSmallHeight,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRepertoireInfoModal(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.size.width > mediaQuery.size.height;
    final isTablet =
        mediaQuery.size.width >= RepertoireUIConstants.tabletWidthThreshold ||
        mediaQuery.size.height >= RepertoireUIConstants.tabletHeightThreshold;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.large),
        ),
      ),
      builder: (BuildContext context) {
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
              padding: const EdgeInsets.all(
                RepertoireUIConstants.modalContentPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modal Header
                  Row(
                    children: [
                      Icon(
                        Icons.library_music,
                        color: colorScheme.primary,
                        size: RepertoireUIConstants.modalIconSize,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        "About Repertoire Practice",
                        style: TextStyle(
                          fontSize: RepertoireUIConstants.modalTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing:
                              RepertoireUIConstants.titleLetterSpacing,
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
                              padding: const EdgeInsets.all(
                                RepertoireUIConstants.infoContainerPadding,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiary.withValues(
                                  alpha: RepertoireUIConstants
                                      .tertiaryBackgroundAlpha,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.medium,
                                ),
                                border: Border.all(
                                  color: colorScheme.tertiary.withValues(
                                    alpha: RepertoireUIConstants.borderAlpha,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                            fontSize: RepertoireUIConstants
                                                .introTextFontSize,
                                            color: colorScheme.tertiary,
                                            height: RepertoireUIConstants
                                                .introTextLineHeight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppBorderRadius.xLarge),

                          // App Recommendations
                          Semantics(
                            header: true,
                            child: Text(
                              "Recommended Apps",
                              style: TextStyle(
                                fontSize:
                                    RepertoireUIConstants.sectionHeaderFontSize,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.md),

                          _buildCompactAppRecommendation(
                            name: "Flowkey",
                            description:
                                "Learn popular songs with interactive lessons and real-time feedback",
                            url: "https://www.flowkey.com",
                            icon: Icons.play_circle_filled,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(height: Spacing.md),

                          _buildCompactAppRecommendation(
                            name: "Simply Piano",
                            description:
                                "Practice with your favorite songs using acoustic recognition",
                            url: "https://www.joytunes.com/simply-piano",
                            icon: Icons.music_note,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(height: AppBorderRadius.xLarge),

                          // Practice Timer Info
                          Semantics(
                            container: true,
                            child: Container(
                              padding: const EdgeInsets.all(
                                RepertoireUIConstants.infoContainerPadding,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: RepertoireUIConstants
                                      .tertiaryBackgroundAlpha,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.medium,
                                ),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(
                                    alpha: RepertoireUIConstants.borderAlpha,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: Spacing.sm),
                                      Text(
                                        "Practice Timer",
                                        style: TextStyle(
                                          fontSize: RepertoireUIConstants
                                              .sectionHeaderFontSize,
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
                                      fontSize: RepertoireUIConstants
                                          .practiceTimerDescFontSize,
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
      },
    );
  }

  Widget _buildCompactAppRecommendation({
    required String name,
    required String description,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(
          RepertoireUIConstants.appRecommendationPadding,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(
            RepertoireUIConstants.containerBorderRadius,
          ),
          border: Border.all(
            color: color.withValues(
              alpha: RepertoireUIConstants.appRecommendationBorderAlpha,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(
                RepertoireUIConstants.appIconPadding,
              ),
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: RepertoireUIConstants.appIconBackgroundAlpha,
                ),
                borderRadius: BorderRadius.circular(
                  RepertoireUIConstants.containerBorderRadius,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: RepertoireUIConstants.appRecommendationIconSize,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: RepertoireUIConstants.appNameFontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: RepertoireUIConstants.appDescriptionFontSize,
                      height: RepertoireUIConstants.appDescriptionLineHeight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Semantics(
              button: true,
              label: "Open $name website",
              hint: "Opens $name in external browser or app",
              child: IconButton(
                onPressed: () => _launchUrl(url),
                icon: Icon(
                  Icons.open_in_new,
                  color: color,
                  size: RepertoireUIConstants.appRecommendationIconSize,
                ),
                tooltip: "Open $name",
                padding: const EdgeInsets.all(
                  RepertoireUIConstants.iconButtonPadding,
                ),
                constraints: const BoxConstraints(
                  minWidth: RepertoireUIConstants.iconButtonMinWidth,
                  minHeight: RepertoireUIConstants.iconButtonMinHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not open $urlString")));
      }
    }
  }
}
