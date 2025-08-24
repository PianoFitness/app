import "package:flutter/material.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/features/notifications/notifications_page.dart";
import "package:piano_fitness/features/play/play_page.dart";
import "package:piano_fitness/features/practice/practice_hub_page.dart";
import "package:piano_fitness/features/reference/reference_page.dart";
import "package:piano_fitness/features/repertoire/repertoire_page.dart";

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
  ];

  /// Page titles for the app bar.
  static const List<String> _pageTitles = [
    "Free Play",
    "Practice",
    "Reference",
    "Repertoire",
  ];

  /// Page icons for the app bar.
  static const List<IconData> _pageIcons = [
    Icons.piano,
    Icons.school,
    Icons.library_books,
    Icons.library_music,
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
          IconButton(
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.piano), label: "Free Play"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Practice"),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: "Reference",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: "Repertoire",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
