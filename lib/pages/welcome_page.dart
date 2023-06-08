import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dto/workout-summary.dart';

import '../services/my_academy/workout_session_api.dart';
import '../widgets/exercise_group_card.dart';
import '../widgets/workout_group_card_placeholder.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePage> {
  late WorkoutSummary workoutSummary;
  late int exerciseFrequency = 0;
  late String lastWorkout = 'Nenhum';
  late bool alreadWorkout = false;
  late bool isLoading = true; // Add this line

  @override
  void initState() {
    super.initState();
    loadValues();
  }

  loadValues() async {
    WorkoutSummary summary = await getWorkoutSummary(1);

    try {
      setState(() {
        isLoading = true; // Set isLoading to true before making the request
        // Load workout summary from API
        workoutSummary = summary;
        // Other state updates
        exerciseFrequency = summary.counter; // Update exerciseFrequency
        lastWorkout = summary.lastSession?.workoutsGroups?.name ??
            'Nenhum'; // Update lastWorkout

        // Compare last workout date with current day
        if (summary.lastSession != null) {
          DateTime currentDay = DateTime.now();
          DateTime lastWorkoutDay = summary.lastSession!.date;
          alreadWorkout = DateFormat('yyyy-MM-dd').format(currentDay) ==
              DateFormat('yyyy-MM-dd').format(lastWorkoutDay);
        }
      });
    } catch (error) {
      // Handle the error
    } finally {
      setState(() {
        isLoading =
            false; // Set isLoading to false after the request is completed
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
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
                  const SizedBox(height: 60),
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
                  // Show a loading circle while isLoading is true
                  if (isLoading || workoutSummary?.workoutGroupOfDay == null)
                    WorkoutGroupCardPlaceholder()
                  else
                    WorkoutGroupCard(
                      alreadWorkout: alreadWorkout,
                      workoutGroup: workoutSummary.workoutGroupOfDay!,
                      callback: loadValues,
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (!isLoading)
                    Center(
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
                                  lastWorkout,
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
                    )
                  else
                    WorkoutGroupCardPlaceholder(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      );
}
