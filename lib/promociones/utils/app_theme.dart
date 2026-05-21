import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores
  static const Color primary = Color(0xFF1A1A2E);
  static const Color accent = Color(0xFFE94560);
  static const Color accentGold = Color(0xFFF5A623);
  static const Color surface = Color(0xFF16213E);
  static const Color cardBg = Color(0xFF0F3460);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color success = Color(0xFF4CAF50);
  static const Color inactive = Color(0xFF757575);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentGold,
        surface: surface,
        onPrimary: textLight,
        onSurface: textLight,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textLight, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: textLight, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: textLight, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textLight, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textLight),
          bodyLarge: TextStyle(color: textLight),
          bodyMedium: TextStyle(color: textMuted),
          labelLarge: TextStyle(color: textLight, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBg, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textLight,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBg, width: 1),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: textLight),
      ),
    );
  }
}