import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_entity.dart';

void main() {
  group('WorkoutGroupEntity', () {
    test('should have correct props', () {
      const workout = WorkoutEntity(exerciseId: 1);
      const group = WorkoutGroupEntity(
        id: 1,
        name: 'Leg Day',
        image: 'legs.jpg',
        userId: 'user1',
        workouts: [workout],
      );

      expect(group.id, 1);
      expect(group.name, 'Leg Day');
      expect(group.image, 'legs.jpg');
      expect(group.userId, 'user1');
      expect(group.workouts, [workout]);
      expect(group.props, [
        1,
        'Leg Day',
        'legs.jpg',
        'user1',
        [workout],
      ]);
    });
  });
}
