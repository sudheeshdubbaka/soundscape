import 'package:flutter/material.dart';

/// Formats seconds as m:ss.
String formatTime(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

/// A catalog track. Artwork is generated from [colors] and [icon].
class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.seconds,
    required this.colors,
    required this.icon,
  });

  final String id, title, artist, album, genre;
  final int seconds;
  final List<Color> colors;
  final IconData icon;

  String get duration => formatTime(seconds);
}

/// A playlist. [trackIds] is mutable so user playlists can grow.
class Playlist {
  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.trackIds,
    required this.colors,
    required this.icon,
    this.custom = false,
  });

  final String id, name, description;
  final List<String> trackIds;
  final List<Color> colors;
  final IconData icon;
  final bool custom;
}

/// A browsable genre category.
class Genre {
  const Genre(this.name, this.icon, this.colors);
  final String name;
  final IconData icon;
  final List<Color> colors;
}
