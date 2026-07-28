import 'package:flutter/material.dart';

/// Centralized color tokens for the app. Feature code should reference these
/// tokens (or the `Theme.of(context).colorScheme`) rather than hardcoding
/// [Color] literals, so the palette can be updated in one place.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF3D5AFE);
  static const Color primaryDark = Color(0xFF0031CA);
  static const Color primaryLight = Color(0xFF8187FF);
  static const Color secondary = Color(0xFF00BFA5);

  // Neutrals
  static const Color black = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF5F5F7);
  static const Color grey300 = Color(0xFFE0E0E5);
  static const Color grey500 = Color(0xFF9E9EA7);
  static const Color grey700 = Color(0xFF5A5A66);
  static const Color grey900 = Color(0xFF1C1C22);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Surfaces
  static const Color lightBackground = white;
  static const Color lightSurface = grey100;
  static const Color darkBackground = black;
  static const Color darkSurface = grey900;

  static const ColorScheme lightScheme = ColorScheme.light(
    primary: primary,
    secondary: secondary,
    error: error,
    surface: lightSurface,
  );

  static const ColorScheme darkScheme = ColorScheme.dark(
    primary: primaryLight,
    secondary: secondary,
    error: error,
    surface: darkSurface,
  );
}
