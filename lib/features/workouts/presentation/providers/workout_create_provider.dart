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

  void updateName(String name) {
    state = WorkoutGroupEntity(
      id: state.id,
      name: name,
      image: state.image,
      userId: state.userId,
      workouts: state.workouts,
    );
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
      state = WorkoutGroupEntity(
        id: state.id,
        name: state.name,
        image: state.image,
        userId: state.userId,
        workouts: newWorkouts,
      );
    } else {
      // Create new
      final newWorkout = WorkoutEntity(
        exerciseId: exercise.id,
        exercise: exercise,
        series: [newSeries],
      );

      state = WorkoutGroupEntity(
        id: state.id,
        name: state.name,
        image: state.image,
        userId: state.userId,
        workouts: [...state.workouts, newWorkout],
      );
    }
  }

  Future<void> saveGroup(String userId) async {
    // TODO: Call Repository create
    print('Saving Group: ${state.name} with ${state.workouts.length} workouts');
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
