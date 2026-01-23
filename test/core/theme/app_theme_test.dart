import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppTheme', () {
    test('premiumTheme should return a valid ThemeData', () {
      final theme = AppTheme.premiumTheme;

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppTheme.backgroundDark);
      expect(theme.colorScheme.primary, AppTheme.primaryColor);
      expect(theme.colorScheme.secondary, AppTheme.secondaryColor);
    });

    test('colors should be correct', () {
      expect(AppTheme.primaryColor, const Color(0xFF6200EA));
      expect(AppTheme.primaryVariant, const Color(0xFF3700B3));
      expect(AppTheme.secondaryColor, const Color(0xFF00E5FF));
      expect(AppTheme.backgroundDark, const Color(0xFF121212));
    });
  });
}
