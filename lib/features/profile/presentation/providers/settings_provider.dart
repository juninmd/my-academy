import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final double barWeight;

  SettingsState({this.barWeight = 20.0});

  SettingsState copyWith({double? barWeight}) {
    return SettingsState(
      barWeight: barWeight ?? this.barWeight,
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
    state = state.copyWith(barWeight: barWeight);
  }

  Future<void> setBarWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bar_weight', weight);
    state = state.copyWith(barWeight: weight);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
