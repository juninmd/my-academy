import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/profile/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsState', () {
    test('copyWith should work correctly', () {
      final state = SettingsState();
      final newState = state.copyWith(
        barWeight: 25.0,
        bodyWeight: 80.0,
        themeMode: ThemeMode.dark,
      );

      expect(newState.barWeight, 25.0);
      expect(newState.bodyWeight, 80.0);
      expect(newState.themeMode, ThemeMode.dark);
    });
  });

  group('SettingsNotifier', () {
    test('should load default settings', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      // Ensure notifier initializes
      container.read(settingsProvider.notifier);

      // Wait for _loadSettings
      await Future.delayed(Duration.zero);

      final state = container.read(settingsProvider);
      expect(state.barWeight, 20.0);
      expect(state.bodyWeight, 70.0);
      expect(state.themeMode, ThemeMode.system);
    });

    test('should update bar weight', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(settingsProvider.notifier);

      await notifier.setBarWeight(30.0);

      final state = container.read(settingsProvider);
      expect(state.barWeight, 30.0);
    });

     test('should update body weight', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(settingsProvider.notifier);

      await notifier.setBodyWeight(90.0);

      final state = container.read(settingsProvider);
      expect(state.bodyWeight, 90.0);
    });

    test('should update theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(settingsProvider.notifier);

      await notifier.setThemeMode(ThemeMode.dark);

      final state = container.read(settingsProvider);
      expect(state.themeMode, ThemeMode.dark);
    });
  });
}
