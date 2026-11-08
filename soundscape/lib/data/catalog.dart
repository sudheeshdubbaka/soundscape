import 'package:flutter/material.dart';

import '../models/models.dart';

const artPalettes = <List<Color>>[
  [Color(0xFF7C4DFF), Color(0xFF00B8D4)],
  [Color(0xFFFF5E7E), Color(0xFFFF9A44)],
  [Color(0xFF00A152), Color(0xFF00838F)],
  [Color(0xFF3D5AFE), Color(0xFFD500F9)],
  [Color(0xFFE65100), Color(0xFFC51162)],
  [Color(0xFF00897B), Color(0xFF304FFE)],
  [Color(0xFF6A1B9A), Color(0xFFEF5350)],
  [Color(0xFF0277BD), Color(0xFF26A69A)],
];

const genres = <Genre>[
  Genre('Synthwave', Icons.nightlight_round, [
    Color(0xFF6A1B9A),
    Color(0xFFD500F9),
  ]),
  Genre('Lo-fi', Icons.coffee, [Color(0xFF00695C), Color(0xFF26A69A)]),
  Genre('Indie', Icons.wb_sunny, [Color(0xFFE65100), Color(0xFFFFA000)]),
  Genre('Jazz', Icons.piano, [Color(0xFF1A237E), Color(0xFF3949AB)]),
  Genre('Electronic', Icons.bolt, [Color(0xFF0277BD), Color(0xFF00B8D4)]),
  Genre('Classical', Icons.auto_awesome, [
    Color(0xFF880E4F),
    Color(0xFFE91E63),
  ]),
];

Track _t(
  int n,
  String title,
  String artist,
  String album,
  String genre,
  int secs,
) =>
    Track(
      id: 't$n',
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      seconds: secs,
      colors: artPalettes[n % artPalettes.length],
      icon: genres.firstWhere((g) => g.name == genre).icon,
    );

/// Fictional artists and titles; no real audio or copyrighted material.
final List<Track> catalog = [
  _t(1, 'Neon Drive', 'Parallax Youth', 'After Hours Grid', 'Synthwave', 214),
  _t(
    2,
    'Midnight Arcade',
    'Parallax Youth',
    'After Hours Grid',
    'Synthwave',
    187,
  ),
  _t(3, 'Chrome Horizon', 'Vector Lane', 'Skyline Protocol', 'Synthwave', 232),
  _t(4, 'Rainy Window', 'Quiet Harbor', 'Tea & Static', 'Lo-fi', 142),
  _t(5, 'Paper Lanterns', 'Quiet Harbor', 'Tea & Static', 'Lo-fi', 168),
  _t(6, 'Study Break', 'Sleepy Circuits', 'Desk Lamp Hours', 'Lo-fi', 155),
  _t(7, 'Golden Hour Drive', 'The Marigolds', 'Porchlight', 'Indie', 201),
  _t(8, 'Porchlight', 'The Marigolds', 'Porchlight', 'Indie', 226),
  _t(9, 'Static Bloom', 'Wren & Willow', 'Small Weather', 'Indie', 193),
  _t(10, 'Blue Corner', 'Ola Mercer Quartet', 'Basement Sessions', 'Jazz', 258),
  _t(
    11,
    'Smoke & Satin',
    'Ola Mercer Quartet',
    'Basement Sessions',
    'Jazz',
    276,
  ),
  _t(12, 'Late Train to Rio', 'Cass Delamar', 'Night Mail', 'Jazz', 241),
  _t(13, 'Pulse Garden', 'Hexa Bloom', 'Lattice', 'Electronic', 219),
  _t(14, 'Signal Fade', 'Hexa Bloom', 'Lattice', 'Electronic', 205),
  _t(
    15,
    'Moon Study No. 3',
    'Elena Varga',
    'Nocturnes for Rain',
    'Classical',
    312,
  ),
  _t(16, 'Winter Etude', 'Elena Varga', 'Nocturnes for Rain', 'Classical', 289),
];

final Map<String, Track> trackIndex = {for (final t in catalog) t.id: t};

/// Fresh copies so user edits never mutate shared seed data.
List<Playlist> seedPlaylists() => [
      Playlist(
        id: 'p1',
        name: 'Night Drive',
        description: 'Neon-lit synths for the long way home.',
        trackIds: ['t1', 't2', 't3', 't13', 't14', 't9'],
        colors: artPalettes[3],
        icon: Icons.nightlight_round,
      ),
      Playlist(
        id: 'p2',
        name: 'Focus Flow',
        description: 'Soft beats and piano to keep you in the zone.',
        trackIds: ['t4', 't5', 't6', 't15', 't16'],
        colors: artPalettes[5],
        icon: Icons.self_improvement,
      ),
      Playlist(
        id: 'p3',
        name: 'Golden Hour',
        description: 'Warm guitars and easy choruses for late afternoons.',
        trackIds: ['t7', 't8', 't9', 't5'],
        colors: artPalettes[1],
        icon: Icons.wb_twilight,
      ),
      Playlist(
        id: 'p4',
        name: 'Late Night Jazz',
        description: 'Smoky quartets and slow trains.',
        trackIds: ['t10', 't11', 't12', 't16'],
        colors: artPalettes[6],
        icon: Icons.piano,
      ),
      Playlist(
        id: 'p5',
        name: 'Weekend Mix',
        description: 'A little of everything, nothing in a hurry.',
        trackIds: ['t3', 't7', 't12', 't14', 't5', 't1'],
        colors: artPalettes[0],
        icon: Icons.celebration,
      ),
    ];
