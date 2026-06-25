import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Stitch Color Palette
  static const Color primary = Color(0xFF00478d);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color primaryContainer = Color(0xFF005eb8);
  static const Color onPrimaryContainer = Color(0xFFc8daff);
  
  static const Color secondary = Color(0xFF006d35);
  static const Color onSecondary = Color(0xFFffffff);
  static const Color secondaryContainer = Color(0xFF8df9a8);
  static const Color onSecondaryContainer = Color(0xFF007439);
  
  static const Color tertiary = Color(0xFF004983);
  static const Color onTertiary = Color(0xFFffffff);
  static const Color tertiaryContainer = Color(0xFF28619e);
  static const Color onTertiaryContainer = Color(0xFFc5dbff);
  
  static const Color error = Color(0xFFba1a1a);
  static const Color onError = Color(0xFFffffff);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onErrorContainer = Color(0xFF93000a);
  
  static const Color background = Color(0xFFf8f9fa);
  static const Color onBackground = Color(0xFF191c1d);
  static const Color surface = Color(0xFFf8f9fa);
  static const Color onSurface = Color(0xFF191c1d);
  
  static const Color surfaceVariant = Color(0xFFe1e3e4);
  static const Color onSurfaceVariant = Color(0xFF424752);
  static const Color outline = Color(0xFF727783);
  
  // Custom non-standard colors needed for the UI
  static const Color surfaceContainerLowest = Color(0xFFffffff);
  static const Color surfaceContainerLow = Color(0xFFf3f4f5);
  static const Color surfaceContainer = Color(0xFFedeeef);
  static const Color surfaceContainerHigh = Color(0xFFe7e8e9);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
        surfaceVariant: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.w800, color: onSurface),
        displayMedium: GoogleFonts.manrope(fontSize: 45, fontWeight: FontWeight.w800, color: onSurface),
        displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w700, color: onSurface),
        headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface),
        headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
        headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface),
        titleLarge: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w500, color: onSurface),
        titleMedium: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: onSurface),
        titleSmall: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
        bodyLarge: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w400, color: onSurfaceVariant),
        bodyMedium: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant),
        bodySmall: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant),
        labelLarge: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
        labelMedium: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: onSurface),
        labelSmall: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600, color: onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)), // Pill shape typical of modern tailwind
          textStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: primary),
        iconTheme: const IconThemeData(color: primaryContainer),
      ),
    );
  }
}
