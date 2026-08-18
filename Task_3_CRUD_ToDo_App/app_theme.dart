import 'package:flutter/material.dart';

/// Central place for the app's visual identity.
/// One accent color, used consistently across light & dark mode,
/// keeps the app feeling designed rather than default.
class AppColors {
  static const Color primary = Color(0xFF6C5CE7); // indigo/violet
  static const Color primaryDark = Color(0xFF4834D4);
  static const Color accent = Color(0xFF00CEC9); // teal accent
  static const Color highPriority = Color(0xFFFF6B6B);
  static const Color mediumPriority = Color(0xFFFFA94D);
  static const Color lowPriority = Color(0xFF20C997);
}

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF6F5FB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF14121F),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Roboto',
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1F1B2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
  );

  static Color priorityColor(dynamic priority) {
    final name = priority.toString().split('.').last;
    switch (name) {
      case 'high':
        return AppColors.highPriority;
      case 'low':
        return AppColors.lowPriority;
      default:
        return AppColors.mediumPriority;
    }
  }
}
