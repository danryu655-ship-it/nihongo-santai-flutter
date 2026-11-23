import 'package:flutter/material.dart';

/// Tema soft dark/light — sama seperti Flashcard.
/// Sumber kebenaran tunggal: AppState.softDark (tersimpan di nsf_soft_dark).
class AppTheme {
  static const Color lightBg = Color(0xFFF7F5F0); // Warm off-white
  static const Color lightSurface = Color(0xFFECE8DF);
  static const Color lightText = Color(0xFF262422);
  static const Color lightMuted = Color(0xFF6B655E);

  static const Color darkBg = Color(0xFF1C1B1A); // Warm charcoal
  static const Color darkSurface = Color(0xFF282624);
  static const Color darkText = Color(0xFFEAE5DC);
  static const Color darkMuted = Color(0xFFB3ACA0);

  static const Color accent = Color(0xFFD97757); // Terracotta lembut

  static Color bg(bool dark) => dark ? darkBg : lightBg;
  static Color surface(bool dark) => dark ? darkSurface : lightSurface;
  static Color text(bool dark) => dark ? darkText : lightText;
  static Color muted(bool dark) => dark ? darkMuted : lightMuted;

  static ThemeData buildTheme(bool dark) {
    final bg = dark ? darkBg : lightBg;
    final surface = dark ? darkSurface : lightSurface;
    final text = dark ? darkText : lightText;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: accent,
        onPrimary: Colors.white,
        secondary: surface,
        onSecondary: text,
        error: const Color(0xFF8C3B3B),
        onError: Colors.white,
        surface: surface,
        onSurface: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
    );
  }
}
