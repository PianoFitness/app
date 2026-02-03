import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
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
class RepertoirePage extends StatelessWidget {
  /// Creates the repertoire page.
  const RepertoirePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RepertoirePageViewModel(
        audioService: context.read<IAudioService>(),
        notificationRepository: context.read<INotificationRepository>(),
        settingsRepository: context.read<ISettingsRepository>(),
      ),
      child: Consumer<RepertoirePageViewModel>(
        builder: (context, viewModel, child) {
          return _buildContent(context, viewModel);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RepertoirePageViewModel viewModel,
  ) {
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
                      listenable: viewModel,
                      builder: (context, child) {
                        return RepertoireResponsiveLayout(
                          durationSelector: RepertoireDurationSelector(
                            availableDurations:
                                RepertoirePageViewModel.timerDurations,
                            selectedDuration: viewModel.selectedDurationMinutes,
                            onDurationChanged: viewModel.setDuration,
                            canInteract: viewModel.canStart,
                            isCompact: isSmallHeight,
                          ),
                          timerDisplay: RepertoireTimerDisplay(
                            state: TimerState(
                              formattedTime: viewModel.formattedTime,
                              progress: viewModel.progress,
                              isRunning: viewModel.isRunning,
                              isPaused: viewModel.isPaused,
                              remainingSeconds: viewModel.remainingSeconds,
                              selectedDurationMinutes:
                                  viewModel.selectedDurationMinutes,
                            ),
                            actions: TimerActions(
                              canStart: viewModel.canStart,
                              canResume: viewModel.canResume,
                              canPause: viewModel.canPause,
                              canReset: viewModel.canReset,
                              onStart: viewModel.startTimer,
                              onResume: viewModel.resumeTimer,
                              onPause: viewModel.pauseTimer,
                              onReset: viewModel.resetTimer,
                            ),
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
        return RepertoireInfoModal(
          onLaunchUrl: (url) => _launchUrl(context, url),
        );
      },
    );
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not open $urlString")));
      }
    }
  }
}
