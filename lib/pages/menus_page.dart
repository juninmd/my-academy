import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_academy/pages/home_page.dart';
import 'classes_page.dart';
import 'workout_group_page.dart';
import 'gym_calendar_page.dart';

final menusPageStoreProvider =
    ChangeNotifierProvider((ref) => MenusPageStore());

class MenusPage extends ConsumerWidget {
  final List<Widget> _screens = [
    ClassesPage(),
    WorkoutGroupPage(),
    HomePage(),
    GymCalendarPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MenusPageStore store = ref.watch(menusPageStoreProvider);

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
          final currentIndex = ref.watch(
              menusPageStoreProvider.select((value) => value.currentIndex));

          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => store.onTabSelected(index, context),
            selectedItemColor:
                Colors.deepPurple, // Roxo profundo sugerido pelo Alfred
            unselectedItemColor: Colors.white,
            selectedFontSize: 16,
            selectedLabelStyle: TextStyle( shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 0.0),
                blurRadius: 15.0,
                color: Color.fromARGB(55, 0, 0, 0),
              ),
            ]) ,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.note_alt_rounded),
                label: 'Aulas',
              ),
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

class MenusPageStore extends ChangeNotifier {
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
