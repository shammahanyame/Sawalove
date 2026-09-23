// lib/core/theme/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SawaLoveTheme {
  // Semantic status
  static const Color success = Color(0xFF1B7F4B);
  static const Color successContainer = Color(0xFFDCF5E5);
  static const Color warning = Color(0xFF9A5B00);
  static const Color warningContainer = Color(0xFFFFE9C2);

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

  // Dark surfaces ("berry" dark mode)
  static const Color darkSurface = Color(0xFF1A0B1D);
  static const Color darkSurfaceContainerLow = Color(0xFF241327);
  static const Color darkSurfaceContainer = Color(0xFF2C1930);
  static const Color darkSurfaceContainerHigh = Color(0xFF38223B);
  static const Color darkSurfaceContainerHighest = Color(0xFF442D47);
  static const Color darkSurfaceContainerLowest = Color(0xFF140717);
  static const Color darkOnSurface = Color(0xFFF4DEE8);
  static const Color darkOnSurfaceVariant = Color(0xFFE0B9C7);
  static const Color darkPrimary = Color(0xFFFF6EA9);
  static const Color darkOnPrimary = Color(0xFF3E001D);
  static const Color darkSecondary = Color(0xFFD8B4FE);
  static const Color darkOnSecondary = Color(0xFF3A1160);
  static const Color errorColor = Color(0xFFB31B25);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      primaryContainer: Color(0xFF9E0055),
      onPrimaryContainer: Color(0xFFFFD9E6),
      secondary: darkSecondary,
      onSecondary: darkOnSecondary,
      secondaryContainer: Color(0xFF5D2A99),
      onSecondaryContainer: Color(0xFFEBDCFF),
      tertiary: Color(0xFF6FD5EC),
      onTertiary: Color(0xFF003545),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerLowest: darkSurfaceContainerLowest,
      surfaceContainerLow: darkSurfaceContainerLow,
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: Color(0xFFA97085),
      outlineVariant: Color(0xFF5C3A48),
    ),
    textTheme: _buildTextTheme(darkOnSurface, darkOnSurface),
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

  static TextStyle? get headlineMedium => lightTheme.textTheme.headlineMedium;
  static TextStyle? get headlineSmall => lightTheme.textTheme.headlineSmall;
  static TextStyle? get bodyMedium => lightTheme.textTheme.bodyMedium;

  static TextTheme _buildTextTheme(Color bodyColor, Color displayColor) =>
      TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 56, fontWeight: FontWeight.w800, color: displayColor),
        displayMedium: GoogleFonts.plusJakartaSans(
            fontSize: 44, fontWeight: FontWeight.w800, color: displayColor),
        displaySmall: GoogleFonts.plusJakartaSans(
            fontSize: 36, fontWeight: FontWeight.w800, color: displayColor),
        headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32, fontWeight: FontWeight.w800, color: displayColor),
        headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 28, fontWeight: FontWeight.w700, color: displayColor),
        headlineSmall: GoogleFonts.plusJakartaSans(
            fontSize: 24, fontWeight: FontWeight.w700, color: displayColor),
        titleLarge: GoogleFonts.beVietnamPro(
            fontSize: 22, fontWeight: FontWeight.w600, color: displayColor),
        titleMedium: GoogleFonts.beVietnamPro(
            fontSize: 18, fontWeight: FontWeight.w600, color: displayColor),
        titleSmall: GoogleFonts.beVietnamPro(
            fontSize: 16, fontWeight: FontWeight.w600, color: displayColor),
        bodyLarge: GoogleFonts.beVietnamPro(
            fontSize: 16, height: 1.5, color: bodyColor),
        bodyMedium: GoogleFonts.beVietnamPro(
            fontSize: 14, height: 1.5, color: bodyColor),
        bodySmall: GoogleFonts.beVietnamPro(
            fontSize: 12, height: 1.4, color: bodyColor),
        labelLarge: GoogleFonts.beVietnamPro(
            fontSize: 14, fontWeight: FontWeight.w600, color: bodyColor),
        labelMedium: GoogleFonts.beVietnamPro(
            fontSize: 12, fontWeight: FontWeight.w500, color: bodyColor),
        labelSmall: GoogleFonts.beVietnamPro(
            fontSize: 11, fontWeight: FontWeight.w500, color: bodyColor),
      );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: surface,
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
    textTheme: _buildTextTheme(onSurface, onSurface),
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

