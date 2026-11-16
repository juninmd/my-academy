import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/theme/app_theme.dart';
import 'package:my_academy/core/theme/pulse_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // We don't disable runtime fetching here because we want to catch the specific exception
  // or allow it if network is available.

  group('AppTheme', () {
    test('colors should be correct', () {
      expect(AppTheme.primaryColor, const Color(0xFFC8FF2E));
      expect(AppTheme.primaryVariant, const Color(0xFF4D7C0F));
      expect(AppTheme.secondaryColor, const Color(0xFFFF5A1F));
      expect(AppTheme.backgroundDark, const Color(0xFF0A0A0C));
    });

    test('dark scheme puts Volt on Void with dark ink on top', () {
      expect(AppTheme.darkScheme.primary, PulseColors.volt);
      expect(AppTheme.darkScheme.onPrimary, PulseColors.void_);
      expect(AppTheme.lightScheme.primary, PulseColors.voltDeep);
      expect(AppTheme.lightScheme.onPrimary, Colors.white);
    });
  });
}
