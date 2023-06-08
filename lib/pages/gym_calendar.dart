import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:my_academy/pages/workouts_page.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants.dart';
import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';

class GymCalendarPage extends StatefulWidget {
  const GymCalendarPage({Key? key}) : super(key: key);

  @override
  _GymCalendarPageState createState() => _GymCalendarPageState();
}

class _GymCalendarPageState extends State<GymCalendarPage> {
  List<WorkoutSession> _workoutSessions = [];
  late final ValueNotifier<List<WorkoutSession>> _selectedEvents;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    initializeDateFormatting('pt_BR');
    super.initState();
    loadValues();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<WorkoutSession> _getEventsForDay(DateTime day) => _workoutSessions
      .where((session) => isSameDate(session.date, day))
      .toList();

  Future<void> loadValues() async {
    List<WorkoutSession> sessions = await getWorkoutSessions(idUser);

    setState(() {
      _workoutSessions = sessions;
    });
  }

  bool isSameDate(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar<WorkoutSession>(
              locale: 'pt_BR',
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        'Dom',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    );
                  }
                },
              ),
              selectedDayPredicate: (day) => isSameDate(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _selectedEvents.value = _getEventsForDay(selectedDay);
                });
              },
              focusedDay: DateTime.now(),
              firstDay: DateTime(now.year, now.month, 1),
              lastDay: DateTime(now.year, now.month + 1, 0),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<WorkoutSession>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) => ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutsPage(
                                workoutGroup: value[index].workoutsGroups!,
                                callback: () => {}),
                          ))
                    },
                    title: Text('${value[index].workoutsGroups!.name}'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
