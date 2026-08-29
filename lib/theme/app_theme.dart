import 'package:flutter/material.dart';

/// Cyber-Occult / Neo-Mystic テーマ。
class AppColors {
  static const background = Color(0xFF0A0E17);
  static const surface = Color(0xFF141A2A);
  static const surfaceHigh = Color(0xFF1E2740);
  static const neonPurple = Color(0xFFB026FF);
  static const cyberGold = Color(0xFFF5C542);
  static const textPrimary = Color(0xFFEDEBF5);
  static const textSecondary = Color(0xFF8E8AA8);
  static const success = Color(0xFF4EE6A8);
}

/// エレメントごとのグラデーション（アイコン+グラデーションでビジュアルを代用）。
class ElementColors {
  static const fire = [Color(0xFFFF5E3A), Color(0xFFFF2E63)];
  static const earth = [Color(0xFF3E7C4A), Color(0xFFB08D57)];
  static const air = [Color(0xFF6EE7E7), Color(0xFFB026FF)];
  static const water = [Color(0xFF2E9CFF), Color(0xFF1B4FCC)];
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.neonPurple,
      secondary: AppColors.cyberGold,
      surface: AppColors.surface,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.textSecondary),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
