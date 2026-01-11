import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/workout_summary_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, WorkoutSummaryEntity>> getWorkoutSummary();
}
