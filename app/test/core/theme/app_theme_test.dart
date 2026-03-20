import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // We don't disable runtime fetching here because we want to catch the specific exception
  // or allow it if network is available.

  group('AppTheme', () {
    test('colors should be correct', () {
      expect(AppTheme.primaryColor, const Color(0xFF6200EA));
      expect(AppTheme.primaryVariant, const Color(0xFF3700B3));
      expect(AppTheme.secondaryColor, const Color(0xFF00E5FF));
      expect(AppTheme.backgroundDark, const Color(0xFF121212));
    });
  });
}
