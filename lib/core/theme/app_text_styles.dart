import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const double _globalTextScale = 1.18;

  static double _scaled(double size) => size * _globalTextScale;

  static TextStyle _sutonnyRegular({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'SutonnyMJ',
      fontFamilyFallback: const ['Hind Siliguri', 'Noto Sans Bengali'],
      fontSize: _scaled(fontSize),
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Bengali font (Hind Siliguri) styles
  static TextStyle hindSiliguri({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    if (fontWeight.value <= FontWeight.w500.value) {
      return _sutonnyRegular(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return GoogleFonts.hindSiliguri(
      fontSize: _scaled(fontSize),
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // English font (Poppins) styles
  static TextStyle poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: _scaled(fontSize),
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Predefined styles
  static TextStyle get splashBrandName => hindSiliguri(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
        letterSpacing: 2.0,
      );

  static TextStyle get splashTagline => poppins(
        fontSize: 10,
        color: AppColors.gold,
        letterSpacing: 3.0,
      );

  static TextStyle get heading1 => hindSiliguri(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading2 => hindSiliguri(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
      );

  static TextStyle get heading3 => hindSiliguri(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyText => hindSiliguri(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => hindSiliguri(
      fontSize: 11,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelGold => hindSiliguri(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
      );

  static TextStyle get labelMuted => hindSiliguri(
      fontSize: 10,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
      );

  static TextStyle get buttonText => hindSiliguri(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0A0A0A),
      );
}
