import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/pages/home_page.dart';
import '../constants.dart';
import '../models/personal.dart';
import '../services/my_academy/personal_api.dart';
import 'students_page.dart';
import 'workout_group_page.dart';

final menusPageStoreProvider =
ChangeNotifierProvider((ref) => MenusPageStore());

class MenusPage extends HookConsumerWidget {
  const MenusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MenusPageStore store = ref.watch(menusPageStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, const []);

    final screens = <Widget>[
      if (store.personal != null) const StudentsPage(),
      const HomePage(),
      WorkoutGroupPage(FireBaseUser!.uid, null),
    ];

    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) => PageView(
          controller: store.pageController,
          onPageChanged: store.onPageChanged,
          children: screens,
          physics: const BouncingScrollPhysics(), // Add bouncing effect
        ),
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final currentIndex = ref.watch(
              menusPageStoreProvider.select((value) => value.currentIndex));

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300), // Animation duration
            curve: Curves.easeInOutCubic, // Animation curve
            decoration: BoxDecoration(
              color: currentIndex == 0
                  ? Colors.red // Change color based on index
                  : Colors.blueGrey, // Change color based on index
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Subtle shadow
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0.0, 5.0),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => store.onTabSelected(index, context),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              selectedFontSize: 16,
              items: [
                if (store.personal != null)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.note_alt_rounded),
                    label: 'Aulas',
                  ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center),
                  label: 'Treinos',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MenusPageStore extends ChangeNotifier {
  int currentIndex = 0;
  final PageController pageController = PageController(initialPage: 0);
  bool isLoading = true;
  Personal? personal = null;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      personal = await getPersonalById(FireBaseUser!.uid);
    } catch (error) {
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onTabSelected(int index, BuildContext context) {
    currentIndex = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
