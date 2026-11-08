import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:soundscape/data/catalog.dart';
import 'package:soundscape/main.dart';
import 'package:soundscape/state/app_state.dart';

Widget _app() => ChangeNotifierProvider(
      create: (_) => AppState(simulateLoading: false),
      child: const SoundscapeApp(),
    );

void main() {
  testWidgets('playback, queue, favorites, search and playlists', (
    tester,
  ) async {
    final s = AppState(simulateLoading: false);
    s.playAll(catalog);
    expect(s.current!.id, 't1');
    expect(s.playing, isTrue);
    await tester.pump(const Duration(seconds: 3));
    expect(s.position, 3);
    s.togglePlay();
    await tester.pump(const Duration(seconds: 3));
    expect(s.position, 3, reason: 'paused player must not advance');
    s.next();
    expect(s.current!.id, 't2');
    s.previous();
    expect(s.current!.id, 't1');
    s.seek(99999);
    expect(s.position, s.current!.seconds);

    expect(s.isFavorite('t1'), isFalse);
    s.toggleFavorite('t1');
    expect(s.isFavorite('t1'), isTrue);

    expect(s.search('neon').single.id, 't1');
    expect(s.search('', genre: 'Jazz'), hasLength(3));
    expect(s.search('zzzz'), isEmpty);

    final p = s.createPlaylist(name: '  Mine ', description: 'desc here');
    expect(p.name, 'Mine');
    expect(s.addToPlaylist(p.id, 't4'), isTrue);
    expect(s.addToPlaylist(p.id, 't4'), isFalse);
    s.dispose();
  });

  testWidgets('desktop layout uses rail; search shows empty state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Recently played'), findsOneWidget);
    await tester.tap(find.text('Browse'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('mobile layout uses bottom bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('create playlist validates then opens the new playlist', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('New playlist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create playlist'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a playlist name.'), findsOneWidget);
    expect(find.text('Add a short description.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '  Road Trip ');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Songs for long drives',
    );
    await tester.tap(find.text('Create playlist'));
    await tester.pumpAndSettle();
    expect(find.text('This playlist is empty'), findsOneWidget);
    expect(find.text('Road Trip'), findsWidgets);
  });
}
