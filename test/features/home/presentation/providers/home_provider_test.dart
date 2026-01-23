import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/domain/repositories/home_repository.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';

@GenerateNiceMocks([MockSpec<HomeRepository>()])
import 'home_provider_test.mocks.dart';

void main() {
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
  });

  test('workoutSummary provider returns entity when success', () async {
    const entity = WorkoutSummaryEntity(counter: 1, hasWorkoutToday: true);
    when(mockRepository.getWorkoutSummary()).thenAnswer((_) async => const Right(entity));

    final container = ProviderContainer(
      overrides: [
        homeRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(workoutSummaryProvider.future),
      entity,
    );
  });

  test('workoutSummary provider throws when failure', () async {
    when(mockRepository.getWorkoutSummary()).thenAnswer((_) async => const Left(ServerFailure('error')));

     final container = ProviderContainer(
      overrides: [
        homeRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(workoutSummaryProvider.future),
      throwsException,
    );
  });
}
