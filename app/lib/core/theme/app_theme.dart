import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette (Shared)
  static const Color primaryColor = Color(0xFF6200EA); // Deep Purple A700
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF00E5FF); // Cyan A400
  static const Color errorColor = Color(0xFFCF6679);

  // Dark Palette
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color onPrimaryDark = Colors.white;
  static const Color onSecondaryDark = Colors.black;
  static const Color onBackgroundDark = Colors.white;
  static const Color onSurfaceDark = Colors.white;

  // Light Palette
  static const Color backgroundLight = Color(0xFFF5F5F7); // iOS-like Light Grey
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFEEEEF0);
  static const Color onPrimaryLight = Colors.white;
  static const Color onSecondaryLight = Colors.black;
  static const Color onBackgroundLight = Colors.black87;
  static const Color onSurfaceLight = Colors.black87;

  static ThemeData get darkPremiumTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: onPrimaryDark,
        primaryContainer: primaryVariant,
        onPrimaryContainer: onPrimaryDark,
        secondary: secondaryColor,
        onSecondary: onSecondaryDark,
        secondaryContainer: secondaryColor,
        onSecondaryContainer: onSecondaryDark,
        error: errorColor,
        onError: Colors.black,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        surfaceContainerHighest: surfaceVariantDark,
      ),
      scaffoldBackgroundColor: backgroundDark,

      textTheme: _buildTextTheme(baseTextTheme, onBackgroundDark),
      appBarTheme: _buildAppBarTheme(backgroundDark, onBackgroundDark),
      cardTheme: _buildCardTheme(
        surfaceDark,
        Colors.white.withValues(alpha: 0.08),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(onPrimaryDark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(secondaryColor),
      textButtonTheme: _buildTextButtonTheme(secondaryColor),
      inputDecorationTheme: _buildInputDecorationTheme(
        surfaceVariantDark,
        onBackgroundDark,
        Colors.white.withValues(alpha: 0.1),
      ),
      bottomNavigationBarTheme: _buildBottomNavTheme(
        surfaceDark,
        onBackgroundDark,
      ),
    );
  }

  static ThemeData get lightPremiumTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimaryLight,
        primaryContainer: primaryVariant,
        onPrimaryContainer: onPrimaryLight,
        secondary: secondaryColor,
        onSecondary: onSecondaryLight,
        secondaryContainer: secondaryColor,
        onSecondaryContainer: onSecondaryLight,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        surfaceContainerHighest: surfaceVariantLight,
      ),
      scaffoldBackgroundColor: backgroundLight,

      textTheme: _buildTextTheme(baseTextTheme, onBackgroundLight),
      appBarTheme: _buildAppBarTheme(backgroundLight, onBackgroundLight),
      cardTheme: _buildCardTheme(
        surfaceLight,
        Colors.black.withValues(alpha: 0.05),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(onPrimaryLight),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        primaryColor,
      ), // Use Primary for outlined in light mode for better contrast? Or keep secondary
      textButtonTheme: _buildTextButtonTheme(primaryColor),
      inputDecorationTheme: _buildInputDecorationTheme(
        surfaceVariantLight,
        onBackgroundLight,
        Colors.black.withValues(alpha: 0.1),
      ),
      bottomNavigationBarTheme: _buildBottomNavTheme(
        surfaceLight,
        onBackgroundLight,
      ),
    );
  }

  // Helper methods to reduce duplication

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: color.withValues(alpha: 0.87),
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: color.withValues(alpha: 0.60),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(Color bgColor, Color fgColor) {
    return AppBarTheme(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: fgColor,
      ),
      iconTheme: IconThemeData(color: fgColor),
    );
  }

  static CardThemeData _buildCardTheme(Color color, Color borderColor) {
    return CardThemeData(
      color: color,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Color fgColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: fgColor,
        elevation: 4,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Color color) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(Color color) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    Color fillColor,
    Color textColor,
    Color borderColor,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      labelStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
      hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
      prefixIconColor: textColor.withValues(alpha: 0.6),
      suffixIconColor: textColor.withValues(alpha: 0.6),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme(
    Color bgColor,
    Color unselectedColor,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: bgColor.withValues(alpha: 0.9),
      selectedItemColor: secondaryColor,
      unselectedItemColor: unselectedColor.withValues(alpha: 0.4),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
}
