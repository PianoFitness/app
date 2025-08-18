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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isSmallHeight = constraints.maxHeight < 600;

            // Responsive padding and spacing
            final padding = isSmallHeight ? 6.0 : 8.0;
            final sectionSpacing = isSmallHeight ? 4.0 : 8.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Button (Compact)
                  Row(
                    children: [
                      Text(
                        "Repertoire Practice",
                        style: TextStyle(
                          fontSize: isSmallHeight ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: "About repertoire practice and recommended apps",
                        child: IconButton(
                          onPressed: () => _showRepertoireInfoModal(context),
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: isSmallHeight ? 20 : 24,
                          ),
                          tooltip: "About repertoire practice",
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),

                  // Compact Timer Section
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        return _buildCompactTimerSection(
                          isSmallHeight,
                          isLandscape,
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
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "About Repertoire Practice",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
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

  Widget _buildCompactTimerSection(bool isSmallHeight, bool isLandscape) {
    // Responsive sizing
    final containerPadding = isSmallHeight ? 8.0 : 10.0;
    final headerSpacing = isSmallHeight ? 6.0 : 10.0;
    final sectionSpacing = isSmallHeight ? 8.0 : 12.0;
    final fontSize = isSmallHeight ? 14.0 : 15.0;
    final chipFontSize = isSmallHeight ? 10.0 : 11.0;
    final labelFontSize = isSmallHeight ? 12.0 : 13.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        children: [
          // Timer Header
          Row(
            children: [
              Icon(Icons.timer, color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 6),
              Text(
                "Practice Timer",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: headerSpacing),

          // Duration Selection (Compact)
          Row(
            children: [
              Text(
                "Duration:",
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: RepertoirePageViewModel.timerDurations.map((
                    duration,
                  ) {
                    final isSelected =
                        _viewModel.selectedDurationMinutes == duration;
                    return Semantics(
                      label: "$duration minutes",
                      selected: isSelected,
                      child: FilterChip(
                        label: Text(
                          "${duration}m",
                          style: TextStyle(fontSize: chipFontSize),
                        ),
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
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),

          // Responsive Timer Display
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive sizing based on available space
                final availableHeight = constraints.maxHeight;
                final isVeryConstrained = availableHeight < 100;

                // Ultra-compact sizing for very constrained spaces
                final circleSize = isVeryConstrained
                    ? 40.0
                    : (isSmallHeight
                          ? 55.0
                          : (availableHeight > 150 ? 70.0 : 60.0));
                final timerFontSize = isVeryConstrained
                    ? 12.0
                    : (isSmallHeight ? 14.0 : 16.0);
                final statusFontSize = isVeryConstrained
                    ? 10.0
                    : (isSmallHeight ? 11.0 : 13.0);
                final buttonSize = isVeryConstrained
                    ? 32.0
                    : (isSmallHeight ? 40.0 : 48.0);
                final buttonSpacing = isVeryConstrained
                    ? 8.0
                    : (isSmallHeight ? 12.0 : 16.0);
                final iconSize = isVeryConstrained
                    ? 16.0
                    : (isSmallHeight ? 20.0 : 24.0);
                final verticalSpacing1 = isVeryConstrained
                    ? 2.0
                    : (isSmallHeight ? 4.0 : 8.0);
                final verticalSpacing2 = isVeryConstrained
                    ? 2.0
                    : (isSmallHeight ? 6.0 : 10.0);

                // Use SingleChildScrollView for very constrained spaces
                final content = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: isVeryConstrained
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  children: [
                    // Progress Indicator (Responsive)
                    SizedBox(
                      width: circleSize,
                      height: circleSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _viewModel.progress,
                            strokeWidth: isVeryConstrained
                                ? 3
                                : (isSmallHeight ? 4 : 5),
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
                                fontSize: timerFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalSpacing1),

                    // Timer Status (Responsive)
                    Semantics(
                      label: _getTimerStatusDescription(),
                      liveRegion: true,
                      child: Text(
                        _getTimerStatusText(),
                        style: TextStyle(
                          fontSize: statusFontSize,
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing2),

                    // Action Buttons (Responsive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Start/Resume Button
                        if (_viewModel.canStart || _viewModel.canResume)
                          Semantics(
                            button: true,
                            label: _viewModel.canStart
                                ? "Start timer"
                                : "Resume timer",
                            child: ElevatedButton(
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.all(
                                  isVeryConstrained
                                      ? 6
                                      : (isSmallHeight ? 10 : 12),
                                ),
                                minimumSize: Size(buttonSize, buttonSize),
                                shape: const CircleBorder(),
                              ),
                              child: Icon(
                                _viewModel.canStart
                                    ? Icons.play_arrow
                                    : Icons.play_arrow,
                                size: iconSize,
                              ),
                            ),
                          ),

                        SizedBox(width: buttonSpacing),

                        // Pause Button
                        if (_viewModel.canPause)
                          Semantics(
                            button: true,
                            label: "Pause timer",
                            child: ElevatedButton(
                              onPressed: () {
                                _viewModel.pauseTimer();
                                SemanticsService.announce(
                                  "Timer paused",
                                  TextDirection.ltr,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.all(
                                  isVeryConstrained
                                      ? 6
                                      : (isSmallHeight ? 10 : 12),
                                ),
                                minimumSize: Size(buttonSize, buttonSize),
                                shape: const CircleBorder(),
                              ),
                              child: Icon(Icons.pause, size: iconSize),
                            ),
                          ),

                        SizedBox(width: buttonSpacing),

                        // Reset Button
                        if (_viewModel.canReset)
                          Semantics(
                            button: true,
                            label: "Reset timer",
                            child: OutlinedButton(
                              onPressed: () {
                                _viewModel.resetTimer();
                                SemanticsService.announce(
                                  "Timer reset to ${_viewModel.selectedDurationMinutes} minutes",
                                  TextDirection.ltr,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange.shade700,
                                side: BorderSide(color: Colors.orange.shade300),
                                padding: EdgeInsets.all(
                                  isVeryConstrained
                                      ? 6
                                      : (isSmallHeight ? 10 : 12),
                                ),
                                minimumSize: Size(buttonSize, buttonSize),
                                shape: const CircleBorder(),
                              ),
                              child: Icon(Icons.refresh, size: iconSize),
                            ),
                          ),
                      ],
                    ),
                  ],
                );

                // Use scrollable view for very constrained spaces
                return isVeryConstrained
                    ? SingleChildScrollView(child: content)
                    : content;
              },
            ),
          ),
          SizedBox(height: isSmallHeight ? 4 : 6),

          // Compact Instructions
          Text(
            "Switch to your repertoire app for focused practice",
            style: TextStyle(
              fontSize: isSmallHeight ? 10 : 11,
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
