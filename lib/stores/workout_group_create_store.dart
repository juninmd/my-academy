import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';
import '../models/exercise.dart';
import '../models/method.dart';
import '../models/workout.dart';
import '../models/workout_group.dart';
import '../models/workout_series.dart';
import '../services/my_academy/exercises_api.dart';
import '../services/my_academy/method_api.dart';
import '../services/my_academy/workout_group_api.dart';
import '../utils.dart';
import 'package:collection/collection.dart';

class WorkoutGroupCreateStore extends ChangeNotifier {
  List<Exercise> _filteredExercises = [];
  List<Exercise> _exercises = [];
  List<WorkoutSeries> seriesList = [];
  List<Workout> workouts = [];
  List<Method> methods = [];
  int? methodId;

  List<Exercise> get exercises =>
      _filteredExercises.isNotEmpty ? _filteredExercises : _exercises;

  List<Exercise> get filteredExercises => _filteredExercises;

  WorkoutGroup workoutGroup = WorkoutGroup(
      name: '',
      userId: idUser,
      description: '',
      dateEnd: DateTime.now(),
      dateStart: DateTime.now(),
      image: '',
      level: 1,
      workouts: []);

  bool isLoading = true;

  void notify() {
    notifyListeners();
  }

  void filterExercises(String filter) {
    if (filter.isEmpty) {
      _filteredExercises = _exercises;
      notify();
      return;
    }
    String lowercaseFilter = filter.toLowerCase();
    _filteredExercises = _exercises
        .where((Exercise exercise) =>
            exercise.name.toLowerCase().contains(lowercaseFilter))
        .toList();
    notify();
  }

  Future<void> loadValues(idUser) async {
    try {
      isLoading = true;
      _exercises = await getExercises();
      _filteredExercises = _exercises;
    } catch (error) {
      print(error);
// Handle the error
    } finally {
      isLoading = false;
      notify();
    }
  }

  Future<void> loadWorkoutsSeriesByWorkout(
      int? workoutId, int exerciseId) async {
    // Se vai criar novas séries
    if (workoutId == null) {
      if (workouts.isNotEmpty) {
        var workout = workouts
            .firstWhereOrNull((element) => element.exerciseId == exerciseId);
        seriesList = workout?.workoutSeries ?? [WorkoutSeries(repetitions: 15, weight: 10, rest: 60)];
        methodId = workout?.methodId;
        return;
      }
      seriesList = [WorkoutSeries(repetitions: 15, weight: 10, rest: 60)];
      return;
    }
    try {
      isLoading = true;
    } catch (error) {
      print(error);
// Handle the error
    } finally {
      isLoading = false;
      notify();
    }
  }

  void addWorkout(int? workoutId, int exerciseId,
      List<WorkoutSeries> workoutSeries, int? methodIdParam) {
    var index =
        workouts.indexWhere((element) => element.exerciseId == exerciseId);

    if (index >= 0) {
      workouts[index].workoutSeries = workoutSeries;
      workouts[index].methodId = methodId;
      notify();
      return;
    }

    workouts.add(Workout(
        exerciseId: exerciseId, id: workoutId, workoutSeries: workoutSeries));

    notify();
  }

  Future<void> createWorkoutGroup(idUser) async {
    List<String> imagePaths = [
      'assets/images/bg1.jpg',
      'assets/images/bg2.jpg',
      'assets/images/bg3.jpg',
      'assets/images/bg4.jpg',
      'assets/images/bg5.jpg',
      'assets/images/bg6.jpg',
    ];

    final background = getRandomImagePath(imagePaths);

    workoutGroup.image = background;
    workoutGroup.userId = idUser;
    workoutGroup.level = 1;
    workoutGroup.workouts = workouts;

    await postWorkoutGroup(workoutGroup);
  }

  Future<void> loadWorkouts(int? workoutGroupId) async {
    // Se vai criar novas séries
    if (workoutGroupId == null) {
      workouts = [];
      notify();
      return;
    }
    try {
      isLoading = true;
    } catch (error) {
      print(error);
// Handle the error
    } finally {
      isLoading = false;
      notify();
    }
  }

  Future<void> loadMethods() async {
    try {
      isLoading = true;
      methods = await getMethods();
    } catch (error) {
      print(error);
    } finally {
      isLoading = false;
      notify();
    }
  }
}

final workoutGroupCreateStoreProvider =
    ChangeNotifierProvider((ref) => WorkoutGroupCreateStore());
