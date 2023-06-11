import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:my_academy/pages/welcome_page.dart';
import 'workout_group_page.dart';
import 'gym_calendar_page.dart';

part 'home_page.g.dart';

class HomePage extends StatelessWidget {
  final HomePageStore _store = HomePageStore();

  final List<Widget> _screens = [
    WorkoutGroupPage(),
    WelcomePage(),
    GymCalendarPage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Observer(
        builder: (_) => PageView(
          controller: _store.pageController,
          onPageChanged: _store.onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Observer(
        builder: (_) => BottomNavigationBar(
          currentIndex: _store.currentIndex,
          onTap: _store.onTabSelected,
          selectedItemColor: Colors.blue, // Roxo profundo sugerido pelo Alfred
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
      ),
    );
}

@observable
class HomePageStore = _HomePageStoreBase with _$HomePageStore;

abstract class _HomePageStoreBase with Store {
  @observable
  int currentIndex = 1;

  final PageController pageController = PageController(initialPage: 1);

  @action
  void onTabSelected(int index) {
    currentIndex = index;
    pageController.jumpToPage(index);
  }

  @action
  void onPageChanged(int index) {
    currentIndex = index;
  }
}
