import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/features/home/data/datasources/home_remote_data_source.dart';
import 'package:my_academy/features/home/data/repositories/home_repository_impl.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';

@GenerateNiceMocks([MockSpec<HomeRemoteDataSource>()])
import 'home_repository_impl_test.mocks.dart';

void main() {
  late MockHomeRemoteDataSource mockDataSource;
  late HomeRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockHomeRemoteDataSource();
    repository = HomeRepositoryImpl(mockDataSource);
  });

  const entity = WorkoutSummaryEntity(
    counter: 1,
    hasWorkoutToday: true,
  );

  test('should return summary when successful', () async {
    when(mockDataSource.getWorkoutSummary()).thenAnswer((_) async => entity);
    final result = await repository.getWorkoutSummary();
    expect(result, const Right(entity));
  });

  test('should return failure when exception', () async {
    when(mockDataSource.getWorkoutSummary()).thenThrow(Exception('error'));
    final result = await repository.getWorkoutSummary();
    expect(result, isA<Left<Failure, WorkoutSummaryEntity>>());
  });
}
