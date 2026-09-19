import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../../data/repositories/calendar_repository.dart';
import '../../domain/entities/workout_session_entity.dart';
import '../../../workouts/domain/entities/workout_group_entity.dart';
import '../../../workouts/domain/entities/exercise_log_entity.dart';

class CalendarPage extends HookConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final focusedDay = useState(DateTime.now());
    final selectedDay = useState(DateTime.now());

    // Fetch sessions for the focused month
    final sessionsAsync = ref.watch(
      workoutSessionsProvider(
        user?.id ?? '',
        focusedDay.value.month,
        focusedDay.value.year,
      ),
    );

    // Fetch workout groups to resolve names
    final workoutGroupsAsync = ref.watch(workoutGroupsProvider(user?.id ?? ''));
    final logsAsync = ref.watch(allExerciseLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body:
          user == null
              ? const Center(child: CircularProgressIndicator())
              : sessionsAsync.when(
                data: (sessions) {
                  // Determine events
                  List<WorkoutSessionEntity> getEventsForDay(DateTime day) =>
                      sessions.where((s) => isSameDay(s.date, day)).toList();

                  final eventsForSelectedDay = getEventsForDay(
                    selectedDay.value,
                  );

                  final groupsMap = workoutGroupsAsync.maybeWhen(
                    data: (groups) => {for (var g in groups) g.id: g},
                    orElse: () => <int, WorkoutGroupEntity>{},
                  );

                  // Calculate daily stats from logs
                  final dailyLogs = logsAsync.maybeWhen(
                    data:
                        (logs) =>
                            logs
                                .where(
                                  (l) => isSameDay(l.date, selectedDay.value),
                                )
                                .toList(),
                    orElse: () => <ExerciseLogEntity>[],
                  );

                  final dailyVolume = dailyLogs.fold<double>(
                    0,
                    (sum, log) =>
                        sum +
                        log.sets.fold(
                          0,
                          (s, set) => s + (set.weight * set.reps),
                        ),
                  );

                  final distinctExercises =
                      dailyLogs.map((l) => l.exerciseId).toSet().length;

                  return Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: TableCalendar<WorkoutSessionEntity>(
                          locale: 'pt_BR',
                          firstDay: DateTime.utc(2020, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: focusedDay.value,
                          selectedDayPredicate:
                              (day) => isSameDay(selectedDay.value, day),
                          onDaySelected: (selected, focused) {
                            selectedDay.value = selected;
                            focusedDay.value = focused;
                          },
                          onPageChanged: (focused) {
                            focusedDay.value = focused;
                          },
                          eventLoader: getEventsForDay,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            markerDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            // Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.insights,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${eventsForSelectedDay.length} sessões • $distinctExercises exercícios',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      Text(
                                        'Volume do dia: ${(dailyVolume / 1000).toStringAsFixed(1)} ton',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (eventsForSelectedDay.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Nenhum treino neste dia.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              ...eventsForSelectedDay.map((e) {
                                final group = groupsMap[e.workoutGroupId];
                                final groupName =
                                    group?.name ??
                                    'Treino (ID: ${e.workoutGroupId})';
                                final exercisesList =
                                    group?.workouts
                                        .map((w) => w.exercise?.name)
                                        .whereType<String>()
                                        .join(', ') ??
                                    '';
                                final timeFormat = DateFormat('HH:mm');

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.fitness_center,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                    title: Text(
                                      groupName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (e.createdAt != null)
                                          Text(
                                            'Realizado às ${timeFormat.format(e.createdAt!.toLocal())}',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          ),
                                        if (exercisesList.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              exercisesList,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Erro: $e')),
              ),
    );
  }
}
