import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/pages/workouts_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobx/mobx.dart';
import '../constants.dart';
import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';

part 'gym_calendar_page.g.dart';

class GymCalendarPage extends StatefulWidget {
  const GymCalendarPage({Key? key}) : super(key: key);

  @override
  _GymCalendarPageState createState() => _GymCalendarPageState();
}

class _GymCalendarPageState extends State<GymCalendarPage> {
  late final GymCalendarPageStore _store;

  @override
  void initState() {
    _store = GymCalendarPageStore();
    initializeDateFormatting('pt_BR');
    super.initState();
    _store.loadValues();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

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
                        style: TextStyle(color: Colors.blue),
                      ),
                    );
                  }
                },
              ),
              selectedDayPredicate: (day) =>
                  _store.isSameDate(day, _store.selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                _store.setSelectedDay(selectedDay);
              },
              focusedDay: DateTime.now(),
              firstDay: DateTime(now.year, now.month, 1),
              lastDay: DateTime(now.year, now.month + 1, 0),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Observer(
              builder: (_) {
                if (_store.isLoading) {
                  return CircularProgressIndicator();
                } else {
                  return ListView.builder(
                    itemCount: _store.selectedEvents.length,
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
                                workoutGroup:
                                _store.selectedEvents[index].workoutsGroups!,
                                callback: () => {},
                              ),
                            ),
                          ),
                        },
                        title: Text(
                            '${_store.selectedEvents[index].workoutsGroups!.name}'),
                      ),
                    ),
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

class GymCalendarPageStore = _GymCalendarPageStoreBase
    with _$GymCalendarPageStore;

abstract class _GymCalendarPageStoreBase with Store {
  @observable
  List<WorkoutSession> workoutSessions = [];

  @observable
  DateTime selectedDay = DateTime.now();

  @computed
  List<WorkoutSession> get selectedEvents => workoutSessions
      .where((session) => isSameDate(session.date, selectedDay))
      .toList();

  @observable
  bool isLoading = false;

  @action
  Future<void> loadValues() async {
    isLoading = true;
    List<WorkoutSession> sessions = await getWorkoutSessions(idUser);

    workoutSessions = sessions;
    isLoading = false;
  }

  @action
  void setSelectedDay(DateTime day) {
    selectedDay = day;
  }

  bool isSameDate(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;

  void dispose() {
    // Dispose any disposables here, if necessary
  }
}
