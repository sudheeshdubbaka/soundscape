import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/shell.dart';

void main() => runApp(
      ChangeNotifierProvider(
          create: (_) => AppState(), child: const SoundscapeApp()),
    );

class SoundscapeApp extends StatelessWidget {
  const SoundscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soundscape',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.dark,
      // Lets mouse/trackpad drag horizontal lists on desktop web.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad
        },
      ),
      home: const AppShell(),
    );
  }
}
