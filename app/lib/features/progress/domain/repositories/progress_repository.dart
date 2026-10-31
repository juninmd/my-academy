import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/muscle_overview_entity.dart';

abstract class ProgressRepository {
  Future<Either<Failure, MuscleOverviewEntity>> getMuscleOverview(
    String userId, {
    int days = 90,
  });
}
