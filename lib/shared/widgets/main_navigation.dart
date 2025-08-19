import "package:flutter/material.dart";
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

  /// Handles bottom navigation item taps.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
