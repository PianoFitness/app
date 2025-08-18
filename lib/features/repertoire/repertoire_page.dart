import "package:flutter/material.dart";
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

              // Practice Timer Section (Placeholder for Phase 2)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          "Practice Timer",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Practice timer coming in the next update! This will help you time your repertoire sessions.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
