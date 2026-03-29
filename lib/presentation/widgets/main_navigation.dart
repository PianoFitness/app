import "package:flutter/material.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_page.dart";
import "package:piano_fitness/presentation/features/history/history_page.dart";
import "package:piano_fitness/presentation/features/play/play_page.dart";
import "package:piano_fitness/presentation/features/practice/practice_hub_page.dart";
import "package:piano_fitness/presentation/features/reference/reference_page.dart";
import "package:piano_fitness/presentation/features/repertoire/repertoire_page.dart";
import "package:piano_fitness/presentation/features/user_profile/user_profile_page.dart";
import "package:provider/provider.dart";

/// Main navigation wrapper that provides bottom navigation between core app sections.
///
/// This widget manages the primary navigation structure of the Piano Fitness app,
/// allowing users to switch between Free Play mode and structured Practice sessions.
class MainNavigation extends StatefulWidget {
  /// Creates the main navigation wrapper.
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  /// The main pages available through bottom navigation.
  static final List<Widget> _pages = <Widget>[
    const PlayPage(),
    const PracticeHubPage(),
    const ReferencePage(),
    const RepertoirePage(),
    const HistoryPage(),
  ];

  /// Page titles for the app bar.
  static const List<String> _pageTitles = [
    "Free Play",
    "Practice",
    "Reference",
    "Repertoire",
    "History",
  ];

  /// Page icons for the app bar.
  static const List<IconData> _pageIcons = [
    Icons.piano,
    Icons.school,
    Icons.library_books,
    Icons.library_music,
    Icons.history,
  ];

  /// Handles bottom navigation item taps.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Semantics(
          header: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_pageIcons[_selectedIndex], color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(_pageTitles[_selectedIndex]),
            ],
          ),
        ),
        actions: [
          // Active profile display
          _buildProfileButton(context),
          IconButton(
            key: const Key("midi_settings_button"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const MidiSettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: "MIDI Settings",
          ),
          IconButton(
            key: const Key("notification_settings_button"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
            tooltip: "Notification Settings",
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        key: const Key("bottom_navigation_bar"),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Semantics(
              key: const Key("nav_tab_free_play"),
              button: true,
              child: const Icon(Icons.piano),
            ),
            label: "Free Play",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              key: const Key("nav_tab_practice"),
              button: true,
              child: const Icon(Icons.school),
            ),
            label: "Practice",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              key: const Key("nav_tab_reference"),
              button: true,
              child: const Icon(Icons.library_books),
            ),
            label: "Reference",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              key: const Key("nav_tab_repertoire"),
              button: true,
              child: const Icon(Icons.library_music),
            ),
            label: "Repertoire",
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              key: const Key("nav_tab_history"),
              button: true,
              child: const Icon(Icons.history),
            ),
            label: "History",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Builds the active profile button for the app bar.
  Widget _buildProfileButton(BuildContext context) {
    final repository = context.read<IUserProfileRepository>();

    return FutureBuilder<String?>(
      future: _getActiveProfileName(repository),
      builder: (context, snapshot) {
        final profileName = snapshot.data ?? "Select Profile";

        return TextButton.icon(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const UserProfilePage(),
              ),
            );
            // Rebuild to show updated profile name (only if still mounted)
            if (mounted) {
              setState(() {});
            }
          },
          icon: const Icon(Icons.person, size: 20),
          label: Text(
            profileName.length > 12
                ? "${profileName.substring(0, 12)}..."
                : profileName,
            style: Theme.of(context).textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  /// Gets the active profile's display name.
  Future<String?> _getActiveProfileName(
    IUserProfileRepository repository,
  ) async {
    try {
      final activeId = await repository.getActiveProfileId();
      if (activeId == null) return null;

      final profile = await repository.getProfile(activeId);
      return profile?.displayName;
    } catch (e) {
      return null;
    }
  }
}
