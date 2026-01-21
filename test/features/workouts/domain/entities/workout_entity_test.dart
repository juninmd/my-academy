import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_series_entity.dart';

void main() {
  group('WorkoutEntity', () {
    test('should have correct props', () {
      const exercise = ExerciseEntity(id: 1, name: 'Exercise 1');
      const series = [WorkoutSeriesEntity(repetitions: 10, weight: 20, rest: 60)];
      const workout = WorkoutEntity(
        id: 1,
        exerciseId: 10,
        methodId: 2,
        description: 'Do it well',
        exercise: exercise,
        series: series,
        isFinished: true,
      );

      expect(workout.id, 1);
      expect(workout.exerciseId, 10);
      expect(workout.methodId, 2);
      expect(workout.description, 'Do it well');
      expect(workout.exercise, exercise);
      expect(workout.series, series);
      expect(workout.isFinished, true);
      expect(workout.props, [
        1,
        10,
        2,
        'Do it well',
        exercise,
        series,
        true,
      ]);
    });
  });
}
