import 'package:flutter/material.dart';
import 'package:my_academy/pages/welcome_page.dart';
import 'workout_group_page.dart';
import 'gym_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  final List<Widget> _screens = [
    const WorkoutGroupPage(),
    const WelcomePage(),
    const GymCalendarPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = 1;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        selectedItemColor:  Colors.red, // Roxo profundo sugerido pelo Alfred
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
        ],
      ),
    );
  }
}
