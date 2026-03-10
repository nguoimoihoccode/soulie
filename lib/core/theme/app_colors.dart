import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Soft Pink / Hồng Nhạt
  static const Color primary = Color(0xFFFF85A2);
  static const Color primaryDark = Color(0xFFE86B8A);
  static const Color primaryLight = Color(0xFFFFABC2);

  // Backgrounds - Soft dark with pink warmth
  static const Color background = Color(0xFF0E0B12);
  static const Color surface = Color(0xFF151218);
  static const Color surfaceLight = Color(0xFF1D1822);
  static const Color surfaceElevated = Color(0xFF261F2E);

  // Card backgrounds
  static const Color cardDark = Color(0xFF1A1520);
  static const Color cardBorder = Color(0xFF302838);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCBBDD8);
  static const Color textTertiary = Color(0xFF8C7DA0);
  static const Color textMuted = Color(0xFF6A5B7A);

  // Accent colors
  static const Color accentPink = Color(0xFFFF85A2);
  static const Color accentPurple = Color(0xFFBB7EFF);
  static const Color accentCyan = Color(0xFF7DD8F0);
  static const Color accentOrange = Color(0xFFFFAA7B);
  static const Color accentMagenta = Color(0xFFFF7EB8);
  static const Color accentRose = Color(0xFFFFB0C8);

  // Status
  static const Color success = Color(0xFF7AE89A);
  static const Color warning = Color(0xFFFFCA70);
  static const Color error = Color(0xFFFF7088);
  static const Color info = Color(0xFF7DD8F0);

  // Online status
  static const Color online = Color(0xFFFF85A2);
  static const Color offline = Color(0xFF6A5B7A);
  static const Color away = Color(0xFFFFCA70);

  // Bottom nav
  static const Color navActive = Color(0xFFFF85A2);
  static const Color navInactive = Color(0xFF6A5B7A);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF85A2), Color(0xFFFFABC2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [Color(0xFFFF85A2), Color(0xFFBB7EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0E0B12), Color(0xFF151218)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF201828), Color(0xFF151218)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFFFF85A2), Color(0xFFBB7EFF), Color(0xFFFFABC2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
