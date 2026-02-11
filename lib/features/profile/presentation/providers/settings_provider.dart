import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnitSystem { metric, imperial }

class SettingsState {
  final double barWeight;
  final double bodyWeight;
  final ThemeMode themeMode;
  final List<double> availablePlates;
  final int weeklyWorkoutGoal;
  final String goal;
  final String experienceLevel;
  final UnitSystem unitSystem;

  SettingsState({
    this.barWeight = 20.0,
    this.bodyWeight = 70.0,
    this.themeMode = ThemeMode.system,
    this.availablePlates = const [25, 20, 15, 10, 5, 2.5, 1.25],
    this.weeklyWorkoutGoal = 4,
    this.goal = 'Hipertrofia',
    this.experienceLevel = 'Iniciante',
    this.unitSystem = UnitSystem.metric,
  });

  SettingsState copyWith({
    double? barWeight,
    double? bodyWeight,
    ThemeMode? themeMode,
    List<double>? availablePlates,
    int? weeklyWorkoutGoal,
    String? goal,
    String? experienceLevel,
    UnitSystem? unitSystem,
  }) {
    return SettingsState(
      barWeight: barWeight ?? this.barWeight,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      themeMode: themeMode ?? this.themeMode,
      availablePlates: availablePlates ?? this.availablePlates,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      unitSystem: unitSystem ?? this.unitSystem,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // Initial state
    _loadSettings();
    return SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final barWeight = prefs.getDouble('bar_weight') ?? 20.0;
    final bodyWeight = prefs.getDouble('body_weight') ?? 70.0;
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    final themeMode = ThemeMode.values[themeIndex];
    final weeklyWorkoutGoal = prefs.getInt('weekly_workout_goal') ?? 4;
    final goal = prefs.getString('workout_goal') ?? 'Hipertrofia';
    final experienceLevel = prefs.getString('experience_level') ?? 'Iniciante';
    final unitSystemIndex = prefs.getInt('unit_system') ?? 0;
    final unitSystem = UnitSystem.values.length > unitSystemIndex
        ? UnitSystem.values[unitSystemIndex]
        : UnitSystem.metric;


    final platesStrings = prefs.getStringList('available_plates');
    List<double> availablePlates;

    if (platesStrings != null) {
      availablePlates = platesStrings
          .map((s) => double.tryParse(s))
          .whereType<double>()
          .toList();
    } else {
      availablePlates = [25, 20, 15, 10, 5, 2.5, 1.25];
    }

    // Ensure sorted descending
    availablePlates.sort((a, b) => b.compareTo(a));

    state = state.copyWith(
      barWeight: barWeight,
      bodyWeight: bodyWeight,
      themeMode: themeMode,
      availablePlates: availablePlates,
      weeklyWorkoutGoal: weeklyWorkoutGoal,
      goal: goal,
      experienceLevel: experienceLevel,
      unitSystem: unitSystem,
    );
  }

  Future<void> setBarWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bar_weight', weight);
    state = state.copyWith(barWeight: weight);
  }

  Future<void> setBodyWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('body_weight', weight);
    state = state.copyWith(bodyWeight: weight);
  }

  Future<void> setWeeklyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weekly_workout_goal', goal);
    state = state.copyWith(weeklyWorkoutGoal: goal);
  }

  Future<void> setGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_goal', goal);
    state = state.copyWith(goal: goal);
  }

  Future<void> setExperienceLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('experience_level', level);
    state = state.copyWith(experienceLevel: level);
  }

  Future<void> setUnitSystem(UnitSystem unitSystem) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unit_system', unitSystem.index);
    state = state.copyWith(unitSystem: unitSystem);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> togglePlateAvailability(double plate) async {
    final currentPlates = List<double>.from(state.availablePlates);
    if (currentPlates.contains(plate)) {
      currentPlates.remove(plate);
    } else {
      currentPlates.add(plate);
    }

    // Sort descending
    currentPlates.sort((a, b) => b.compareTo(a));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'available_plates',
      currentPlates.map((p) => p.toString()).toList()
    );

    state = state.copyWith(availablePlates: currentPlates);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
