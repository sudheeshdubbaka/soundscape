import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : (h < 18 ? 'Good afternoon' : 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loading) return const Scaffold(body: LoadingView());
    final w = MediaQuery.sizeOf(context).width;
    final text = Theme.of(context).textTheme;
    final recent = s.recentTracks;
    final curated = s.playlists.where((p) => !p.custom).toList();
    return Scaffold(
      body: PageBody(
        child: ListView(padding: pagePadding(w), children: [
          Text(_greeting(),
              style:
                  text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Pick up where you left off.', style: text.bodyLarge),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ActionChip(
                avatar: const Icon(Icons.search, size: 18),
                label: const Text('Search catalog'),
                onPressed: () => goTab(context, 1)),
            ActionChip(
                avatar: const Icon(Icons.favorite, size: 18),
                label: const Text('Liked songs'),
                onPressed: () => goTab(context, 2)),
            ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('New playlist'),
                onPressed: () => Navigator.pushNamed(context, '/create')),
            ActionChip(
                avatar: const Icon(Icons.shuffle, size: 18),
                label: const Text('Shuffle all'),
                onPressed: () => s.playAll(catalog, shuffle: true)),
          ]),
          const SizedBox(height: 24),
          _Featured(playlist: curated.first),
          const SizedBox(height: 24),
          const SectionHeader('Recently played'),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recent.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) => TrackCard(track: recent[i], queue: recent),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Made for you'),
          PlaylistGrid(playlists: curated),
        ]),
      ),
    );
  }
}

class _Featured extends StatelessWidget {
  const _Featured({required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final tracks = s.tracksOf(playlist);
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/playlist', arguments: playlist.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(builder: (context, box) {
            final narrow = box.maxWidth < 560;
            final art = Artwork(
                colors: playlist.colors,
                icon: playlist.icon,
                size: narrow ? 120 : 160,
                radius: 16);
            final info = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('FEATURED PLAYLIST',
                      style: text.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(playlist.name,
                      style: text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(playlist.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.icon(
                        onPressed: () => s.playAll(tracks),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play')),
                    OutlinedButton.icon(
                        onPressed: () => s.playAll(tracks, shuffle: true),
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle')),
                  ]),
                ]);
            return narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [art, const SizedBox(height: 16), info])
                : Row(children: [
                    art,
                    const SizedBox(width: 24),
                    Expanded(child: info)
                  ]);
          }),
        ),
      ),
    );
  }
}
