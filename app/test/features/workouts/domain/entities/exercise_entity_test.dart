import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';

void main() {
  group('ExerciseEntity', () {
    test('should have correct props', () {
      const exercise = ExerciseEntity(
        id: 1,
        name: 'Bench Press',
        image: 'bench.jpg',
        tips: ['Tip 1'],
        mistakes: ['Mistake 1'],
        description: 'Description',
      );

      expect(exercise.id, 1);
      expect(exercise.name, 'Bench Press');
      expect(exercise.image, 'bench.jpg');
      expect(exercise.tips, ['Tip 1']);
      expect(exercise.mistakes, ['Mistake 1']);
      expect(exercise.description, 'Description');
      expect(exercise.props, [
        1,
        'Bench Press',
        'bench.jpg',
        ['Tip 1'],
        ['Mistake 1'],
        'Description',
        ExerciseType.strength,
      ]);
    });
  });
}
