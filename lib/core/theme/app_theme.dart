import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/design_constants.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(const TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
      bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
    ));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.primary,
        outline: AppColors.border,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme.apply(bodyColor: AppColors.primary, displayColor: AppColors.primary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.card),
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme(const TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
      bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
    ));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme.apply(bodyColor: AppColors.lightTextPrimary, displayColor: AppColors.lightTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.card),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          side: const BorderSide(color: AppColors.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        ),
      ),
    );
  }
}
