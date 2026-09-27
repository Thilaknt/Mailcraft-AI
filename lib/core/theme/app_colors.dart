import 'package:flutter/material.dart';

class AppColors {
  // Primary Spec Color System
  static const Color background = Color(0xFF0B0D12);
  static const Color surface = Color(0xFF141720);
  static const Color surfaceElevated = Color(0xFF1B1F2A);
  static const Color primary = Color(0xFF3B82F6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF94A3B8);
  static const Color accent = Color(0xFF7C3AED);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Borders
  static const Color border = Color(0xFF1F2432);

  // Brand Gradients & Accents
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueLight = Color(0xFF60A5FA);
  static const Color accentViolet = Color(0xFF7C3AED);
  static const Color sparkCyan = Color(0xFF06B6D4);
  static const Color sparkCyanLight = Color(0xFF38BDF8);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient logoAuraGradient = RadialGradient(
    colors: [
      Color(0x553B82F6),
      Color(0x227C3AED),
      Colors.transparent,
    ],
    radius: 0.85,
  );

  // Semantic dark theme aliases
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkSurfaceElevated = surfaceElevated;
  static const Color darkBorder = border;
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;
}
