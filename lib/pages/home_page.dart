import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:my_academy/pages/welcome_page.dart';
import '../repository/exercise_group_repository.dart';
import 'exercise_group_page.dart';
import 'meal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 1, vsync: this, length: 3);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  List<Widget> screens = [
    const ExerciseGroupPage(),
    WelcomePage(
        workoutImage: 'assets/images/draws/gym-boy.gif',
        exerciseGroup: exerciseGroups[0],
        favoriteExerciseGroup: exerciseGroups[0]),
    const MealPage(),
  ];

  Widget currentScreen = WelcomePage(
      workoutImage: 'assets/images/draws/gym-boy.gif',
      exerciseGroup: exerciseGroups[0],
      favoriteExerciseGroup: exerciseGroups[0]);
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: MotionTabBar(
          labels: const ["Treinos", "Home", "Alimentação"],
          initialSelectedTab: "Home",
          tabIconColor: Colors.black,
          tabBarColor: Colors.white60,
          tabSelectedColor: Colors.red,
          onTabItemSelected: (int value) {
            setState(() {
              _tabController.index = value;
              currentScreen = screens[value];
            });
          },
          icons: const [Icons.fitness_center, Icons.home, Icons.fastfood],
          textStyle: const TextStyle(color: Colors.red),
        ),
        body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: screens));
  }
}
