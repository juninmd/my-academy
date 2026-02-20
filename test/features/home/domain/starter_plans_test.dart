import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/home/domain/starter_plans.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';

void main() {
  test('StarterPlans.getPlans returns plans when exercises match', () {
    final exercises = [
      const ExerciseEntity(id: 1, name: 'Supino Reto'),
      const ExerciseEntity(id: 2, name: 'Agachamento'),
      const ExerciseEntity(id: 3, name: 'Remada Curvada'),
      const ExerciseEntity(id: 4, name: 'Desenvolvimento'),
    ];

    final plans = StarterPlans.getPlans(exercises);

    expect(plans.isNotEmpty, true);
    expect(plans.first.name, contains('Full Body'));
    expect(plans.first.workouts.length, 4);
  });

  test('StarterPlans.getPlans returns empty list when no exercises match', () {
    final exercises = [
      const ExerciseEntity(id: 1, name: 'Yoga'),
      const ExerciseEntity(id: 2, name: 'Pilates'),
    ];

    final plans = StarterPlans.getPlans(exercises);

    expect(plans.isEmpty, true);
  });
}
