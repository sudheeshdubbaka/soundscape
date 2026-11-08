import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key, required this.playlistId});
  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final p = s.playlistById(playlistId);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
            icon: Icons.error_outline,
            title: 'Playlist not found',
            message: 'It may have been removed.'),
      );
    }
    final tracks = s.tracksOf(p);
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(),
      body: PageBody(
        maxWidth: 1000,
        child: ListView.builder(
          padding: pagePadding(w),
          itemCount: tracks.isEmpty ? 2 : tracks.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) return _Header(playlist: p, tracks: tracks);
            if (tracks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: EmptyState(
                  icon: Icons.library_music_outlined,
                  title: 'This playlist is empty',
                  message:
                      'Use the add-to-playlist button on any track to put it here.',
                  action: FilledButton(
                      onPressed: () => goTab(context, 1),
                      child: const Text('Find tracks')),
                ),
              );
            }
            return TrackTile(track: tracks[i - 1], queue: tracks);
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.playlist, required this.tracks});
  final Playlist playlist;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final text = Theme.of(context).textTheme;
    final minutes = tracks.fold<int>(0, (a, t) => a + t.seconds) ~/ 60;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(builder: (context, box) {
        final narrow = box.maxWidth < 600;
        final art = Artwork(
            colors: playlist.colors,
            icon: playlist.icon,
            size: narrow ? 200 : 220,
            radius: 20);
        final info = Column(
          crossAxisAlignment:
              narrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PLAYLIST',
                style: text.labelSmall?.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(playlist.name,
                textAlign: narrow ? TextAlign.center : TextAlign.start,
                style:
                    text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(playlist.description,
                textAlign: narrow ? TextAlign.center : TextAlign.start),
            const SizedBox(height: 4),
            Text(
                '${tracks.length} ${tracks.length == 1 ? 'track' : 'tracks'} · $minutes min',
                style: text.bodySmall),
            const SizedBox(height: 16),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: narrow ? WrapAlignment.center : WrapAlignment.start,
                children: [
                  FilledButton.icon(
                    onPressed: tracks.isEmpty ? null : () => s.playAll(tracks),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play all'),
                  ),
                  OutlinedButton.icon(
                    onPressed: tracks.isEmpty
                        ? null
                        : () => s.playAll(tracks, shuffle: true),
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Shuffle'),
                  ),
                ]),
          ],
        );
        return narrow
            ? Column(children: [art, const SizedBox(height: 16), info])
            : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                art,
                const SizedBox(width: 24),
                Expanded(child: info)
              ]);
      }),
    );
  }
}
