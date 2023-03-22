import 'package:flutter/material.dart';
import 'exercise_group_page.dart';
import 'meal_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    ExerciseGroupPage(),
    MealPage(),
    ExerciseGroupPage(),
    ExerciseGroupPage(),
  ];

  Widget currentScreen = const ExerciseGroupPage();
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageStorage(
          bucket: bucket,
          child: currentScreen,
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              // Define each item as an IconButton with an icon and a label
              IconButton(
                  iconSize: currentIndex == 0 ? 32 : 24,
                  icon: const Icon(Icons.fitness_center),
                  tooltip: 'Exercícios',
                  onPressed: () => setState(() {
                        currentScreen = screens[0];
                        currentIndex = 0;
                      })),
              IconButton(
                iconSize: currentIndex == 1 ? 32 : 24,
                icon: const Icon(Icons.fastfood),
                onPressed: () => setState(() {
                  currentScreen = screens[1];
                  currentIndex = 1;
                }),
                tooltip: 'Alimentação',
              ),
              IconButton(
                iconSize: currentIndex == 2 ? 32 : 24,
                icon: const Icon(Icons.bar_chart),
                onPressed: () => setState(() {
                  currentScreen = screens[2];
                  currentIndex = 2;
                }),
                tooltip: 'Histórico',
              ),
              // Define the center item as a FloatingActionButton with an icon and no label
              IconButton(
                iconSize: currentIndex == 3 ? 32 : 24,
                icon: const Icon(Icons.person),
                tooltip: 'Perfil',
                onPressed: () => setState(() {
                  currentScreen = screens[3];
                  currentIndex = 3;
                }),
              ),
            ])));
  }
}
