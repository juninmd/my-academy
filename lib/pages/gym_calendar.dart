import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class GymCalendarPage extends StatefulWidget {
  const GymCalendarPage({Key? key}) : super(key: key);
  @override
  _GymCalendarPageState createState() => _GymCalendarPageState();
}

class _GymCalendarPageState extends State<GymCalendarPage> {


  @override
  void initState() {
    initializeDateFormatting('pt_BR');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Gym Calendar'),
      ),
      body: TableCalendar(
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            if (day.weekday == DateTime.sunday) {
              final text = DateFormat.E().format(day);
              return Center(
                child: Text(
                  text,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          },
        ),
        locale: 'pt_BR',
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
        ),
        focusedDay: DateTime.now(),
        firstDay: DateTime(now.year, now.month, 1),
        lastDay: DateTime(now.year, now.month + 1, 0),
      ),
    );
  }
}
