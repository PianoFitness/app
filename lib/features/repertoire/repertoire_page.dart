import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_page_view_model.dart";
import "package:piano_fitness/shared/widgets/repertoire_duration_selector.dart";
import "package:piano_fitness/shared/widgets/repertoire_responsive_layout.dart";
import "package:piano_fitness/shared/widgets/repertoire_timer_display.dart";
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_music, color: Colors.orange),
            SizedBox(width: 8),
            Text("Repertoire"),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallHeight = constraints.maxHeight < 600;

            // Responsive padding and spacing
            final padding = isSmallHeight ? 6.0 : 8.0;
            final sectionSpacing = isSmallHeight ? 4.0 : 8.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Header
                  Container(
                    padding: EdgeInsets.all(isSmallHeight ? 12 : 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withValues(alpha: 0.1),
                          const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.library_music,
                            color: const Color(0xFF6366F1),
                            size: isSmallHeight ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: isSmallHeight ? 8 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Repertoire Practice",
                                style: TextStyle(
                                  fontSize: isSmallHeight ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6366F1),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (!isSmallHeight)
                                Text(
                                  "Build your musical repertoire",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _showRepertoireInfoModal(context),
                            child: Semantics(
                              button: true,
                              label:
                                  "About repertoire practice and recommended apps",
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.help_outline,
                                  color: const Color(0xFF6366F1),
                                  size: isSmallHeight ? 18 : 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          instructions: Text(
                            "Switch to your repertoire app for focused practice",
                            style: TextStyle(
                              fontSize: isSmallHeight ? 10 : 11,
                              color: Colors.orange.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modal Header
                  Row(
                    children: [
                      Icon(
                        Icons.library_music,
                        color: const Color(0xFF6366F1),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "About Repertoire Practice",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        tooltip: "Close",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Introduction
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Complete Practice Routine",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Piano Fitness focuses on technical skills—scales, chords, and arpeggios that build your musical foundation. But a complete practice routine also includes repertoire: learning and performing actual pieces of music.",
                                  style: TextStyle(fontSize: 16, height: 1.4),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "For repertoire study, we recommend using dedicated apps that excel at interactive sheet music and guided learning:",
                                  style: TextStyle(fontSize: 16, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // App Recommendations
                          Text(
                            "Recommended Apps",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildCompactAppRecommendation(
                            name: "Flowkey",
                            description:
                                "Learn popular songs with interactive lessons and real-time feedback",
                            url: "https://www.flowkey.com",
                            icon: Icons.play_circle_filled,
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 12),

                          _buildCompactAppRecommendation(
                            name: "Simply Piano",
                            description:
                                "Practice with your favorite songs using acoustic recognition",
                            url: "https://www.joytunes.com/simply-piano",
                            icon: Icons.music_note,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 20),

                          // Practice Timer Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Practice Timer",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Use the timer below to set focused practice sessions. Start the timer, then switch to your repertoire app or sheet music for distraction-free practice.",
                                  style: TextStyle(fontSize: 16, height: 1.4),
                                ),
                              ],
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => _launchUrl(url),
            icon: Icon(Icons.open_in_new, color: color, size: 18),
            tooltip: "Open $name",
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
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
