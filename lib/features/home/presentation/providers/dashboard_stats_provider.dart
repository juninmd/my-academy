import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/settings_provider.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';

class DashboardStats {
  final int workoutsThisWeek;
  final int weeklyGoal;
  final double volumeThisWeek;
  final int streak;

  DashboardStats({
    required this.workoutsThisWeek,
    required this.weeklyGoal,
    required this.volumeThisWeek,
    required this.streak,
  });
}

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final logs = await ref.watch(allExerciseLogsProvider.future);
  final settings = ref.watch(settingsProvider);

  // 1. Workouts This Week
  final now = DateTime.now();
  // Start of week (Monday)
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  final logsThisWeek = logs.where((l) => l.date.isAfter(startOfMonday)).toList();
  final uniqueDaysThisWeek = logsThisWeek
      .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
      .toSet();
  final workoutsCount = uniqueDaysThisWeek.length;

  // 2. Volume This Week
  double volumeThisWeek = 0;
  for (final log in logsThisWeek) {
    for (final set in log.sets) {
      volumeThisWeek += set.weight * set.reps;
    }
  }

  // 3. Current Streak
  int streak = 0;
  final uniqueDaysAll = logs
      .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // Descending

  if (uniqueDaysAll.isNotEmpty) {
    final todayDate = DateTime(now.year, now.month, now.day);
    var checkDate = todayDate;

    // If no workout today, check if yesterday has workout to start streak
    if (!uniqueDaysAll.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (uniqueDaysAll.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
  }

  return DashboardStats(
    workoutsThisWeek: workoutsCount,
    weeklyGoal: settings.weeklyWorkoutGoal,
    volumeThisWeek: volumeThisWeek,
    streak: streak,
  );
});
