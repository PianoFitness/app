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
                constraints.maxHeight < ResponsiveBreakpoints.compactHeight;

            // Responsive padding and spacing
            final padding = isSmallHeight
                ? RepertoireUIConstants.pagePaddingCompact
                : Spacing.sm;
            final sectionSpacing = isSmallHeight ? Spacing.xs : Spacing.sm;

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
                            : Spacing.md,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(
                              alpha: OpacityValues.gradientStart,
                            ),
                            colorScheme.secondary.withValues(
                              alpha: OpacityValues.gradientStart,
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
                            alpha: OpacityValues.borderSubtle,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(Spacing.sm),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: OpacityValues.shadowMedium,
                                  ),
                                  blurRadius: 8.0, // Standard card shadow blur
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.library_music,
                              color: colorScheme.primary,
                              size: isSmallHeight
                                  ? ComponentDimensions.iconSizeMedium
                                  : ComponentDimensions.iconSizeLarge,
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
                                        ? theme
                                              .textTheme
                                              .headlineSmall
                                              ?.fontSize
                                        : theme
                                              .textTheme
                                              .headlineMedium
                                              ?.fontSize,
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
                                      fontSize:
                                          theme.textTheme.bodyMedium?.fontSize,
                                      color: colorScheme.primary.withValues(
                                        alpha: OpacityValues.textMuted,
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
                                        : theme.textTheme.bodySmall?.fontSize,
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
                                  padding: const EdgeInsets.all(Spacing.sm),
                                  child: Icon(
                                    Icons.help_outline,
                                    color: colorScheme.primary,
                                    size: isSmallHeight
                                        ? RepertoireUIConstants
                                              .helpIconSizeCompact
                                        : ComponentDimensions.iconSizeMedium,
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
        mediaQuery.size.width >= ResponsiveBreakpoints.tablet ||
        mediaQuery.size.height >= ResponsiveBreakpoints.tablet;

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
                                            fontSize: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.fontSize,
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
                          const SizedBox(height: Spacing.xl),

                          // App Recommendations
                          Semantics(
                            header: true,
                            child: Text(
                              "Recommended Apps",
                              style: TextStyle(
                                fontSize:
                                    theme.textTheme.headlineMedium?.fontSize,
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
                                      Icon(
                                        Icons.timer,
                                        color: colorScheme.primary,
                                      ),
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
                                      fontSize:
                                          theme.textTheme.bodyLarge?.fontSize,
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
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(
            RepertoireUIConstants.containerBorderRadius,
          ),
          border: Border.all(
            color: color.withValues(alpha: OpacityValues.borderMedium),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(
                RepertoireUIConstants.appIconPadding,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: OpacityValues.backgroundLight),
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
                      fontSize: theme.textTheme.bodyMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall?.fontSize,
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
                padding: const EdgeInsets.all(Spacing.xs),
                constraints: const BoxConstraints(
                  minWidth: ComponentDimensions.iconSizeXLarge,
                  minHeight: ComponentDimensions.iconSizeXLarge,
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
