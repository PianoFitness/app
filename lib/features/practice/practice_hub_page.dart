import "package:flutter/material.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";
import "package:piano_fitness/features/practice/practice_page.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";

/// Hub page for organized practice sessions.
///
/// This page provides a dedicated interface for accessing different types of
/// practice sessions, including scales, chords, arpeggios, and chord progressions.
/// It offers a more structured approach to practice compared to the free play mode.
class PracticeHubPage extends StatelessWidget {
  /// Creates the practice hub page.
  const PracticeHubPage({super.key});

  /// Normalize titles into predictable, ASCII-only keys (e.g., "C Major  Scale!" -> "c_major_scale")
  String _slugify(String s) {
    final slug = s
        .toLowerCase()
        .replaceAll(
          RegExp(r"[^a-z0-9]+"),
          "_",
        ) // collapse non-alnum into underscores
        .replaceAll(RegExp(r"_+"), "_"); // squeeze duplicate underscores
    return slug.replaceAll(
      RegExp(r"^_+|_+$"),
      "",
    ); // trim leading/trailing underscores
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              _buildPracticeModesSection(context),
              const SizedBox(height: 24),
              _buildQuickStartSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the welcome header section.
  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            Icons.music_note,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Structured Practice",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Choose your practice focus and develop your piano skills through guided exercises.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the practice modes grid section.
  Widget _buildPracticeModesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Practice Modes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildPracticeModesFirstRow(context),
        const SizedBox(height: 12),
        _buildPracticeModesSecondRow(context),
      ],
    );
  }

  /// Builds the first row of practice mode cards.
  Widget _buildPracticeModesFirstRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildPracticeModeCard(
              context,
              title: "Scales",
              icon: Icons.trending_up,
              description: "Major, minor, and modal scales",
              color: Theme.of(context).colorScheme.primary,
              onTap: () => _navigateToPractice(context, PracticeMode.scales),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPracticeModeCard(
              context,
              title: "Chords by Key",
              icon: Icons.piano,
              description: "Individual chord triads and inversions",
              color: Theme.of(context).colorScheme.secondary,
              onTap: () =>
                  _navigateToPractice(context, PracticeMode.chordsByKey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPracticeModeCard(
              context,
              title: "Chords by Type",
              icon: Icons.library_music,
              description: "Major, minor, diminished, augmented chords",
              color: Theme.of(context).colorScheme.tertiary,
              onTap: () =>
                  _navigateToPractice(context, PracticeMode.chordsByType),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the second row of practice mode cards.
  Widget _buildPracticeModesSecondRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildPracticeModeCard(
              context,
              title: "Arpeggios",
              icon: Icons.swap_vert,
              description: "Arpeggio patterns across multiple octaves",
              color:
                  Theme.of(context).extension<SemanticColors>()?.warning ??
                  Theme.of(context).colorScheme.tertiary,
              onTap: () => _navigateToPractice(context, PracticeMode.arpeggios),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPracticeModeCard(
              context,
              title: "Chord Progressions",
              icon: Icons.music_note,
              description: "Chord progressions using roman numeral notation",
              color: Theme.of(context).colorScheme.primary,
              onTap: () =>
                  _navigateToPractice(context, PracticeMode.chordProgressions),
            ),
          ),
          const SizedBox(width: 8),
          const Spacer(),
        ],
      ),
    );
  }

  /// Builds the quick start section with preset exercises.
  Widget _buildQuickStartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Quick Start",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
    // Create a key based on the title for test reliability
    final keyName = _slugify(title);

    return Card(
      elevation: 2,
      child: InkWell(
        key: Key("practice_mode_$keyName"),
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
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
    // Create a key based on the title for test reliability
    final keyName = _slugify(title);

    return Card(
      elevation: 1,
      child: ListTile(
        key: Key("quick_start_$keyName"),
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
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
