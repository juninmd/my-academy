import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/workout_series_entity.dart';
import '../../domain/repositories/workout_series_repository.dart';
import '../models/workout_series_dto.dart';

part 'workout_series_repository_impl.g.dart';

class WorkoutSeriesRepositoryImpl implements WorkoutSeriesRepository {
  WorkoutSeriesRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<WorkoutSeriesEntity>>> getWorkoutSeries() async {
    try {
      final response = await _apiClient.get('workouts-series');
      final List<dynamic> data = response;
      return Right(
        data
            .cast<Map<String, dynamic>>()
            .map((json) => WorkoutSeriesDto.fromJson(json).toEntity())
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSeriesEntity>> getWorkoutSeriesById(
    int id,
  ) async {
    try {
      final response = await _apiClient.get('workouts-series/$id');
      final data = response as Map<String, dynamic>;
      return Right(WorkoutSeriesDto.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSeriesEntity>> createWorkoutSeries(
    WorkoutSeriesEntity series,
  ) async {
    try {
      final dto = WorkoutSeriesDto.fromEntity(series);
      final response = await _apiClient.post(
        'workouts-series',
        data: dto.toJson(),
      );
      return Right(
        WorkoutSeriesDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSeriesEntity>> updateWorkoutSeries(
    WorkoutSeriesEntity series,
  ) async {
    try {
      final dto = WorkoutSeriesDto.fromEntity(series);
      final response = await _apiClient.patch(
        'workouts-series/${series.id}',
        data: dto.toJson(),
      );
      return Right(
        WorkoutSeriesDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWorkoutSeries(int id) async {
    try {
      await _apiClient.delete('workouts-series/$id');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

@riverpod
WorkoutSeriesRepository workoutSeriesRepository(Ref ref) {
  return WorkoutSeriesRepositoryImpl(ref.watch(apiClientProvider));
}

@riverpod
Future<List<WorkoutSeriesEntity>> workoutSeries(Ref ref) async {
  final repository = ref.watch(workoutSeriesRepositoryProvider);
  final result = await repository.getWorkoutSeries();
  return result.fold((failure) => [], (list) => list);
}

@riverpod
Future<WorkoutSeriesEntity?> workoutSeriesById(Ref ref, int id) async {
  final repository = ref.watch(workoutSeriesRepositoryProvider);
  final result = await repository.getWorkoutSeriesById(id);
  return result.fold((failure) => null, (series) => series);
}
