import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Inter';

  static TextStyle displayLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.0,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.6,
        color: color,
      );

  static TextStyle headlineMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle titleLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle titleMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle headlineLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle displayHero(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36.0,
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -0.8,
        color: color,
      );

  static TextStyle tagline(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle labelLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle caption(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: color,
      );
}
