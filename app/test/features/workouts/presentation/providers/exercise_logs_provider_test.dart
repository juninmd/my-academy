import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';
import 'package:my_academy/core/exceptions/failure.dart';

import 'workout_provider_test.mocks.dart';

class MockAuthNotifier extends AuthNotifier {
  final UserEntity? _initial;
  MockAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

void main() {
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
  });

  const user = UserEntity(id: 'u1', email: 'e', name: 'n');
  final date = DateTime(2023, 1, 1);
  final logs = [
    ExerciseLogEntity(
      id: '1',
      userId: 'u1',
      exerciseId: 1,
      date: date,
      sets: [],
    ),
  ];

  group('exerciseLogsProvider', () {
    test('returns empty list when user is not logged in', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(null)),
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // We need to listen to it so it doesn't get auto-disposed before resolution
      final sub = container.listen(exerciseLogsProvider(1).future, (_, _) {});

      final result = await container.read(exerciseLogsProvider(1).future);
      expect(result, isEmpty);
      sub.close();
    });

    test('returns logs when successful', () async {
      when(
        mockRepository.getExerciseLogs('u1', 1),
      ).thenAnswer((_) async => Right(logs));

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(user)),
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final sub = container.listen(exerciseLogsProvider(1).future, (_, _) {});

      final result = await container.read(exerciseLogsProvider(1).future);
      expect(result, logs);
      sub.close();
    });

    test('throws exception when repository returns failure', () async {
      when(
        mockRepository.getExerciseLogs('u1', 1),
      ).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(user)),
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Use a listener to check for the error state directly instead of reading the future.
      // Reading `.future` on an autoDispose provider that throws an exception can cause
      // uncaught asynchronous errors in the test environment if not handled carefully,
      // leading to test timeouts.
      Object? capturedError;
      final sub = container.listen(
        exerciseLogsProvider(1),
        (previous, next) {
          if (next.hasError) {
            capturedError = next.error;
          }
        },
        fireImmediately: true,
      );

      // Wait a tiny bit for the microtask to complete and the provider to resolve
      await Future.delayed(Duration.zero);

      expect(capturedError, isNotNull);
      expect(capturedError, isA<Exception>());

      final state = container.read(exerciseLogsProvider(1));
      expect(state.hasError, isTrue);

      sub.close();
    });
  });

  group('allExerciseLogsProvider', () {
    test('returns empty list when user is not logged in', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(null)),
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final sub = container.listen(allExerciseLogsProvider.future, (_, _) {});

      final result = await container.read(allExerciseLogsProvider.future);
      expect(result, isEmpty);
      sub.close();
    });

    test('returns logs when successful', () async {
      when(
        mockRepository.getAllExerciseLogs('u1'),
      ).thenAnswer((_) async => Right(logs));

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(user)),
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final sub = container.listen(allExerciseLogsProvider.future, (_, _) {});

      final result = await container.read(allExerciseLogsProvider.future);
      expect(result, logs);
      sub.close();
    });

    test('throws exception when repository returns failure', () async {
      when(
        mockRepository.getAllExerciseLogs('u1'),
      ).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(user)),
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      // Use a listener to check for the error state directly instead of reading the future.
      Object? capturedError;
      final sub = container.listen(
        allExerciseLogsProvider,
        (previous, next) {
          if (next.hasError) {
            capturedError = next.error;
          }
        },
        fireImmediately: true,
      );

      // Wait a tiny bit for the microtask to complete and the provider to resolve
      await Future.delayed(Duration.zero);

      expect(capturedError, isNotNull);
      expect(capturedError, isA<Exception>());

      final state = container.read(allExerciseLogsProvider);
      expect(state.hasError, isTrue);

      sub.close();
    });
  });
}
