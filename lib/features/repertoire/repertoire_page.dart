import "package:flutter/material.dart";
import "package:flutter/semantics.dart";
import "package:piano_fitness/features/repertoire/repertoire_page_view_model.dart";
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Introduction Section
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
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "About Repertoire Practice",
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
              const SizedBox(height: 16),

              // App Recommendations Section
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
                        Icon(Icons.apps, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          "Recommended Repertoire Apps",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Flowkey Recommendation
                    _buildAppRecommendation(
                      name: "Flowkey",
                      description:
                          "Learn popular songs with interactive lessons and real-time feedback.",
                      url: "https://www.flowkey.com",
                      icon: Icons.play_circle_filled,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),

                    // Simply Piano Recommendation
                    _buildAppRecommendation(
                      name: "Simply Piano",
                      description:
                          "Practice with your favorite songs using acoustic recognition.",
                      url: "https://www.joytunes.com/simply-piano",
                      icon: Icons.music_note,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Practice Timer Section
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  return _buildTimerSection();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        children: [
          // Timer Header
          Row(
            children: [
              Icon(Icons.timer, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                "Practice Timer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Duration Selection
          Text(
            "Select Duration",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RepertoirePageViewModel.timerDurations.map((duration) {
              final isSelected = _viewModel.selectedDurationMinutes == duration;
              return Semantics(
                label: "$duration minutes",
                selected: isSelected,
                child: FilterChip(
                  label: Text("${duration}m"),
                  selected: isSelected,
                  onSelected: _viewModel.canStart
                      ? (selected) {
                          if (selected) {
                            _viewModel.setDuration(duration);
                            SemanticsService.announce(
                              "$duration minutes selected",
                              TextDirection.ltr,
                            );
                          }
                        }
                      : null,
                  selectedColor: Colors.orange.shade100,
                  checkmarkColor: Colors.orange.shade700,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Timer Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                // Progress Indicator
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _viewModel.progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.orange.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange.shade600,
                        ),
                      ),
                      Semantics(
                        label:
                            "Timer display: ${_viewModel.formattedTime} remaining",
                        liveRegion: true,
                        child: Text(
                          _viewModel.formattedTime,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Timer Status
                Semantics(
                  label: _getTimerStatusDescription(),
                  liveRegion: true,
                  child: Text(
                    _getTimerStatusText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timer Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Start/Resume Button
              if (_viewModel.canStart || _viewModel.canResume)
                Semantics(
                  button: true,
                  label: _viewModel.canStart ? "Start timer" : "Resume timer",
                  child: ElevatedButton.icon(
                    onPressed: _viewModel.canStart
                        ? () {
                            _viewModel.startTimer();
                            SemanticsService.announce(
                              "Timer started",
                              TextDirection.ltr,
                            );
                          }
                        : () {
                            _viewModel.resumeTimer();
                            SemanticsService.announce(
                              "Timer resumed",
                              TextDirection.ltr,
                            );
                          },
                    icon: Icon(
                      _viewModel.canStart ? Icons.play_arrow : Icons.play_arrow,
                    ),
                    label: Text(_viewModel.canStart ? "Start" : "Resume"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              // Pause Button
              if (_viewModel.canPause)
                Semantics(
                  button: true,
                  label: "Pause timer",
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _viewModel.pauseTimer();
                      SemanticsService.announce(
                        "Timer paused",
                        TextDirection.ltr,
                      );
                    },
                    icon: const Icon(Icons.pause),
                    label: const Text("Pause"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              // Reset Button
              if (_viewModel.canReset)
                Semantics(
                  button: true,
                  label: "Reset timer",
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _viewModel.resetTimer();
                      SemanticsService.announce(
                        "Timer reset to ${_viewModel.selectedDurationMinutes} minutes",
                        TextDirection.ltr,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reset"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade300),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Instructions
          Text(
            "Set your timer, then switch to your repertoire app or sheet music for focused practice.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTimerStatusText() {
    if (_viewModel.isRunning && !_viewModel.isPaused) {
      return "Timer Running";
    } else if (_viewModel.isPaused) {
      return "Timer Paused";
    } else if (_viewModel.remainingSeconds == 0) {
      return "Session Complete!";
    } else {
      return "Ready to Start";
    }
  }

  String _getTimerStatusDescription() {
    final status = _getTimerStatusText();
    final time = _viewModel.formattedTime;
    return "$status. $time remaining.";
  }

  Widget _buildAppRecommendation({
    required String name,
    required String description,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _launchUrl(url),
            icon: Icon(Icons.open_in_new, color: color),
            tooltip: "Open $name",
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
