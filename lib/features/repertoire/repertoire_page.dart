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

  Widget _buildCompactTimerSection(bool isSmallHeight, bool isLandscape) {
    // Responsive sizing
    final containerPadding = isSmallHeight ? 12.0 : 16.0;
    final headerSpacing = isSmallHeight ? 8.0 : 12.0;
    final sectionSpacing = isSmallHeight ? 12.0 : 16.0;
    final fontSize = isSmallHeight ? 15.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
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
              Icon(
                Icons.schedule,
                color: const Color(0xFF6366F1),
                size: isSmallHeight ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Practice Timer",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: headerSpacing),

          // Enhanced Duration Selector
          _buildEnhancedDurationSelector(isSmallHeight),
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
                    // Enhanced Timer Display with Musical Elements
                    Container(
                      width: circleSize + 16,
                      height: circleSize + 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.white, const Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Gradient Progress Ring
                              CircularProgressIndicator(
                                value: _viewModel.progress,
                                strokeWidth: isVeryConstrained ? 4 : 6,
                                backgroundColor: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _viewModel.isRunning
                                      ? const Color(
                                          0xFF10B981,
                                        ) // Green when running
                                      : const Color(
                                          0xFF6366F1,
                                        ), // Indigo when paused/stopped
                                ),
                              ),
                              // Inner gradient circle
                              Container(
                                width: circleSize - 20,
                                height: circleSize - 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white,
                                      const Color(
                                        0xFF6366F1,
                                      ).withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                              ),
                              // Time Display
                              Semantics(
                                label:
                                    "Timer display: ${_viewModel.formattedTime} remaining",
                                liveRegion: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!isVeryConstrained)
                                      Icon(
                                        Icons.music_note,
                                        size: timerFontSize * 0.8,
                                        color: _viewModel.isRunning
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF6366F1),
                                      ),
                                    Text(
                                      _viewModel.formattedTime,
                                      style: TextStyle(
                                        fontSize: timerFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF6366F1),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing1),

                    // Enhanced Timer Status with Better Feedback
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isVeryConstrained ? 8 : 12,
                        vertical: isVeryConstrained ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor().withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: statusFontSize,
                            color: _getStatusColor(),
                          ),
                          const SizedBox(width: 4),
                          Semantics(
                            label: _getTimerStatusDescription(),
                            liveRegion: true,
                            child: Text(
                              _getTimerStatusText(),
                              style: TextStyle(
                                fontSize: statusFontSize,
                                color: _getStatusColor(),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalSpacing2),

                    // Action Buttons (Responsive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Enhanced Start/Resume Button
                        if (_viewModel.canStart || _viewModel.canResume)
                          Semantics(
                            button: true,
                            label: _viewModel.canStart
                                ? "Start timer"
                                : "Resume timer",
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF059669),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
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
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
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
                          ),

                        SizedBox(width: buttonSpacing),

                        // Enhanced Pause Button
                        if (_viewModel.canPause)
                          Semantics(
                            button: true,
                            label: "Pause timer",
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _viewModel.pauseTimer();
                                  SemanticsService.announce(
                                    "Timer paused",
                                    TextDirection.ltr,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
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
                          ),

                        SizedBox(width: buttonSpacing),

                        // Enhanced Reset Button
                        if (_viewModel.canReset)
                          Semantics(
                            button: true,
                            label: "Reset timer",
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6366F1),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: OutlinedButton(
                                onPressed: () {
                                  _viewModel.resetTimer();
                                  SemanticsService.announce(
                                    "Timer reset to ${_viewModel.selectedDurationMinutes} minutes",
                                    TextDirection.ltr,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6366F1),
                                  backgroundColor: Colors.white,
                                  side: BorderSide.none,
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

  Color _getStatusColor() {
    if (_viewModel.isRunning && !_viewModel.isPaused) {
      return const Color(0xFF10B981); // Green for running
    } else if (_viewModel.isPaused) {
      return const Color(0xFFF59E0B); // Amber for paused
    } else if (_viewModel.remainingSeconds == 0) {
      return const Color(0xFF8B5CF6); // Purple for completed
    } else {
      return const Color(0xFF6366F1); // Indigo for ready
    }
  }

  IconData _getStatusIcon() {
    if (_viewModel.isRunning && !_viewModel.isPaused) {
      return Icons.play_circle_filled;
    } else if (_viewModel.isPaused) {
      return Icons.pause_circle_filled;
    } else if (_viewModel.remainingSeconds == 0) {
      return Icons.celebration;
    } else {
      return Icons.schedule;
    }
  }

  Widget _buildEnhancedDurationSelector(bool isSmallHeight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: const Color(0xFF6366F1),
                size: isSmallHeight ? 16 : 18,
              ),
              const SizedBox(width: 6),
              Text(
                "Practice Duration",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallHeight ? 13 : 14,
                  color: const Color(0xFF6366F1),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RepertoirePageViewModel.timerDurations.map((duration) {
              final isSelected = _viewModel.selectedDurationMinutes == duration;
              final isRecommended = duration == 15;

              return Semantics(
                label:
                    "$duration minutes${isRecommended ? ', recommended' : ''}",
                selected: isSelected,
                child: Material(
                  elevation: isSelected ? 4 : 1,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _viewModel.canStart
                        ? () {
                            _viewModel.setDuration(duration);
                            SemanticsService.announce(
                              "$duration minutes selected",
                              TextDirection.ltr,
                            );
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallHeight ? 12 : 16,
                        vertical: isSmallHeight ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: isRecommended && !isSelected
                            ? Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${duration}m",
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallHeight ? 12 : 13,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: isSmallHeight ? 10 : 12,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFF59E0B),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_viewModel.selectedDurationMinutes == 15)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "⭐ Recommended for focused practice",
                style: TextStyle(
                  fontSize: isSmallHeight ? 11 : 12,
                  color: const Color(0xFFF59E0B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
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
