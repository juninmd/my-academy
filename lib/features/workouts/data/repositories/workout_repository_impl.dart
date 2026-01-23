import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../utils/constants.dart';
import '../../domain/entities/workout_group_entity.dart';
import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../domain/repositories/workout_repository.dart';

// Helper to map dynamic JSON to Entities (simplified for now, ideally strictly typed DTOs)
class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<WorkoutGroupEntity>>> getWorkoutGroups(
    String userId,
  ) async {
    try {
      final response = await _apiClient.get('workouts-groups/user/$userId');
      final List<dynamic> data = response;

      final groups = data.cast<Map<String, dynamic>>().map(_mapGroup).toList();
      return Right(groups);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutGroupEntity>> getWorkoutGroup(
    String userId,
    int groupId,
  ) async {
    try {
      final response = await _apiClient.get(
        'workouts-groups/$groupId',
      );
      return Right(_mapGroup(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseEntity>>> getExercises() async {
    try {
      final response = await _apiClient.get('exercises');
      final List<dynamic> data = response;
      return Right(
        data.cast<Map<String, dynamic>>().map(_mapExercise).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseLogEntity>>> getExerciseLogs(
    String userId,
    int exerciseId,
  ) async {
    try {
      final response = await _apiClient.get(
        'exercise-logs?userId=$userId&exerciseId=$exerciseId&_sort=date&_order=desc',
      );
      final List<dynamic> data = response;
      return Right(
        data
            .cast<Map<String, dynamic>>()
            .map(ExerciseLogEntity.fromJson)
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExerciseLogEntity>> saveExerciseLog(
    ExerciseLogEntity log,
  ) async {
    try {
      final response = await _apiClient.post('exercise-logs', data: log.toJson());
      return Right(ExerciseLogEntity.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseLogEntity>>> getAllExerciseLogs(
    String userId,
  ) async {
    try {
      final response = await _apiClient.get(
        'exercise-logs?userId=$userId&_sort=date&_order=desc',
      );
      final List<dynamic> data = response;
      return Right(
        data
            .cast<Map<String, dynamic>>()
            .map(ExerciseLogEntity.fromJson)
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  WorkoutGroupEntity _mapGroup(Map<String, dynamic> json) => WorkoutGroupEntity(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    userId: json['userId'],
    workouts:
        json['workouts'] != null
            ? (json['workouts'] as List)
                .cast<Map<String, dynamic>>()
                .map(_mapWorkout)
                .toList()
            : [],
  );

  WorkoutEntity _mapWorkout(Map<String, dynamic> json) => WorkoutEntity(
    id: json['id'],
    exerciseId: json['exerciseId'],
    description: json['description'],
    exercise: json['exercise'] != null ? _mapExercise(json['exercise']) : null,
    // map series...
  );

  ExerciseEntity _mapExercise(Map<String, dynamic> json) => ExerciseEntity(
    id: json['id'],
    name: json['name'],
    image: json['image'],
    description: json['description'],
    tips:
        json['tips'] != null
            ? (json['tips'] as String).split(',')
            : [], // Legacy string split
    mistakes:
        json['mistakes'] != null ? (json['mistakes'] as String).split(',') : [],
  );
}
