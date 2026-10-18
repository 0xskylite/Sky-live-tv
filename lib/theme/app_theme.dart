import 'package:flutter/material.dart';

/// Sky Live TV design system — premium dark streaming interface.
class AppColors {
  static const bg = Color(0xFF080D18);
  static const surface = Color(0xFF111A2B);
  static const surface2 = Color(0xFF1A263B);
  static const navSurface = Color(0xFF0C1422);
  static const searchSurface = Color(0xFF101B2C);
  static const sky = Color(0xFF38BDF8);
  static const indigo = Color(0xFF818CF8);
  static const live = Color(0xFFFF4D67);
  static const textPrimary = Color(0xFFF4F7FC);
  static const textSecondary = Color(0xFF91A0B7);

  static const headerGradient = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sky,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.navSurface,
      indicatorColor: AppColors.sky.withValues(alpha: 41),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
        color: states.contains(WidgetState.selected)
            ? AppColors.sky
            : AppColors.textSecondary,
        fontSize: 11,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w500,
      )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? AppColors.sky
            : AppColors.textSecondary,
        size: 23,
      )),
      elevation: 16,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.searchSurface,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIconColor: AppColors.textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sky,
        foregroundColor: const Color(0xFF06111D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    ),
  );
}
