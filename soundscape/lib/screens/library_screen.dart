import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final w = MediaQuery.sizeOf(context).width;
    final ordered = [
      ...s.playlists.where((p) => p.custom),
      ...s.playlists.where((p) => !p.custom),
    ];
    final favs = s.favoriteTracks;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Library'),
          actions: [
            IconButton(
              tooltip: 'Create playlist',
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/create'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Playlists'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: s.loading
            ? const LoadingView()
            : TabBarView(
                children: [
                  PageBody(
                    child: ListView(
                      padding: pagePadding(w),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/create'),
                            icon: const Icon(Icons.add),
                            label: const Text('New playlist'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PlaylistGrid(playlists: ordered),
                      ],
                    ),
                  ),
                  favs.isEmpty
                      ? EmptyState(
                          icon: Icons.favorite_border,
                          title: 'No favorites yet',
                          message:
                              'Tap the heart on any track and it will show up here.',
                          action: FilledButton(
                            onPressed: () => goTab(context, 1),
                            child: const Text('Browse tracks'),
                          ),
                        )
                      : PageBody(
                          maxWidth: 900,
                          child: ListView.builder(
                            padding: pagePadding(w),
                            itemCount: favs.length + 1,
                            itemBuilder: (_, i) {
                              if (i == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${favs.length} favorite ${favs.length == 1 ? 'track' : 'tracks'}',
                                        ),
                                      ),
                                      FilledButton.icon(
                                        onPressed: () => s.playAll(favs),
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text('Play all'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return TrackTile(track: favs[i - 1], queue: favs);
                            },
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
