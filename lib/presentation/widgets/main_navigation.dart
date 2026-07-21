import "package:flutter/material.dart";
import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_quick_panel.dart";
import "package:piano_fitness/presentation/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_page.dart";
import "package:piano_fitness/presentation/features/history/history_page.dart";
import "package:piano_fitness/presentation/features/play/play_page.dart";
import "package:piano_fitness/presentation/features/practice/practice_hub_page.dart";
import "package:piano_fitness/presentation/features/reference/reference_page.dart";
import "package:piano_fitness/presentation/features/repertoire/repertoire_page.dart";
import "package:piano_fitness/presentation/features/user_profile/user_profile_page.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
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

  /// Stable keys for each tab's icon, shared between the bottom nav bar
  /// (portrait) and navigation drawer (landscape) so tests can find a tab
  /// regardless of which layout is active.
  static const List<Key> _tabKeys = [
    Key("nav_tab_free_play"),
    Key("nav_tab_practice"),
    Key("nav_tab_reference"),
    Key("nav_tab_repertoire"),
    Key("nav_tab_history"),
  ];

  /// Handles bottom navigation item taps.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavIcon(int index) {
    return Semantics(
      key: _tabKeys[index],
      button: true,
      child: Icon(_pageIcons[index]),
    );
  }

  /// Builds the landscape navigation drawer: closes itself after a
  /// selection so it never occupies screen space while not in use.
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      key: const Key("navigation_drawer"),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            for (var i = 0; i < _pageTitles.length; i++)
              ListTile(
                key: _tabKeys[i],
                leading: Icon(_pageIcons[i]),
                title: Text(_pageTitles[i]),
                selected: i == _selectedIndex,
                onTap: () {
                  _onItemTapped(i);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the overflow menu for less-frequently-used settings pages.
  ///
  /// MIDI Settings and Notification Settings share one "more" icon instead
  /// of each getting a dedicated app bar icon - the app bar is otherwise
  /// too narrow on phone-width screens once the profile button and the
  /// metronome quick-access icon are also present.
  Widget _buildMoreActionsButton(BuildContext context) {
    return PopupMenuButton<_MoreAction>(
      key: const Key("more_actions_button"),
      tooltip: "More options",
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        final page = switch (action) {
          _MoreAction.midiSettings => const MidiSettingsPage(),
          _MoreAction.notificationSettings => const NotificationsPage(),
        };
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (context) => page));
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          key: Key("midi_settings_button"),
          value: _MoreAction.midiSettings,
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text("MIDI Settings"),
          ),
        ),
        PopupMenuItem(
          key: Key("notification_settings_button"),
          value: _MoreAction.notificationSettings,
          child: ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notification Settings"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Landscape phones have little spare height for chrome, so navigation
    // moves into an auto-hiding drawer instead of a persistent bar/rail,
    // letting the piano and settings use the full width.
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      key: const Key("main_navigation_scaffold"),
      drawer: isLandscape ? _buildDrawer(context) : null,
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        toolbarHeight: ComponentDimensions.minTouchTarget,
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
          const _MetronomeAppBarButton(),
          _buildMoreActionsButton(context),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: isLandscape
          ? null
          : NavigationBar(
              key: const Key("bottom_navigation_bar"),
              height: ComponentDimensions.minTouchTarget + Spacing.sm,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: [
                for (var i = 0; i < _pageTitles.length; i++)
                  NavigationDestination(
                    icon: _buildNavIcon(i),
                    label: _pageTitles[i],
                  ),
              ],
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

/// Overflow menu entries built by [_MainNavigationState._buildMoreActionsButton].
enum _MoreAction { midiSettings, notificationSettings }

/// App bar icon that opens the metronome quick panel, available on every
/// page. Isolated into its own widget so only this icon (not the whole
/// navigation scaffold) rebuilds while the metronome is playing.
class _MetronomeAppBarButton extends StatelessWidget {
  const _MetronomeAppBarButton();

  @override
  Widget build(BuildContext context) {
    // Scoped to isPlaying/bpm rather than watching MetronomeState as a
    // whole, so this icon doesn't rebuild on every currentBeat change
    // (several times a second while playing).
    final isPlaying = context.select<MetronomeState, bool>(
      (state) => state.isPlaying,
    );
    final bpm = context.select<MetronomeState, int>((state) => state.bpm);
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      key: const Key("metronome_button"),
      icon: Icon(Icons.timer, color: isPlaying ? colorScheme.primary : null),
      tooltip: isPlaying ? "Metronome ($bpm BPM, playing)" : "Metronome",
      onPressed: () => _showMetronomePanel(context),
    );
  }

  void _showMetronomePanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.large),
        ),
      ),
      builder: (context) => const MetronomeQuickPanel(),
    );
  }
}
