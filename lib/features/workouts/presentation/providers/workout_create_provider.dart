import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/workout_group_entity.dart';
import '../../domain/entities/workout_series_entity.dart';
import 'workout_provider.dart';

part 'workout_create_provider.g.dart';

@riverpod
class WorkoutCreateNotifier extends _$WorkoutCreateNotifier {
  @override
  WorkoutGroupEntity build() =>
      const WorkoutGroupEntity(name: '', userId: '', workouts: []);

  void loadGroup(WorkoutGroupEntity group) {
    state = group;
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void addWorkout(ExerciseEntity exercise, int reps, int weight, int rest) {
    final newSeries = WorkoutSeriesEntity(
      repetitions: reps,
      weight: weight,
      rest: rest,
    );

    // Check if workout exists for this exercise
    final existingIndex = state.workouts.indexWhere(
      (w) => w.exerciseId == exercise.id,
    );

    if (existingIndex >= 0) {
      // Update existing
      final existingWorkout = state.workouts[existingIndex];
      final updatedWorkout = WorkoutEntity(
        id: existingWorkout.id,
        exerciseId: existingWorkout.exerciseId,
        exercise: existingWorkout.exercise,
        series: [...existingWorkout.series, newSeries],
      );

      final newWorkouts = [...state.workouts];
      newWorkouts[existingIndex] = updatedWorkout;
      state = state.copyWith(workouts: newWorkouts);
    } else {
      // Create new
      final newWorkout = WorkoutEntity(
        exerciseId: exercise.id,
        exercise: exercise,
        series: [newSeries],
      );

      state = state.copyWith(workouts: [...state.workouts, newWorkout]);
    }
  }

  void removeWorkout(int index) {
    final newWorkouts = [...state.workouts];
    newWorkouts.removeAt(index);
    state = state.copyWith(workouts: newWorkouts);
  }

  void reorderWorkouts(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newWorkouts = [...state.workouts];
    final item = newWorkouts.removeAt(oldIndex);
    newWorkouts.insert(newIndex, item);
    state = state.copyWith(workouts: newWorkouts);
  }

  Future<void> saveGroup(String userId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final groupToSave = state.copyWith(userId: userId);

    if (state.id != null) {
      await repository.updateWorkoutGroup(groupToSave);
    } else {
      await repository.createWorkoutGroup(groupToSave);
    }
    ref.invalidate(workoutGroupsProvider(userId));
  }
}

@riverpod
Future<List<ExerciseEntity>> exercises(Ref ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final result = await repository.getExercises();
  return result.fold((failure) => [], (list) => list);
}

// Alias for backward compatibility
final workoutCreateNotifierProvider = workoutCreateProvider;
