import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/notification_service.dart';

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
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool restAlertEnabled;

  SettingsState({
    this.barWeight = 20.0,
    this.bodyWeight = 70.0,
    this.themeMode = ThemeMode.system,
    this.availablePlates = const [25, 20, 15, 10, 5, 2.5, 1.25],
    this.weeklyWorkoutGoal = 4,
    this.goal = 'Hipertrofia',
    this.experienceLevel = 'Iniciante',
    this.unitSystem = UnitSystem.metric,
    this.reminderEnabled = false,
    this.reminderHour = 18,
    this.reminderMinute = 0,
    this.restAlertEnabled = true,
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
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? restAlertEnabled,
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
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      restAlertEnabled: restAlertEnabled ?? this.restAlertEnabled,
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
    final unitSystem =
        UnitSystem.values.length > unitSystemIndex
            ? UnitSystem.values[unitSystemIndex]
            : UnitSystem.metric;

    final platesStrings = prefs.getStringList('available_plates');
    List<double> availablePlates;

    if (platesStrings != null) {
      availablePlates =
          platesStrings
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
      reminderEnabled: prefs.getBool('reminder_enabled') ?? false,
      reminderHour: prefs.getInt('reminder_hour') ?? 18,
      reminderMinute: prefs.getInt('reminder_minute') ?? 0,
      restAlertEnabled: prefs.getBool('rest_alert_enabled') ?? true,
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

  /// Liga/desliga o lembrete diário. Retorna `false` se a permissão for negada.
  Future<bool> setReminderEnabled(bool enabled) async {
    final service = ref.read(notificationServiceProvider);
    if (enabled) {
      if (!await service.requestPermission()) return false;
      await service.scheduleWorkoutReminder(
        hour: state.reminderHour,
        minute: state.reminderMinute,
      );
    } else {
      await service.cancelWorkoutReminder();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', enabled);
    state = state.copyWith(reminderEnabled: enabled);
    return true;
  }

  Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', hour);
    await prefs.setInt('reminder_minute', minute);
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    if (state.reminderEnabled) {
      await ref
          .read(notificationServiceProvider)
          .scheduleWorkoutReminder(hour: hour, minute: minute);
    }
  }

  /// Liga/desliga o aviso de fim de descanso. Retorna `false` se negada.
  Future<bool> setRestAlertEnabled(bool enabled) async {
    if (enabled &&
        !await ref.read(notificationServiceProvider).requestPermission()) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rest_alert_enabled', enabled);
    state = state.copyWith(restAlertEnabled: enabled);
    return true;
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
      currentPlates.map((p) => p.toString()).toList(),
    );

    state = state.copyWith(availablePlates: currentPlates);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
