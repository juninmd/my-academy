import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/exercise.dart';
import '../models/workout_group.dart';
import '../services/my_academy/exercises_api.dart';
import '../services/my_academy/workout_group_api.dart';

class WorkoutGroupStore extends ChangeNotifier {
  List<WorkoutGroup> workoutGroups = [];

  WorkoutGroup workoutGroup = WorkoutGroup(
      name: '',
      userId: idUser,
      description: '',
      dateEnd: DateTime.now(),
      dateStart: DateTime.now(),
      image: '',
      level: 1,
      workouts: []);

  List<Exercise> exercises = [];
  bool isLoading = true;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      workoutGroups = await getWorkoutGroups(idUser);
      exercises = await getExercises();
    } catch (error) {
// Handle the error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
