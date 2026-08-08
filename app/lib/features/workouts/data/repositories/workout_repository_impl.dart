import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/workout_group_entity.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../domain/entities/session_log_entity.dart';
import '../../domain/repositories/workout_repository.dart';
import '../models/workout_group_dto.dart';
import '../models/exercise_dto.dart';
import '../models/exercise_log_dto.dart';
import '../models/workout_dto.dart';

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

      final groups =
          data
              .cast<Map<String, dynamic>>()
              .map((json) => WorkoutGroupDto.fromJson(json).toEntity())
              .toList();

      final box = Hive.box('workouts');
      await box.put('groups_$userId', jsonEncode(data));

      return Right(groups);
    } catch (e) {
      try {
        final box = Hive.box('workouts');
        final cachedData = box.get('groups_$userId');
        if (cachedData != null) {
          final List<dynamic> data = jsonDecode(cachedData as String);
          final groups =
              data
                  .cast<Map<String, dynamic>>()
                  .map((json) => WorkoutGroupDto.fromJson(json).toEntity())
                  .toList();
          return Right(groups);
        }
      } catch (_) {}
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutGroupEntity>> getWorkoutGroup(
    String userId,
    int groupId,
  ) async {
    try {
      final response = await _apiClient.get('workouts-groups/$groupId');
      final data = response as Map<String, dynamic>;
      return Right(WorkoutGroupDto.fromJson(data).toEntity());
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
        data
            .cast<Map<String, dynamic>>()
            .map((json) => ExerciseDto.fromJson(json).toEntity())
            .toList(),
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
        'exercise-logs',
        queryParameters: {
          'userId': userId,
          'exerciseId': exerciseId.toString(),
        },
      );
      final List<dynamic> data = response;
      return Right(
        data
            .cast<Map<String, dynamic>>()
            .map((json) => ExerciseLogDto.fromJson(json).toEntity())
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
      final logDto = ExerciseLogDto.fromEntity(log);
      final response = await _apiClient.post(
        'exercise-logs',
        data: logDto.toJson(),
      );
      return Right(
        ExerciseLogDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
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
        'exercise-logs',
        queryParameters: {'userId': userId},
        options: Options(responseType: ResponseType.plain),
      );
      final String jsonString = response as String;

      final box = Hive.box('exercise_logs');
      await box.put('logs_$userId', jsonString);

      final logs = await compute(_parseExerciseLogs, jsonString);
      return Right(logs);
    } catch (e) {
      try {
        final box = Hive.box('exercise_logs');
        final cachedData = box.get('logs_$userId');
        if (cachedData != null) {
          final logs = await compute(_parseExerciseLogs, cachedData as String);
          return Right(logs);
        }
      } catch (_) {}
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutGroupEntity>> createWorkoutGroup(
    WorkoutGroupEntity group,
  ) async {
    try {
      final dto = WorkoutGroupDto.fromEntity(group);

      final Map<String, dynamic> json = {
        'name': dto.name,
        if (dto.image != null) 'image': dto.image,
        'userId': dto.userId,
        'workouts': dto.workouts.map(_mapWorkoutDtoToJsonForCreate).toList(),
      };

      final response = await _apiClient.post('workouts-groups', data: json);
      return Right(
        WorkoutGroupDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutGroupEntity>> updateWorkoutGroup(
    WorkoutGroupEntity group,
  ) async {
    try {
      final dto = WorkoutGroupDto.fromEntity(group);

      final Map<String, dynamic> json = {
        'name': dto.name,
        if (dto.image != null) 'image': dto.image,
        'userId': dto.userId,
        'workouts': dto.workouts.map(_mapWorkoutDtoToJsonForUpdate).toList(),
      };

      final response = await _apiClient.put(
        'workouts-groups/${group.id}',
        data: json,
      );
      return Right(
        WorkoutGroupDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWorkoutGroup(int groupId) async {
    try {
      await _apiClient.delete('workouts-groups/$groupId');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveWorkoutSession(
    int workoutGroupId,
    DateTime date,
    Map<int, ExerciseSessionLog> sessionLogs,
  ) async {
    try {
      final workoutsData =
          sessionLogs.values.map((log) {
            return {
              'exerciseId': log.exerciseId,
              'notes': log.notes,
              'sets':
                  log.setLogs.values
                      .map(
                        (s) => {
                          'reps': s.actualReps,
                          'weight': s.actualWeight,
                          'rpe': s.rpe,
                          'type': s.type.name,
                        },
                      )
                      .toList(),
            };
          }).toList();

      await _apiClient.post(
        'workouts-sessions',
        data: {
          'workoutGroupId': workoutGroupId,
          'date': date.toIso8601String(),
          'workouts': workoutsData,
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Map<String, dynamic> _mapWorkoutDtoToJsonForCreate(WorkoutDto workout) {
    return {
      'exerciseId': workout.exerciseId,
      if (workout.methodId != null) 'methodId': workout.methodId,
      if (workout.description != null) 'description': workout.description,
      'workoutSeries': workout.series.map((s) => s.toJson()).toList(),
    };
  }

  Map<String, dynamic> _mapWorkoutDtoToJsonForUpdate(WorkoutDto workout) {
    return {
      if (workout.id != null) 'id': workout.id,
      'exerciseId': workout.exerciseId,
      if (workout.methodId != null) 'methodId': workout.methodId,
      if (workout.description != null) 'description': workout.description,
      'workoutSeries': workout.series.map((s) => s.toJson()).toList(),
    };
  }
}

List<ExerciseLogEntity> _parseExerciseLogs(String jsonString) {
  final List<dynamic> data = jsonDecode(jsonString);
  return data
      .cast<Map<String, dynamic>>()
      .map((json) => ExerciseLogDto.fromJson(json).toEntity())
      .toList();
}
