import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
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
      final response = await _apiClient.post(
        'exercise-logs',
        data: log.toJson(),
      );
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

  @override
  Future<Either<Failure, WorkoutGroupEntity>> createWorkoutGroup(
    WorkoutGroupEntity group,
  ) async {
    try {
      // Ensure we don't send ID for creation if it's auto-generated
      final Map<String, dynamic> json = {
        'name': group.name,
        'image': group.image,
        'userId': group.userId,
        'workouts': group.workouts.map(_mapWorkoutToJson).toList(),
      };

      final response = await _apiClient.post('workout-groups', data: json);
      return Right(_mapGroup(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutGroupEntity>> updateWorkoutGroup(
    WorkoutGroupEntity group,
  ) async {
    try {
       final Map<String, dynamic> json = {
        'name': group.name,
        'image': group.image,
        'userId': group.userId,
        'workouts': group.workouts.map(_mapWorkoutToJson).toList(),
      };

      final response = await _apiClient.put(
        'workout-groups/${group.id}',
        data: json,
      );
      return Right(_mapGroup(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWorkoutGroup(int groupId) async {
    try {
      await _apiClient.delete('workout-groups/$groupId');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Map<String, dynamic> _mapWorkoutToJson(WorkoutEntity workout) {
     return {
        // preserve ID if it exists, otherwise backend handles it?
        // usually for nested relations, if we want to update, we send ID.
        // if we want to create, no ID.
        if (workout.id != null) 'id': workout.id,
        'exerciseId': workout.exerciseId,
        'description': workout.description,
        'series': workout.series.map((s) => {
           'repetitions': s.repetitions,
           'weight': s.weight,
           'rest': s.rest,
        }).toList(),
     };
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
