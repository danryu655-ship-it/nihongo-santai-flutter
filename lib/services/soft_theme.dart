import 'package:flutter/material.dart';

/// Palet soft dark/light — sama seperti Flashcard.
class SoftTheme {
  static const Color lightBg = Color(0xFFF7F5F0);
  static const Color lightSurface = Color(0xFFECE8DF);
  static const Color lightText = Color(0xFF262422);
  static const Color lightMuted = Color(0xFF6B655E);

  static const Color darkBg = Color(0xFF1C1B1A);
  static const Color darkSurface = Color(0xFF282624);
  static const Color darkText = Color(0xFFEAE5DC);
  static const Color darkMuted = Color(0xFFB3ACA0);

  static const Color accent = Color(0xFFD97757); // Terracotta

  static Color bg(bool dark) => dark ? darkBg : lightBg;
  static Color surface(bool dark) => dark ? darkSurface : lightSurface;
  static Color text(bool dark) => dark ? darkText : lightText;
  static Color muted(bool dark) => dark ? darkMuted : lightMuted;
}
