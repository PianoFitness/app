import "package:flutter/material.dart";
import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/history/history_page.dart";
import "package:piano_fitness/presentation/features/metronome/metronome_page.dart";
import "package:piano_fitness/presentation/features/metronome/widgets/metronome_quick_panel.dart";
import "package:piano_fitness/presentation/features/midi_settings/midi_settings_page.dart";
import "package:piano_fitness/presentation/features/notifications/notifications_page.dart";
import "package:piano_fitness/presentation/features/play/play_page.dart";
import "package:piano_fitness/presentation/features/practice/practice_hub_page.dart";
import "package:piano_fitness/presentation/features/reference/reference_page.dart";
import "package:piano_fitness/presentation/features/repertoire/repertoire_page.dart";
import "package:piano_fitness/presentation/features/skill_progression/skill_tree_page.dart";
import "package:piano_fitness/presentation/features/user_profile/user_profile_page.dart";
import "package:piano_fitness/presentation/widgets/main_navigation_scope.dart";
import "package:provider/provider.dart";

final List<Widget> _pages = <Widget>[
  const SkillTreePage(),
  const PracticeHubPage(),
  const PlayPage(),
  const ReferencePage(),
  const RepertoirePage(),
  const HistoryPage(),
];

const List<String> _pageTitles = [
  "Curriculum",
  "Practice",
  "Free Play",
  "Reference",
  "Repertoire",
  "History",
];

const List<IconData> _pageIcons = [
  Icons.menu_book,
  Icons.school,
  Icons.piano,
  Icons.library_books,
  Icons.library_music,
  Icons.history,
];

const List<Key> _bottomTabKeys = [
  Key("nav_tab_curriculum"),
  Key("nav_tab_practice"),
  Key("nav_tab_free_play"),
  Key("nav_tab_reference"),
  Key("nav_tab_repertoire"),
  Key("nav_tab_history"),
];

const List<Key> _drawerTabKeys = [
  Key("drawer_tab_curriculum"),
  Key("drawer_tab_practice"),
  Key("drawer_tab_free_play"),
  Key("drawer_tab_reference"),
  Key("drawer_tab_repertoire"),
  Key("drawer_tab_history"),
];

/// Persistent application shell for sections, utilities, and nested routes.
///
/// Detail pages are pushed onto [_contentNavigatorKey], so the shell app bar
/// remains available instead of being covered by each new route.
class MainNavigation extends StatefulWidget {
  /// Creates the main navigation shell.
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final _contentNavigatorKey = GlobalKey<NavigatorState>();
  late final NavigatorObserver _contentNavigatorObserver;
  late final ValueNotifier<int> _selectedIndexNotifier;

  int _selectedIndex = 0;
  bool _contentCanPop = false;
  String? _contentRouteTitle;

  @override
  void initState() {
    super.initState();
    _selectedIndexNotifier = ValueNotifier(_selectedIndex);
    _contentNavigatorObserver = _ContentNavigatorObserver(
      onChanged: _synchronizeContentRoute,
    );
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  void _synchronizeContentRoute(Route<dynamic>? route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final canPop = _contentNavigatorKey.currentState?.canPop() ?? false;
      final title = canPop ? route?.settings.name : null;
      if (_contentCanPop == canPop && _contentRouteTitle == title) return;
      setState(() {
        _contentCanPop = canPop;
        _contentRouteTitle = title;
      });
    });
  }

  Route<void> _buildContentRootRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: "app-root"),
      builder: (context) => ValueListenableBuilder<int>(
        valueListenable: _selectedIndexNotifier,
        builder: (context, selectedIndex, child) =>
            IndexedStack(index: selectedIndex, children: _pages),
      ),
    );
  }

  void _onItemTapped(int index) {
    _contentNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    _selectedIndexNotifier.value = index;
    setState(() {
      _selectedIndex = index;
      _contentCanPop = false;
      _contentRouteTitle = null;
    });
  }

  Future<T?> _pushContentPage<T>(Widget page, String title) {
    return _contentNavigatorKey.currentState!.push<T>(
      MaterialPageRoute<T>(
        settings: RouteSettings(name: title),
        builder: (context) => page,
      ),
    );
  }

  Future<void> _openProfilePage() async {
    final repository = context.read<IUserProfileRepository>();
    final profileIdBefore = await repository.getActiveProfileId();
    await _pushContentPage<void>(const UserProfilePage(), "Profiles");
    if (!mounted) return;
    final profileIdAfter = await repository.getActiveProfileId();
    if (!mounted || profileIdBefore == profileIdAfter) return;

    // Recreate the root route so profile-scoped page subscriptions reload.
    _contentNavigatorKey.currentState?.pushAndRemoveUntil<void>(
      _buildContentRootRoute(),
      (route) => false,
    );
    setState(() {
      _contentCanPop = false;
      _contentRouteTitle = null;
    });
  }

  Widget _buildNavIcon(int index) {
    return Semantics(
      key: _bottomTabKeys[index],
      button: true,
      child: Icon(_pageIcons[index]),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      key: const Key("navigation_drawer"),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                Spacing.sm,
              ),
              child: Text(
                "Piano Fitness",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (var i = 0; i < _pageTitles.length; i++)
              ListTile(
                key: _drawerTabKeys[i],
                leading: Icon(_pageIcons[i]),
                title: Text(_pageTitles[i]),
                selected: !_contentCanPop && i == _selectedIndex,
                onTap: () {
                  Navigator.of(context).pop();
                  _onItemTapped(i);
                },
              ),
            const Divider(),
            ListTile(
              key: const Key("drawer_metronome"),
              leading: const Icon(Icons.timer),
              title: const Text("Metronome"),
              onTap: () {
                Navigator.of(context).pop();
                _pushContentPage<void>(const MetronomePage(), "Metronome");
              },
            ),
            ListTile(
              key: const Key("midi_settings_button"),
              leading: const Icon(Icons.settings_input_component),
              title: const Text("MIDI Settings"),
              onTap: () {
                Navigator.of(context).pop();
                _pushContentPage<void>(
                  const MidiSettingsPage(),
                  "MIDI Settings",
                );
              },
            ),
            ListTile(
              key: const Key("notification_settings_button"),
              leading: const Icon(Icons.notifications_outlined),
              title: const Text("Notifications"),
              onTap: () {
                Navigator.of(context).pop();
                _pushContentPage<void>(
                  const NotificationsPage(),
                  "Notifications",
                );
              },
            ),
            ListTile(
              key: const Key("profile_button"),
              leading: const Icon(Icons.person_outline),
              title: const Text("Switch profile"),
              onTap: () {
                Navigator.of(context).pop();
                _openProfilePage();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return PopScope(
      canPop: !_contentCanPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _contentCanPop) {
          _contentNavigatorKey.currentState?.maybePop();
        }
      },
      child: Scaffold(
        key: const Key("main_navigation_scaffold"),
        drawer: _buildDrawer(context),
        appBar: AppBar(
          backgroundColor: colorScheme.inversePrimary,
          toolbarHeight: ComponentDimensions.minTouchTarget,
          automaticallyImplyLeading: false,
          leadingWidth: _contentCanPop ? 96 : 56,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_contentCanPop)
                IconButton(
                  key: const Key("content_back_button"),
                  tooltip: "Back",
                  onPressed: () =>
                      _contentNavigatorKey.currentState?.maybePop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              Builder(
                builder: (context) => IconButton(
                  key: const Key("global_navigation_menu_button"),
                  tooltip: "Open navigation",
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                ),
              ),
            ],
          ),
          title: Semantics(
            header: true,
            child: Text(
              _contentRouteTitle ?? _pageTitles[_selectedIndex],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: [
            _MetronomeAppBarButton(
              onOpenFullPage: () =>
                  _pushContentPage<void>(const MetronomePage(), "Metronome"),
            ),
          ],
        ),
        body: MainNavigationScope(
          child: Navigator(
            key: _contentNavigatorKey,
            observers: [_contentNavigatorObserver],
            onGenerateRoute: (settings) => _buildContentRootRoute(),
          ),
        ),
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
      ),
    );
  }
}

class _ContentNavigatorObserver extends NavigatorObserver {
  _ContentNavigatorObserver({required this.onChanged});

  final ValueChanged<Route<dynamic>?> onChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onChanged(newRoute);
  }
}

class _MetronomeAppBarButton extends StatelessWidget {
  const _MetronomeAppBarButton({required this.onOpenFullPage});

  final VoidCallback onOpenFullPage;

  @override
  Widget build(BuildContext context) {
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
      builder: (context) => MetronomeQuickPanel(onOpenFullPage: onOpenFullPage),
    );
  }
}
