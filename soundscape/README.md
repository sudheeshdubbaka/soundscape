# Soundscape

A responsive music playlist web app built with Flutter (Material 3) and Provider.
Playback is **simulated**: no audio is streamed or bundled; a timer advances the progress bar.

## Setup
Requires Flutter 3.27+ (stable) with web enabled.

```bash
flutter create . --platforms web --project-name soundscape   # adds web/ scaffolding; keeps lib/ and pubspec
flutter pub get
```

## Run
```bash
flutter run -d chrome
# or a release build served locally:
flutter build web && cd build/web && python3 -m http.server 8080
```

## Test and analyze
```bash
dart format .
flutter analyze
flutter test
```

## Screenshots
Serve the release build on http://localhost:8080, then either use Chrome DevTools
(F12, device toolbar, 1440x900 / 820x1180 / 390x844, "Capture screenshot"), or Playwright:

```bash
npx playwright screenshot --viewport-size "1440,900" --wait-for-timeout 4000 http://localhost:8080 desktop-home.png
npx playwright screenshot --viewport-size "390,844"  --wait-for-timeout 4000 http://localhost:8080 mobile-home.png
```
Also capture a playlist details screen (click "Night Drive") and the New playlist form.

## Structure
- `lib/models` - Track, Playlist, Genre
- `lib/data` - local mock catalog, seed playlists, art palettes
- `lib/state` - `AppState` (ChangeNotifier via Provider): playback, queue, favorites, playlists
- `lib/screens` - Home, Browse/Search, Library, Playlist details, Create playlist
- `lib/widgets` - Artwork, cards/track tile, now-playing bar + player, adaptive shell
- `test/app_test.dart` - state and widget tests

## Layout breakpoints
<600 px bottom NavigationBar; 600-1100 NavigationRail; >=1100 extended rail.
Grids use `maxCrossAxisExtent`, so column counts follow width. Motion collapses to zero when the OS requests reduced motion.
