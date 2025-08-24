import "package:flutter/material.dart";
import "package:piano_fitness/features/practice/practice_page.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";

/// Hub page for organized practice sessions.
///
/// This page provides a dedicated interface for accessing different types of
/// practice sessions, including scales, chords, arpeggios, and chord progressions.
/// It offers a more structured approach to practice compared to the free play mode.
class PracticeHubPage extends StatelessWidget {
  /// Creates the practice hub page.
  const PracticeHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Row(
                  children: [
                    // Icon column (compact)
                    const Icon(
                      Icons.music_note,
                      size: 48,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 16),
                    // Text content column (expanded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Structured Practice",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Choose your practice focus and develop your piano skills through guided exercises.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Practice Modes Grid
              const Text(
                "Practice Modes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // First row of practice modes
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildPracticeModeCard(
                        context,
                        title: "Scales",
                        icon: Icons.trending_up,
                        description: "Major, minor, and modal scales",
                        color: Colors.blue,
                        onTap: () =>
                            _navigateToPractice(context, PracticeMode.scales),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPracticeModeCard(
                        context,
                        title: "Chords by Key",
                        icon: Icons.piano,
                        description: "Individual chord triads and inversions",
                        color: Colors.green,
                        onTap: () => _navigateToPractice(
                          context,
                          PracticeMode.chordsByKey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPracticeModeCard(
                        context,
                        title: "Chords by Type",
                        icon: Icons.library_music,
                        description:
                            "Major, minor, diminished, augmented chords",
                        color: Colors.teal,
                        onTap: () => _navigateToPractice(
                          context,
                          PracticeMode.chordsByType,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Second row of practice modes
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildPracticeModeCard(
                        context,
                        title: "Arpeggios",
                        icon: Icons.swap_vert,
                        description:
                            "Arpeggio patterns across multiple octaves",
                        color: Colors.orange,
                        onTap: () => _navigateToPractice(
                          context,
                          PracticeMode.arpeggios,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPracticeModeCard(
                        context,
                        title: "Chord Progressions",
                        icon: Icons.music_note,
                        description:
                            "Chord progressions using roman numeral notation",
                        color: Colors.purple,
                        onTap: () => _navigateToPractice(
                          context,
                          PracticeMode.chordProgressions,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Start Section
              const Text(
                "Quick Start",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildQuickStartCard(
                context,
                title: "Beginner Chord Progression",
                subtitle: "I - V in C Major",
                icon: Icons.play_circle_fill,
                onTap: () => _navigateToChordProgression(
                  context,
                  ChordProgressionLibrary.getProgressionByName("I - V")!,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickStartCard(
                context,
                title: "C Major Scale",
                subtitle: "All white keys",
                icon: Icons.keyboard,
                onTap: () => _navigateToPractice(context, PracticeMode.scales),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a practice mode card widget.
  Widget _buildPracticeModeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a quick start card widget.
  Widget _buildQuickStartCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// Navigates to the practice page with the specified mode.
  void _navigateToPractice(BuildContext context, PracticeMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PracticePage(initialMode: mode),
      ),
    );
  }

  /// Navigates to chord progression practice with a specific progression.
  void _navigateToChordProgression(
    BuildContext context,
    ChordProgression progression,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PracticePage(
          initialMode: PracticeMode.chordProgressions,
          initialChordProgression: progression,
        ),
      ),
    );
  }
}
