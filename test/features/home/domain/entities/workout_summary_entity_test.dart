import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';

void main() {
  test('WorkoutSummaryEntity supports value equality', () {
    const entity1 = WorkoutSummaryEntity(
      counter: 1,
      hasWorkoutToday: true,
      lastSessionDate: 'date',
      workoutName: 'name',
      personalName: 'personal',
      workoutGroupId: 1,
    );
    const entity2 = WorkoutSummaryEntity(
      counter: 1,
      hasWorkoutToday: true,
      lastSessionDate: 'date',
      workoutName: 'name',
      personalName: 'personal',
      workoutGroupId: 1,
    );

    expect(entity1, equals(entity2));
  });
}
