import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_academy/pages/welcome_page.dart';
import 'workout_group_page.dart';
import 'gym_calendar_page.dart';

final homePageStoreProvider = ChangeNotifierProvider((ref) => HomePageStore());

class HomePage extends ConsumerWidget {
  final List<Widget> _screens = [
    WorkoutGroupPage(),
    WelcomePage(),
    GymCalendarPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomePageStore store = ref.watch(homePageStoreProvider);

    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) => PageView(
          controller: store.pageController,
          onPageChanged: store.onPageChanged,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final currentIndex = ref.watch(homePageStoreProvider.select((value) => value.currentIndex));

          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => store.onTabSelected(index, context),
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
          );
        },
      ),
    );

  }
}

class HomePageStore extends ChangeNotifier {
  int currentIndex = 1;
  final PageController pageController = PageController(initialPage: 1);

  void onTabSelected(int index, BuildContext context) {
    currentIndex = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }
}