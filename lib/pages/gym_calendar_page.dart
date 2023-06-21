import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/pages/workouts_page.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants.dart';
import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';

final gymCalendarPageStoreProvider =
    ChangeNotifierProvider((ref) => GymCalendarPageStore());

class GymCalendarPage extends HookConsumerWidget {
  const GymCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GymCalendarPageStore store = ref.watch(gymCalendarPageStoreProvider);
    final now = DateTime.now();

    useEffect(() {
      store.loadValues();
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar<WorkoutSession>(
              locale: 'pt_BR',
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false,
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        'Dom',
                        style: TextStyle(color: Colors.blue),
                      ),
                    );
                  }
                },
              ),
              selectedDayPredicate: (day) =>
                  store.isSameDate(day, store.selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                store.setSelectedDay(selectedDay);
              },
              focusedDay: DateTime.now(),
              firstDay: DateTime(now.year, now.month, 1),
              lastDay: DateTime(now.year, now.month + 1, 0),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            store.selectedEvents.length > 0
                ? 'Você fez ${store.selectedEvents.length} treino(s)'
                : 'Você não treinou',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final selectedEvents = ref.watch(gymCalendarPageStoreProvider
                    .select((value) => value.selectedEvents));

                if (store.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final workoutSession = selectedEvents[index];
                      final workoutGroup = workoutSession.workoutsGroups!;
                      final workoutCount = selectedEvents.length;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutsPage(
                              workoutGroup: workoutGroup,
                              callback: () {},
                            ),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                workoutGroup.image,
                                fit: BoxFit.cover,
                                height: 120,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workoutGroup.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GymCalendarPageStore extends ChangeNotifier {
  List<WorkoutSession> workoutSessions = [];
  DateTime selectedDay = DateTime.now();
  bool isLoading = false;

  List<WorkoutSession> get selectedEvents => workoutSessions
      .where((session) => isSameDate(session.date, selectedDay))
      .toList();

  Future<void> loadValues() async {
    try {
      isLoading = true;
      initializeDateFormatting('pt_BR');
      workoutSessions = await getWorkoutSessions(idUser);
    } catch (error) {
      // Handle the error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDay(DateTime day) {
    selectedDay = day;
    notifyListeners();
  }

  bool isSameDate(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
