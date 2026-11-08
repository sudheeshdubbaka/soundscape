import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String? _genre;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _query = '';
      _genre = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final w = MediaQuery.sizeOf(context).width;
    final searching = _query.trim().isNotEmpty || _genre != null;
    return Scaffold(
      body: PageBody(
        child: Padding(
          padding: pagePadding(w),
          child: Column(children: [
            SearchBar(
              controller: _controller,
              hintText: 'Search songs, artists, albums',
              leading: const Icon(Icons.search),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: _clear),
              ],
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: s.loading
                  ? const LoadingView()
                  : AnimatedSwitcher(
                      duration: motion(context),
                      child: searching ? _results(s) : _genres(),
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _genres() => Column(
        key: const ValueKey('genres'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Browse all'),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.9,
              ),
              itemCount: genres.length,
              itemBuilder: (_, i) => _GenreTile(
                  genre: genres[i],
                  onTap: () => setState(() => _genre = genres[i].name)),
            ),
          ),
        ],
      );

  Widget _results(AppState s) {
    final results = s.search(_query, genre: _genre);
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_genre != null)
                InputChip(
                    label: Text(_genre!),
                    onDeleted: () => setState(() => _genre = null)),
              Text(
                  '${results.length} ${results.length == 1 ? 'result' : 'results'}'),
            ]),
        const SizedBox(height: 8),
        Expanded(
          child: results.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'No matches',
                  message:
                      'Nothing in the catalog matches “${_query.trim()}”. Try a different title, artist or genre.',
                  action: OutlinedButton(
                      onPressed: _clear, child: const Text('Clear search')),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 560,
                    mainAxisExtent: 72,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: results.length,
                  itemBuilder: (_, i) =>
                      TrackTile(track: results[i], queue: results),
                ),
        ),
      ],
    );
  }
}

class _GenreTile extends StatelessWidget {
  const _GenreTile({required this.genre, required this.onTap});
  final Genre genre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Browse ${genre.name}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: genre.colors),
              ),
            ),
            Positioned(
                right: -8,
                bottom: -8,
                child: Icon(genre.icon, size: 72, color: Colors.white24)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(genre.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            Positioned.fill(
                child: Material(
                    color: Colors.transparent, child: InkWell(onTap: onTap))),
          ]),
        ),
      );
}
