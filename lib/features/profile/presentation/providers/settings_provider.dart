import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final double barWeight;
  final ThemeMode themeMode;

  SettingsState({this.barWeight = 20.0, this.themeMode = ThemeMode.system});

  SettingsState copyWith({double? barWeight, ThemeMode? themeMode}) {
    return SettingsState(
      barWeight: barWeight ?? this.barWeight,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final barWeight = prefs.getDouble('bar_weight') ?? 20.0;
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    final themeMode = ThemeMode.values[themeIndex];

    state = state.copyWith(barWeight: barWeight, themeMode: themeMode);
  }

  Future<void> setBarWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bar_weight', weight);
    state = state.copyWith(barWeight: weight);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    state = state.copyWith(themeMode: mode);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
