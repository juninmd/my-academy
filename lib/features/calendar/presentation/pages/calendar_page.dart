import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../../data/repositories/calendar_repository.dart';
import '../../domain/entities/workout_session_entity.dart';

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

                  final groupNames = workoutGroupsAsync.maybeWhen(
                    data: (groups) => {for (var g in groups) g.id: g.name},
                    orElse: () => <int, String>{},
                  );

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
                                    Icons.check_circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${eventsForSelectedDay.length} treinos no dia',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Total no mês: ${sessions.length}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
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
                              ...eventsForSelectedDay.map(
                                (e) => Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.fitness_center),
                                    title: Text(
                                      groupNames[e.workoutGroupId] ??
                                          'Treino (ID: ${e.workoutGroupId})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Realizado às ${e.date.hour.toString().padLeft(2, '0')}:${e.date.minute.toString().padLeft(2, '0')}',
                                    ),
                                    trailing: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
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
