// lib/core/theme/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SawaLoveTheme {
  static const Color primary = Color(0xFFB30065);
  static const Color primaryContainer = Color(0xFFFF6EA9);
  static const Color secondary = Color(0xFF8329C8);
  static const Color tertiary = Color(0xFF00647C);
  static const Color surface = Color(0xFFFFF4F6);
  static const Color surfaceContainerLow = Color(0xFFFFECF1);
  static const Color surfaceContainer = Color(0xFFFFE0EA);
  static const Color surfaceContainerHigh = Color(0xFFFFD8E5);
  static const Color surfaceContainerHighest = Color(0xFFFFD1E1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF7E4D61);
  static const Color onSurface = Color(0xFF4A2134);
  static const Color onPrimary = Color(0xFFFFEFF2);
  static const Color outlineVariant = Color(0xFFD89CB4);
  static const Color outline = Color(0xFF9C677D);
  static const Color errorColor = Color(0xFFB31B25);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static TextStyle? get headlineMedium => lightTheme.textTheme.headlineMedium;
  static TextStyle? get headlineSmall => lightTheme.textTheme.headlineSmall;
  static TextStyle? get bodyMedium => lightTheme.textTheme.bodyMedium;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: surface,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurface: onSurface,
      onPrimary: onPrimary,
      error: errorColor,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 56,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.beVietnamPro(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.beVietnamPro(
        fontSize: 16,
        height: 1.5,
      ),
      labelMedium: GoogleFonts.beVietnamPro(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ).apply(),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: StadiumBorder(),
      elevation: 0,
      highlightElevation: 0,
    ),
  );
}

