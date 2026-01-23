import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/workouts/domain/repositories/workout_repository.dart';
import 'package:my_academy/features/workouts/presentation/providers/exercise_stats_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

@GenerateNiceMocks([MockSpec<WorkoutRepository>()])
import 'exercise_stats_provider_test.mocks.dart';

void main() {
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
  });

  const user = UserEntity(id: 'u1', email: 'e', name: 'n');

  test('exerciseStatsProvider returns logs when success', () async {
    when(mockRepository.getExerciseLogs(any, any)).thenAnswer((_) async => const Right([]));

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => Stream.value(user)),
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(exerciseStatsProvider(1).future),
      isEmpty,
    );
  });
}
