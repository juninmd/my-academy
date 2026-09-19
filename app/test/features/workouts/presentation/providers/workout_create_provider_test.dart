import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

import 'workout_provider_test.mocks.dart';

void main() {
  test('WorkoutCreateNotifier updates state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(workoutCreateNotifierProvider.notifier);

    notifier.updateName('New Name');
    expect(container.read(workoutCreateNotifierProvider).name, 'New Name');

    const exercise = ExerciseEntity(id: 1, name: 'Ex');
    notifier.addWorkout(exercise, 10, 20, 30);

    final state = container.read(workoutCreateNotifierProvider);
    expect(state.workouts.length, 1);
    expect(state.workouts[0].exerciseId, 1);
    expect(state.workouts[0].series.length, 1);
  });

  test(
    'saveGroup surfaces a rejected save instead of pretending it worked',
    () async {
      final repository = MockWorkoutRepository();
      when(repository.createWorkoutGroup(any)).thenAnswer(
        (_) async => const Left(ServerFailure('image should not be empty')),
      );
      final container = ProviderContainer(
        overrides: [workoutRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(workoutCreateNotifierProvider.notifier);
      notifier.updateName('Treino A');

      await expectLater(
        notifier.saveGroup('u1'),
        throwsA(isA<ServerFailure>()),
      );
      final saved =
          verify(repository.createWorkoutGroup(captureAny)).captured.single
              as WorkoutGroupEntity;
      expect(saved.userId, 'u1');
    },
  );
}
