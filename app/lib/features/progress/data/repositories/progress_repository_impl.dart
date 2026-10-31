import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/muscle_overview_entity.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/muscle_overview_dto.dart';
import '../models/suggestion_dto.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, MuscleOverviewEntity>> getMuscleOverview(
    String userId, {
    int days = 90,
  }) async {
    try {
      final response = await _apiClient.get(
        'progress/muscles',
        queryParameters: {'userId': userId, 'days': days},
      );
      return Right(
        MuscleOverviewDto.fromJson(response as Map<String, dynamic>),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SuggestionEntity?>> getSuggestion(
    String userId,
    int exerciseId,
  ) async {
    try {
      final response = await _apiClient.get(
        'progress/exercises/$exerciseId/suggestion',
        queryParameters: {'userId': userId},
      );
      return Right(
        SuggestionDto.fromResponse(response as Map<String, dynamic>),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getCoachAdvice(
    String userId, {
    int days = 30,
  }) async {
    try {
      final response = await _apiClient.post(
        'coach/advice',
        data: {'userId': userId, 'days': days},
      );
      return Right((response as Map<String, dynamic>)['advice'] as String);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
