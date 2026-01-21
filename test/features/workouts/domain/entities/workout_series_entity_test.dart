import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_series_entity.dart';

void main() {
  group('WorkoutSeriesEntity', () {
    test('should have correct props', () {
      const series = WorkoutSeriesEntity(
        id: 1,
        workoutId: 2,
        repetitions: 12,
        weight: 30,
        rest: 60,
      );

      expect(series.id, 1);
      expect(series.workoutId, 2);
      expect(series.repetitions, 12);
      expect(series.weight, 30);
      expect(series.rest, 60);
      expect(series.props, [1, 2, 12, 30, 60]);
    });
  });
}
