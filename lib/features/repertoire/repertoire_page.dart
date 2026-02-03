import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/features/repertoire/repertoire_page_view_model.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_duration_selector.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_header.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_info_modal.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_responsive_layout.dart";
import "package:piano_fitness/features/repertoire/widgets/repertoire_timer_display.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
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
                  RepertoireHeader(
                    isSmallHeight: isSmallHeight,
                    onInfoTap: () => _showRepertoireInfoModal(context),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.large),
        ),
      ),
      builder: (BuildContext context) {
        return RepertoireInfoModal(onLaunchUrl: _launchUrl);
      },
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
