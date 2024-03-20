import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants.dart';
import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';
import '../widgets/exercise_group_card.dart';

final gymCalendarPageStoreProvider =
    ChangeNotifierProvider((ref) => GymCalendarPageStore());

class GymCalendarPage extends HookConsumerWidget {
  const GymCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GymCalendarPageStore store = ref.watch(gymCalendarPageStoreProvider);
    final now = DateTime.now();

    useEffect(() {
      initializeDateFormatting('pt_BR');
      store.loadValues(FireBaseUser!.uid);
      return null;
    }, [FireBaseUser!.uid]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar<WorkoutSession>(
              locale: 'pt_BR',
              daysOfWeekVisible: true,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerVisible: true,
              headerStyle:
                  HeaderStyle(formatButtonVisible: false, titleCentered: true),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: true,
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    return Text(
                      'Dom',
                      style: TextStyle(color: Colors.deepPurple),
                    );
                  }
                  return null;
                },
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) =>
                  store.isSameDate(day, store.selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                store.setSelectedDay(selectedDay);
              },
              onPageChanged: (onPageChanged) {
                store.setMonth(onPageChanged);
              },
              eventLoader: (day) => store.workoutSessions
                  .where((session) => store.isSameDate(session.date, day))
                  .toList(),
              focusedDay: store.selectedDay,
              firstDay: DateTime(2023, 1, 1),
              lastDay: DateTime(now.year, now.month + 1, 0),
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              height: 100.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WorkoutSummaryCard(
                  workoutCount: store.selectedEvents.length,
                  totalWorkoutsThisMonth: store.totalWorkoutsThisMonth,
                ),
              ),
            ),
          ),
          if (store.selectedEvents.isNotEmpty)
            Positioned(
              bottom: 130.0,
              left: 16.0,
              right: 16.0,
              child: Container(
                height: 150.0,
                child: GridView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  itemCount: store.selectedEvents.length,
                  itemBuilder: (context, index) {
                    final workoutSession = store.selectedEvents[index];
                    final workoutGroup = workoutSession.workoutsGroups!;

                    return ExerciseGroupCard(
                        workoutGroup: workoutGroup,
                        callback: () {
                          store.loadValues(FireBaseUser!.uid);
                        },
                        alreadyWorkout: false);
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    mainAxisExtent:150,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GymCalendarPageStore extends ChangeNotifier {
  List<WorkoutSession> workoutSessions = [];
  var totalWorkoutsThisMonth = 0;
  DateTime selectedDay = DateTime.now();
  bool isLoading = false;

  List<WorkoutSession> get selectedEvents => workoutSessions
      .where((session) => isSameDate(session.date, selectedDay))
      .toList();

  Future<void> loadValues(idUser) async {
    try {
      isLoading = true;
      workoutSessions = await getWorkoutSessions(idUser);
      totalWorkoutsThisMonth = workoutSessions
          .where((session) => session.date.month == selectedDay.month)
          .length;
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

  void setMonth(DateTime day) {
    selectedDay = day;
    totalWorkoutsThisMonth = workoutSessions
        .where((session) => session.date.month == day.month)
        .length;
    notifyListeners();
  }

  bool isSameDate(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class WorkoutSummaryCard extends StatelessWidget {
  final int workoutCount;
  final int totalWorkoutsThisMonth;

  const WorkoutSummaryCard({
    Key? key,
    required this.workoutCount,
    required this.totalWorkoutsThisMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = workoutCount > 0
        ? 'Você treinou ${workoutCount}x no dia.'
        : 'Você não treinou neste dia.';
    final totalMessage = 'Total no mês de $totalWorkoutsThisMonth treino(s)';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple, // Use your secondary color
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Change Row to Column
            crossAxisAlignment: CrossAxisAlignment.center, // Align to the left
            children: [
              Row(
                // Retain Row for icons and first message
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    // Wrap the message text
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                // Separate row for the second message
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    color: Colors.white
                        .withOpacity(0.8), // Slightly reduced opacity
                    size: 24.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    // Wrap the total message text
                    child: Text(
                      totalMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
