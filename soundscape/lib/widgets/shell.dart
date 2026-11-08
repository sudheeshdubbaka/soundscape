import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/browse_screen.dart';
import '../screens/create_playlist_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/playlist_screen.dart';
import '../state/app_state.dart';
import 'common.dart';
import 'player.dart';

/// Key of the nested navigator that hosts all in-app screens.
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
const _tabRoutes = ['/', '/browse', '/library'];

/// Switches to a top-level tab from anywhere in the app.
void goTab(BuildContext context, int index) {
  context.read<AppState>().setTab(index);
  shellNavigatorKey.currentState?.pushNamedAndRemoveUntil(
    _tabRoutes[index],
    (route) => false,
  );
}

/// Adaptive shell: bottom bar (<600), rail (600-1100), extended rail (>=1100).
/// The now-playing bar sits below the nested navigator so it persists everywhere.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  Route<void> _route(BuildContext context, RouteSettings st) {
    final Widget page = switch (st.name) {
      '/browse' => const BrowseScreen(),
      '/library' => const LibraryScreen(),
      '/playlist' => PlaylistScreen(playlistId: st.arguments as String? ?? ''),
      '/create' => const CreatePlaylistScreen(),
      _ => const HomeScreen(),
    };
    final d = motion(context, 280);
    return PageRouteBuilder<void>(
      settings: st,
      transitionDuration: d,
      reverseTransitionDuration: d,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, .03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final tab = context.select<AppState, int>((s) => s.tab);
    final body = Column(
      children: [
        Expanded(
          child: Navigator(
            key: shellNavigatorKey,
            initialRoute: '/',
            onGenerateRoute: (st) => _route(context, st),
          ),
        ),
        const NowPlayingBar(),
      ],
    );

    if (w < 600) {
      return Scaffold(
        body: SafeArea(bottom: false, child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => goTab(context, i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'Browse'),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music),
              label: 'Library',
            ),
          ],
        ),
      );
    }

    final extended = w >= 1100;
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              extended: extended,
              selectedIndex: tab,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              onDestinationSelected: (i) => goTab(context, i),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.graphic_eq, color: primary, size: 32),
                    if (extended) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Soundscape',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Browse'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music),
                  label: Text('Library'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
