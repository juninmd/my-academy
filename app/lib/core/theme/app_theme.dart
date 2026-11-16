import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'component_themes.dart';
import 'pulse_tokens.dart';

/// Tema PULSE: cockpit escuro, tátil e cinético (com modo claro AA).
class AppTheme {
  // Aliases mantidos para quem já consome as cores da marca.
  static const Color primaryColor = PulseColors.volt;
  static const Color primaryVariant = PulseColors.voltDeep;
  static const Color secondaryColor = PulseColors.ember;
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color errorColorLight = Color(0xFFB3261E);
  static const Color primaryOnDark = PulseColors.volt;
  static const Color backgroundDark = PulseColors.void_;
  static const Color surfaceDark = PulseColors.carbon;
  static const Color surfaceVariantDark = PulseColors.graphite;
  static const Color backgroundLight = PulseColors.paper;
  static const Color surfaceLight = PulseColors.paperRaised;
  static const Color surfaceVariantLight = PulseColors.paperSunken;

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: PulseColors.volt,
    onPrimary: PulseColors.void_,
    primaryContainer: Color(0xFF2A3510),
    onPrimaryContainer: PulseColors.volt,
    secondary: PulseColors.ember,
    onSecondary: PulseColors.void_,
    secondaryContainer: Color(0xFF3A1A0E),
    onSecondaryContainer: PulseColors.ember,
    tertiary: PulseColors.chalk,
    onTertiary: PulseColors.void_,
    error: errorColor,
    onError: PulseColors.void_,
    surface: PulseColors.carbon,
    onSurface: PulseColors.chalk,
    onSurfaceVariant: PulseColors.mist,
    surfaceContainerLowest: PulseColors.void_,
    surfaceContainerLow: Color(0xFF101013),
    surfaceContainer: PulseColors.carbon,
    surfaceContainerHigh: Color(0xFF1C1C22),
    surfaceContainerHighest: PulseColors.graphite,
    outline: PulseColors.steel,
    outlineVariant: PulseColors.graphite,
    inverseSurface: PulseColors.chalk,
    onInverseSurface: PulseColors.void_,
    inversePrimary: PulseColors.voltDeep,
  );

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: PulseColors.voltDeep,
    onPrimary: Colors.white,
    primaryContainer: PulseColors.volt,
    onPrimaryContainer: PulseColors.ink,
    secondary: PulseColors.emberDeep,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFE1D3),
    onSecondaryContainer: Color(0xFF7C2D12),
    tertiary: PulseColors.ink,
    onTertiary: Colors.white,
    error: errorColorLight,
    onError: Colors.white,
    surface: PulseColors.paperRaised,
    onSurface: PulseColors.ink,
    onSurfaceVariant: PulseColors.inkMuted,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF9F9FA),
    surfaceContainer: Color(0xFFF1F1F3),
    surfaceContainerHigh: Color(0xFFECECEF),
    surfaceContainerHighest: PulseColors.paperSunken,
    outline: Color(0xFFC4C4CC),
    outlineVariant: Color(0xFFE0E0E4),
    inverseSurface: PulseColors.ink,
    onInverseSurface: PulseColors.chalk,
    inversePrimary: PulseColors.volt,
  );

  static ThemeData get darkPremiumTheme =>
      _build(darkScheme, PulseColors.void_);

  static ThemeData get lightPremiumTheme =>
      _build(lightScheme, PulseColors.paper);

  static ThemeData _build(ColorScheme scheme, Color background) {
    final base = scheme.brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: buildTextTheme(base, scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: scheme.onSurface,
        ),
      ),
    ).withAppComponents();
  }

  /// Inter para texto; Space Grotesk para números e títulos.
  static TextTheme buildTextTheme(TextTheme base, ColorScheme scheme) {
    final body = GoogleFonts.interTextTheme(base)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    TextStyle? display(TextStyle? s, double tracking, FontWeight w) => s == null
        ? null
        : GoogleFonts.spaceGrotesk(
            textStyle: s,
            fontWeight: w,
            letterSpacing: tracking,
          );

    return body.copyWith(
      displayLarge: display(body.displayLarge, -2.5, FontWeight.w700),
      displayMedium: display(body.displayMedium, -2, FontWeight.w700),
      displaySmall: display(body.displaySmall, -1.5, FontWeight.w700),
      headlineLarge: display(body.headlineLarge, -1, FontWeight.w700),
      headlineMedium: display(body.headlineMedium, -0.8, FontWeight.w700),
      headlineSmall: display(body.headlineSmall, -0.5, FontWeight.w700),
      titleLarge: display(body.titleLarge, -0.3, FontWeight.w700),
      titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: body.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: body.bodyMedium?.copyWith(
        height: 1.5,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: body.labelSmall?.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
