import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'common.dart';

/// Slide-up route for the full player.
Route<void> playerRoute(BuildContext context) {
  final d = motion(context, 320);
  return PageRouteBuilder<void>(
    fullscreenDialog: true,
    transitionDuration: d,
    reverseTransitionDuration: d,
    pageBuilder: (context, animation, secondaryAnimation) =>
        const PlayerScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero)
          .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// Compact now-playing control shown across the app; tap to open the player.
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = s.current;
    final scheme = Theme.of(context).colorScheme;
    final roomy = MediaQuery.sizeOf(context).width >= 400;
    return AnimatedSize(
      duration: motion(context),
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: t == null
          ? const SizedBox(width: double.infinity)
          : Material(
              color: scheme.surfaceContainerHigh,
              child: InkWell(
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(playerRoute(context)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: s.progress),
                    duration: motion(context, 900),
                    builder: (context, v, _) =>
                        LinearProgressIndicator(value: v, minHeight: 3),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: [
                      Artwork(
                          colors: t.colors, icon: t.icon, size: 44, radius: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text('${t.artist} · Demo player',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ]),
                      ),
                      if (roomy)
                        IconButton(
                            tooltip: 'Previous track',
                            onPressed: s.previous,
                            icon: const Icon(Icons.skip_previous)),
                      IconButton.filled(
                        tooltip: s.playing ? 'Pause' : 'Play',
                        onPressed: s.togglePlay,
                        icon: Icon(s.playing ? Icons.pause : Icons.play_arrow),
                      ),
                      IconButton(
                          tooltip: 'Next track',
                          onPressed: s.next,
                          icon: const Icon(Icons.skip_next)),
                    ]),
                  ),
                ]),
              ),
            ),
    );
  }
}

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = s.current;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final close = IconButton(
      tooltip: 'Close player',
      icon: const Icon(Icons.keyboard_arrow_down),
      onPressed: () => Navigator.of(context).pop(),
    );
    if (t == null) {
      return Scaffold(
        appBar: AppBar(leading: close),
        body: const EmptyState(
            icon: Icons.music_off,
            title: 'Nothing playing',
            message: 'Pick a track to start the demo player.'),
      );
    }
    final art = Center(
      child: AnimatedSwitcher(
        duration: motion(context, 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
              scale: Tween<double>(begin: .94, end: 1).animate(anim),
              child: child),
        ),
        child: ConstrainedBox(
          key: ValueKey(t.id),
          constraints: const BoxConstraints(maxWidth: 340),
          child: AspectRatio(
              aspectRatio: 1,
              child: Artwork(colors: t.colors, icon: t.icon, radius: 24)),
        ),
      ),
    );
    final controls =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t.title,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('${t.artist} — ${t.album}',
          style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 16),
      Slider(
        value: s.position.toDouble().clamp(0, t.seconds.toDouble()),
        max: t.seconds.toDouble(),
        onChanged: s.seek,
        semanticFormatterCallback: (v) =>
            '${formatTime(v.round())} of ${t.duration}',
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(formatTime(s.position)),
        Text(t.duration),
      ]),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
            tooltip: 'Shuffle up next',
            onPressed: s.shuffleUpcoming,
            icon: const Icon(Icons.shuffle)),
        IconButton(
            iconSize: 36,
            tooltip: 'Previous track',
            onPressed: s.previous,
            icon: const Icon(Icons.skip_previous)),
        IconButton.filled(
          iconSize: 40,
          tooltip: s.playing ? 'Pause' : 'Play',
          onPressed: s.togglePlay,
          icon: Icon(s.playing ? Icons.pause : Icons.play_arrow),
        ),
        IconButton(
            iconSize: 36,
            tooltip: 'Next track',
            onPressed: s.next,
            icon: const Icon(Icons.skip_next)),
        IconButton(
          tooltip: s.repeat ? 'Repeat queue: on' : 'Repeat queue: off',
          onPressed: s.toggleRepeat,
          icon: Icon(Icons.repeat, color: s.repeat ? scheme.primary : null),
        ),
      ]),
      Align(
        alignment: Alignment.center,
        child: TextButton.icon(
          onPressed: () => s.toggleFavorite(t.id),
          icon:
              Icon(s.isFavorite(t.id) ? Icons.favorite : Icons.favorite_border),
          label: Text(s.isFavorite(t.id) ? 'In favorites' : 'Add to favorites'),
        ),
      ),
    ]);
    final upNext = s.upNext.take(8).toList();
    return Scaffold(
      appBar: AppBar(leading: close, title: const Text('Now playing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: LayoutBuilder(builder: (context, box) {
              final wide = box.maxWidth >= 760;
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Chip(
                        avatar: const Icon(Icons.info_outline, size: 18),
                        label: const Text(
                            'Demo player · simulated playback, no audio'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (wide)
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 340, child: art),
                            const SizedBox(width: 32),
                            Expanded(child: controls),
                          ])
                    else ...[art, const SizedBox(height: 24), controls],
                    const SizedBox(height: 24),
                    const SectionHeader('Up next'),
                    if (upNext.isEmpty)
                      Text('Nothing queued after this track.',
                          style: TextStyle(color: scheme.onSurfaceVariant))
                    else
                      for (var i = 0; i < upNext.length; i++)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Artwork(
                              colors: upNext[i].colors,
                              icon: upNext[i].icon,
                              size: 40,
                              radius: 8),
                          title: Text(upNext[i].title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(upNext[i].artist,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Text(upNext[i].duration),
                          onTap: () => s.jumpTo(s.queueIndex + 1 + i),
                        ),
                  ]);
            }),
          ),
        ),
      ),
    );
  }
}
