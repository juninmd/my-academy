import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/domain/repositories/home_repository.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';

class FakeHomeRepository implements HomeRepository {
  bool shouldThrow = false;
  WorkoutSummaryEntity? summaryToReturn;

  @override
  Future<Either<Failure, WorkoutSummaryEntity>> getWorkoutSummary() async {
    if (shouldThrow) {
      return const Left(ServerFailure('error'));
    }
    return Right(
      summaryToReturn ??
          const WorkoutSummaryEntity(counter: 0, hasWorkoutToday: false),
    );
  }
}

void main() {
  test('workoutSummary provider returns entity when success', () async {
    final fakeRepository = FakeHomeRepository();
    const entity = WorkoutSummaryEntity(counter: 1, hasWorkoutToday: true);
    fakeRepository.summaryToReturn = entity;

    final container = ProviderContainer(
      overrides: [homeRepositoryProvider.overrideWithValue(fakeRepository)],
    );

    // Keep provider alive
    final sub = container.listen(
      workoutSummaryProvider.future,
      (prev, next) {},
    );

    expect(await container.read(workoutSummaryProvider.future), entity);

    sub.close();
  });

  test('workoutSummary provider throws when failure', () async {
    final fakeRepository = FakeHomeRepository();
    fakeRepository.shouldThrow = true;

    final container = ProviderContainer(
      overrides: [homeRepositoryProvider.overrideWithValue(fakeRepository)],
    );

    final sub = container.listen(workoutSummaryProvider, (_, __) {});

    final asyncValue = container.read(workoutSummaryProvider);
    expect(asyncValue.isLoading, true);

    sub.close();
  });
}
