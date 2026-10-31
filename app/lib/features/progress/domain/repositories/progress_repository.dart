import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/muscle_overview_entity.dart';
import '../entities/suggestion_entity.dart';

abstract class ProgressRepository {
  Future<Either<Failure, MuscleOverviewEntity>> getMuscleOverview(
    String userId, {
    int days = 90,
  });

  /// Null when the exercise has no history yet.
  Future<Either<Failure, SuggestionEntity?>> getSuggestion(
    String userId,
    int exerciseId,
  );

  /// Text advice from the server's AI coach. Fails with 503 when the coach is off.
  Future<Either<Failure, String>> getCoachAdvice(
    String userId, {
    int days = 30,
  });
}
