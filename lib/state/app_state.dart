import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/models.dart';

/// Shared app state: simulated playback, queue, favorites and playlists.
/// No audio is played; a timer advances [position] while [playing].
class AppState extends ChangeNotifier {
  AppState(
      {bool simulateLoading = true,
      this.tickInterval = const Duration(seconds: 1)}) {
    if (simulateLoading) {
      _loading = true;
      _loadTimer = Timer(const Duration(milliseconds: 700), () {
        _loading = false;
        notifyListeners();
      });
    }
  }

  final Duration tickInterval;
  final Random _rng = Random();
  final List<Playlist> _playlists = seedPlaylists();
  final Set<String> _favorites = {'t3', 't7', 't12'};
  final List<String> _recent = ['t1', 't5', 't9', 't2', 't14', 't6'];

  List<Track> _queue = [];
  int _index = -1;
  int _position = 0;
  int _seq = 0;
  int _tab = 0;
  bool _playing = false;
  bool _repeat = false;
  bool _loading = false;
  Timer? _loadTimer;
  Timer? _ticker;

  // ---- read access ----
  bool get loading => _loading;
  bool get playing => _playing;
  bool get repeat => _repeat;
  int get position => _position;
  int get queueIndex => _index;
  int get tab => _tab;
  Track? get current =>
      _index >= 0 && _index < _queue.length ? _queue[_index] : null;
  List<Track> get upNext => _index < 0 ? const [] : _queue.sublist(_index + 1);
  double get progress {
    final t = current;
    return t == null ? 0 : (_position / t.seconds).clamp(0.0, 1.0);
  }

  List<Playlist> get playlists => List.unmodifiable(_playlists);
  List<Playlist> get customPlaylists =>
      _playlists.where((p) => p.custom).toList();
  List<Track> get recentTracks =>
      _recent.map((id) => trackIndex[id]).whereType<Track>().toList();
  List<Track> get favoriteTracks =>
      catalog.where((t) => _favorites.contains(t.id)).toList();
  bool isFavorite(String id) => _favorites.contains(id);

  Playlist? playlistById(String id) {
    for (final p in _playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Track> tracksOf(Playlist p) =>
      p.trackIds.map((id) => trackIndex[id]).whereType<Track>().toList();

  List<Track> search(String query, {String? genre}) {
    final q = query.trim().toLowerCase();
    return catalog.where((t) {
      if (genre != null && t.genre != genre) return false;
      return q.isEmpty ||
          '${t.title} ${t.artist} ${t.album} ${t.genre}'
              .toLowerCase()
              .contains(q);
    }).toList();
  }

  // ---- navigation / library ----
  void setTab(int i) {
    if (_tab == i) return;
    _tab = i;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (!_favorites.remove(id)) _favorites.add(id);
    notifyListeners();
  }

  Playlist createPlaylist(
      {required String name,
      required String description,
      int paletteIndex = 0}) {
    final p = Playlist(
      id: 'u${++_seq}',
      name: name.trim(),
      description: description.trim(),
      trackIds: [],
      colors: artPalettes[paletteIndex % artPalettes.length],
      icon: Icons.queue_music,
      custom: true,
    );
    _playlists.add(p);
    notifyListeners();
    return p;
  }

  /// Returns false when the track is already in the playlist.
  bool addToPlaylist(String playlistId, String trackId) {
    final p = playlistById(playlistId);
    if (p == null || p.trackIds.contains(trackId)) return false;
    p.trackIds.add(trackId);
    notifyListeners();
    return true;
  }

  // ---- playback ----
  void playTrack(Track t, {List<Track>? queue}) {
    final list = queue ?? [t];
    final i = list.indexWhere((x) => x.id == t.id);
    _start(i < 0 ? [t] : list, i < 0 ? 0 : i);
  }

  void playAll(List<Track> list, {bool shuffle = false}) {
    if (list.isEmpty) return;
    final l = List<Track>.of(list);
    if (shuffle) l.shuffle(_rng);
    _start(l, 0);
  }

  void _start(List<Track> list, int idx) {
    _queue = List.of(list);
    _index = idx;
    _position = 0;
    _playing = true;
    _remember();
    _syncTicker();
    notifyListeners();
  }

  void togglePlay() {
    if (current == null) return;
    _playing = !_playing;
    _syncTicker();
    notifyListeners();
  }

  void next({bool auto = false}) {
    if (_queue.isEmpty) return;
    if (_index + 1 < _queue.length) {
      _index++;
      _position = 0;
      _remember();
    } else if (_repeat) {
      _index = 0;
      _position = 0;
      _remember();
    } else {
      _position = 0;
      if (auto) {
        _playing = false;
        _syncTicker();
      }
    }
    notifyListeners();
  }

  void previous() {
    if (_position > 3 || _index <= 0) {
      _position = 0;
    } else {
      _index--;
      _position = 0;
      _remember();
    }
    notifyListeners();
  }

  void jumpTo(int i) {
    if (i < 0 || i >= _queue.length) return;
    _index = i;
    _position = 0;
    _remember();
    notifyListeners();
  }

  void seek(double seconds) {
    final t = current;
    if (t == null) return;
    _position = seconds.round().clamp(0, t.seconds);
    notifyListeners();
  }

  void toggleRepeat() {
    _repeat = !_repeat;
    notifyListeners();
  }

  void shuffleUpcoming() {
    if (_index < 0) return;
    final rest = _queue.sublist(_index + 1)..shuffle(_rng);
    _queue = [..._queue.sublist(0, _index + 1), ...rest];
    notifyListeners();
  }

  void _remember() {
    final t = current;
    if (t == null) return;
    _recent
      ..remove(t.id)
      ..insert(0, t.id);
    if (_recent.length > 8) _recent.removeLast();
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = _playing ? Timer.periodic(tickInterval, (_) => _tick()) : null;
  }

  void _tick() {
    final t = current;
    if (t == null) return;
    _position++;
    if (_position >= t.seconds) {
      next(auto: true);
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _ticker?.cancel();
    super.dispose();
  }
}
