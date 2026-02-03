import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../workouts/presentation/providers/workout_provider.dart';

class WeeklyCalendarStrip extends ConsumerWidget {
  const WeeklyCalendarStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    // Assuming week starts on Sunday.
    // weekday: Mon=1, Sun=7.
    // If today is Sunday (7), we want to go back 0 days? Or is Sunday the start?
    // Let's assume standard ISO: Mon=1.
    // But usually calendar strips start Sunday or Monday.
    // Let's stick to Local defaults.

    // final currentWeekday = now.weekday; // 1(Mon)..7(Sun)
    // Let's Center the strip on "Today" or just show the current week "Sunday to Saturday"?
    // "Sunday to Saturday" is common in calendars.

    final firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
    // If today is Sunday (7), 7%7 = 0. We subtract 0. Correct.
    // If today is Monday (1), 1%7 = 1. We subtract 1. Last Sunday. Correct.

    final weekDays = List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));

    final logsAsync = ref.watch(allExerciseLogsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua Semana',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

              return logsAsync.when(
                data: (logs) {
                   final hasLog = logs.any((log) =>
                      log.date.year == date.year &&
                      log.date.month == date.month &&
                      log.date.day == date.day
                   );
                   return _DayCell(date: date, isToday: isToday, hasWorkout: hasLog);
                },
                loading: () => _DayCell(date: date, isToday: isToday, hasWorkout: false, isLoading: true),
                error: (e, s) => _DayCell(date: date, isToday: isToday, hasWorkout: false),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.hasWorkout,
    this.isLoading = false,
  });

  final DateTime date;
  final bool isToday;
  final bool hasWorkout;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          DateFormat('E', 'pt_BR').format(date)[0].toUpperCase(),
          style: TextStyle(
            color: isToday ? colorScheme.primary : Colors.grey,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isToday
                ? colorScheme.primary
                : hasWorkout
                    ? colorScheme.tertiaryContainer
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday ? null : Border.all(
              color: hasWorkout ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: isLoading
              ? SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onSurface))
              : Text(
                '${date.day}',
                style: TextStyle(
                  color: isToday
                      ? colorScheme.onPrimary
                      : hasWorkout
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
        ),
        const SizedBox(height: 4),
        if (hasWorkout)
          Icon(Icons.circle, size: 6, color: isToday ? colorScheme.primary : colorScheme.tertiary)
        else
          const SizedBox(height: 6),
      ],
    );
  }
}
