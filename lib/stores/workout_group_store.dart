import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants.dart';
import '../models/exercise.dart';
import '../models/workout_group.dart';
import '../services/my_academy/exercises_api.dart';
import '../services/my_academy/workout_group_api.dart';

class WorkoutGroupStore extends ChangeNotifier {
  List<WorkoutGroup> workoutGroups = [];
  List<Exercise> _filteredExercises = [];
  List<Exercise> _exercises = [];

  List<Exercise> get exercises =>
      _filteredExercises.isNotEmpty ? _filteredExercises : _exercises;
  List<Exercise> get filteredExercises => _filteredExercises;

  bool isLoading = true;

  void notify() {
    notifyListeners();
  }

  void filterExercises(String filter) {
    if (filter.isEmpty) {
      _filteredExercises = _exercises;
      notifyListeners();
      return;
    }
    var lowercaseFilter = filter.toLowerCase();
    _filteredExercises = _exercises
        .where(
            (exercise) => exercise.name.toLowerCase().contains(lowercaseFilter))
        .toList();
    notifyListeners();
  }

  Future<void> loadValues(idUser) async {
    try {
      isLoading = true;
      workoutGroups = await getWorkoutGroups(idUser);
      _exercises = await getExercises();
      _filteredExercises = _exercises;
    } catch (error) {
      print(error);
// Handle the error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkoutsSeriesByWorkout(int? workoutId) async {
    if (workoutId == null) {
      return;
    }
    try {
      isLoading = true;
      workoutGroups = await getWorkoutGroups(idUser);
      _exercises = await getExercises();
      _filteredExercises = _exercises;
    } catch (error) {
      print(error);
// Handle the error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final workoutGroupStoreProvider =
ChangeNotifierProvider((ref) => WorkoutGroupStore());
