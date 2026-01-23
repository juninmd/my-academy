import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';

void main() {
  test('WorkoutCreateNotifier updates state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(workoutCreateNotifierProvider.notifier);

    notifier.updateName('New Name');
    expect(container.read(workoutCreateNotifierProvider).name, 'New Name');

    const exercise = ExerciseEntity(id: 1, name: 'Ex', bodyPart: 'Chest');
    notifier.addWorkout(exercise, 10, 20, 30);

    final state = container.read(workoutCreateNotifierProvider);
    expect(state.workouts.length, 1);
    expect(state.workouts[0].exerciseId, 1);
    expect(state.workouts[0].series.length, 1);
  });
}
