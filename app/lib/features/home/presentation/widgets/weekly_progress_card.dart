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
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return logsAsync.when(
      data: (logs) {
        // Filter logs for this week
        final thisWeekLogs =
            logs.where((log) {
              final logDate = DateTime(
                log.date.year,
                log.date.month,
                log.date.day,
              );
              final start = DateTime(
                startOfWeek.year,
                startOfWeek.month,
                startOfWeek.day,
              );
              final end = DateTime(
                endOfWeek.year,
                endOfWeek.month,
                endOfWeek.day,
              ).add(const Duration(days: 1)); // End of day
              return logDate.isAfter(
                    start.subtract(const Duration(seconds: 1)),
                  ) &&
                  logDate.isBefore(end);
            }).toList();

        // Count unique days
        final uniqueDays =
            thisWeekLogs
                .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
                .toSet();
        final workoutsCount = uniqueDays.length;
        final progress = (workoutsCount / weeklyGoal).clamp(0.0, 1.0);

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDark
                        ? [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.8),
                        ]
                        : [
                          Colors.white,
                          Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Meta Semanal',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            workoutsCount >= weeklyGoal
                                ? 'Objetivo Concluído! 🎉'
                                : 'Faltam ${weeklyGoal - workoutsCount} treinos',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workoutsCount >= weeklyGoal
                                ? 'Você está voando baixo!'
                                : 'Mantenha o foco, você consegue.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 8,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
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
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Days Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      weekDays.map((date) {
                        final isToday =
                            date.day == now.day &&
                            date.month == now.month &&
                            date.year == now.year;
                        final dateKey = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );
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
      loading:
          () => const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error: (e, s) => const SizedBox(),
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
            color:
                isToday
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient:
                hasWorkout
                    ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color:
                hasWorkout
                    ? null
                    : isToday
                    ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
            border: Border.all(
              color:
                  hasWorkout
                      ? Colors.transparent
                      : isToday
                      ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5)
                      : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
              width: isToday ? 2 : 1,
            ),
            shape: BoxShape.circle,
            boxShadow:
                hasWorkout
                    ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child:
              hasWorkout
                  ? Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                  : Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                        color:
                            isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
