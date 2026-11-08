import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'common.dart';

/// Responsive grid of playlist cards; column count follows available width.
class PlaylistGrid extends StatelessWidget {
  const PlaylistGrid({super.key, required this.playlists});
  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: .72,
        ),
        itemCount: playlists.length,
        itemBuilder: (_, i) => PlaylistCard(playlist: playlists[i]),
      );
}

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final n = playlist.trackIds.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/playlist', arguments: playlist.id),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
              aspectRatio: 1,
              child: Artwork(
                  colors: playlist.colors, icon: playlist.icon, radius: 0)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall),
                    Text('$n ${n == 1 ? 'track' : 'tracks'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Compact square card used in horizontal "recently played" lists.
class TrackCard extends StatelessWidget {
  const TrackCard({super.key, required this.track, this.queue});
  final Track track;
  final List<Track>? queue;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.read<AppState>().playTrack(track, queue: queue),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Artwork(colors: track.colors, icon: track.icon, size: 138),
            const SizedBox(height: 8),
            Text(track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall),
            Text(track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall),
          ]),
        ),
      ),
    );
  }
}

/// Track row with play/pause, favorite and add-to-playlist controls.
class TrackTile extends StatelessWidget {
  const TrackTile({super.key, required this.track, this.queue});
  final Track track;
  final List<Track>? queue;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final isCurrent = s.current?.id == track.id;
    final isPlaying = isCurrent && s.playing;
    final fav = s.isFavorite(track.id);
    final showDuration = MediaQuery.sizeOf(context).width >= 560;
    return ListTile(
      selected: isCurrent,
      selectedTileColor: scheme.primaryContainer.withValues(alpha: .35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading:
          Artwork(colors: track.colors, icon: track.icon, size: 48, radius: 8),
      title: Text(track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${track.artist} · ${track.genre}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () => s.playTrack(track, queue: queue),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (showDuration)
          Text(track.duration, style: Theme.of(context).textTheme.bodySmall),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: fav
              ? 'Remove ${track.title} from favorites'
              : 'Add ${track.title} to favorites',
          onPressed: () => s.toggleFavorite(track.id),
          icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
              color: fav ? scheme.primary : null),
        ),
        IconButton(
          tooltip: isPlaying ? 'Pause ${track.title}' : 'Play ${track.title}',
          onPressed: () =>
              isCurrent ? s.togglePlay() : s.playTrack(track, queue: queue),
          icon: AnimatedSwitcher(
            duration: motion(context, 150),
            child: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                key: ValueKey(isPlaying),
                size: 32,
                color: isCurrent ? scheme.primary : null),
          ),
        ),
        _AddToPlaylistMenu(track: track),
      ]),
    );
  }
}

class _AddToPlaylistMenu extends StatelessWidget {
  const _AddToPlaylistMenu({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Add ${track.title} to a playlist',
      icon: const Icon(Icons.playlist_add),
      onSelected: (pid) {
        final s = context.read<AppState>();
        final name = s.playlistById(pid)?.name ?? 'playlist';
        final added = s.addToPlaylist(pid, track.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(added ? 'Added to $name' : 'Already in $name')),
        );
      },
      itemBuilder: (context) {
        final custom = context.read<AppState>().customPlaylists;
        if (custom.isEmpty) {
          return const [
            PopupMenuItem<String>(
                enabled: false, child: Text('Create a playlist first'))
          ];
        }
        return [
          for (final p in custom)
            PopupMenuItem<String>(value: p.id, child: Text('Add to ${p.name}'))
        ];
      },
    );
  }
}
