import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color primaryColor = Color(0xFF6200EA); // Deep Purple A700
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF00E5FF); // Cyan A400
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);

  static const Color errorColor = Color(0xFFCF6679);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;

  static ThemeData get premiumTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: onPrimary,
        primaryContainer: primaryVariant,
        onPrimaryContainer: onPrimary,
        secondary: secondaryColor,
        onSecondary: onSecondary,
        secondaryContainer: secondaryColor,
        onSecondaryContainer: onSecondary,
        error: errorColor,
        onError: Colors.black,
        surface: surfaceDark,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
      ),
      scaffoldBackgroundColor: backgroundDark,

      // Typography
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: onBackground,
          letterSpacing: -1.5,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: onBackground,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: onBackground.withValues(
            alpha: 0.87,
          ), // Updated from withOpacity
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: onBackground.withValues(
            alpha: 0.60,
          ), // Updated from withOpacity
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        iconTheme: const IconThemeData(color: onBackground),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shadowColor: Colors.black.withValues(
          alpha: 0.2,
        ), // Updated from withOpacity
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ), // Updated from withOpacity
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 4,
          shadowColor: primaryColor.withValues(
            alpha: 0.5,
          ), // Updated from withOpacity
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: const BorderSide(color: secondaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ), // Updated from withOpacity
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        labelStyle: TextStyle(
          color: onBackground.withValues(alpha: 0.6),
        ), // Updated from withOpacity
        hintStyle: TextStyle(
          color: onBackground.withValues(alpha: 0.4),
        ), // Updated from withOpacity
        prefixIconColor: onBackground.withValues(
          alpha: 0.6,
        ), // Updated from withOpacity
        suffixIconColor: onBackground.withValues(
          alpha: 0.6,
        ), // Updated from withOpacity
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark.withValues(
          alpha: 0.9,
        ), // Updated from withOpacity
        selectedItemColor: secondaryColor,
        unselectedItemColor: onBackground.withValues(
          alpha: 0.4,
        ), // Updated from withOpacity
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
