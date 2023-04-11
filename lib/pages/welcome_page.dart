import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:my_academy/models/exercise_group.dart';
import '../repository/exercise_group_repository.dart';

import '../repository/workouts_repository.dart';
import '../widgets/calories_progress_bar.dart';
import '../widgets/exercise_group_card.dart';
import 'exercise_list_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePage> {
  late ExerciseGroup exerciseGroup = exerciseGroups[0];
  late int exerciseFrequency = 0;
  late String lastWorkout = '';
  late bool alreadWorkout = true;

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  loadValues() async {
    await checkExerciseOfDay();
    int exerciseGroupIdIndex = await getExerciseIdOfDay();
    int frequency = await getExerciseFrequency();
    String lastWorkoutDate = (await getLastExerciseDate()) ?? 'Sem treinos';
    bool alreadWorkoutToday = await checkAlreadWorkoutToday();

    setState(() {
      lastWorkout = lastWorkoutDate;
      exerciseFrequency = frequency;
      exerciseGroup = exerciseGroups.firstWhere(
          (element) => element.id == exerciseGroupIdIndex,
          orElse: () => exerciseGroups[0]);
      alreadWorkout = alreadWorkoutToday;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Scaffold(
        body: Stack(fit: StackFit.expand, children: [
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/images/bg1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: const Color(0xff0B183C).withOpacity(0.69),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Treino do dia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                DelayedDisplay(
                  delay: const Duration(milliseconds: 350),
                  slidingBeginOffset: const Offset(0.0, 0.6),
                  child: ExerciseGroupCard(
                      alreadWorkout: alreadWorkout,
                      exerciseGroup: exerciseGroup),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Row(
                    children: [
                      const SizedBox(width: 60),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Último treino',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.deepPurple,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Text(
                              lastWorkout!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sequência de',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.deepPurple,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Text(
                              '$exerciseFrequency treinos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
