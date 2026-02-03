import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../workouts/presentation/providers/workout_provider.dart';
import '../../../profile/presentation/providers/settings_provider.dart';

class WeeklyProgressCard extends ConsumerWidget {
  const WeeklyProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final weeklyGoal = settings.weeklyWorkoutGoal;
    final logsAsync = ref.watch(allExerciseLogsProvider);

    final now = DateTime.now();
    // Start of week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Generate days for the bottom strip
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return logsAsync.when(
      data: (logs) {
        // Filter logs for this week
        final thisWeekLogs = logs.where((log) {
          final logDate = DateTime(log.date.year, log.date.month, log.date.day);
          final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          final end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day).add(const Duration(days: 1)); // End of day
          return logDate.isAfter(start.subtract(const Duration(seconds: 1))) && logDate.isBefore(end);
        }).toList();

        // Count unique days
        final uniqueDays = thisWeekLogs.map((l) => DateTime(l.date.year, l.date.month, l.date.day)).toSet();
        final workoutsCount = uniqueDays.length;
        final progress = (workoutsCount / weeklyGoal).clamp(0.0, 1.0);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meta Semanal',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workoutsCount >= weeklyGoal
                                ? 'Objetivo Concluído! 🎉'
                                : 'Faltam ${weeklyGoal - workoutsCount} treinos',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            workoutsCount >= weeklyGoal
                                ? 'Você está voando baixo!'
                                : 'Mantenha o foco, você consegue.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 8,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$workoutsCount/$weeklyGoal',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Days Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekDays.map((date) {
                    final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                    final dateKey = DateTime(date.year, date.month, date.day);
                    final hasWorkout = uniqueDays.contains(dateKey);

                    return _DayDot(
                      date: date,
                      isToday: isToday,
                      hasWorkout: hasWorkout,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.date,
    required this.isToday,
    required this.hasWorkout,
  });

  final DateTime date;
  final bool isToday;
  final bool hasWorkout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DateFormat('E', 'pt_BR').format(date)[0].toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: hasWorkout
                ? Theme.of(context).colorScheme.primary
                : isToday
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
            border: Border.all(
              color: hasWorkout || isToday
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            shape: BoxShape.circle,
          ),
          child: hasWorkout
              ? Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.onPrimary)
              : Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
