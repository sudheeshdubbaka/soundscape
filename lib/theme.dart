import 'package:flutter/material.dart';

/// App-wide Material 3 theme; dark is the primary design target.
ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8E6CFF), brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        brightness == Brightness.dark ? const Color(0xFF0F0D17) : null,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    cardTheme: const CardThemeData(margin: EdgeInsets.zero),
  );
}
