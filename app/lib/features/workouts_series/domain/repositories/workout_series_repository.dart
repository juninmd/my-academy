import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/workout_series_entity.dart';

abstract class WorkoutSeriesRepository {
  Future<Either<Failure, List<WorkoutSeriesEntity>>> getWorkoutSeries();
  Future<Either<Failure, WorkoutSeriesEntity>> getWorkoutSeriesById(int id);
  Future<Either<Failure, WorkoutSeriesEntity>> createWorkoutSeries(WorkoutSeriesEntity series);
  Future<Either<Failure, WorkoutSeriesEntity>> updateWorkoutSeries(WorkoutSeriesEntity series);
  Future<Either<Failure, Unit>> deleteWorkoutSeries(int id);
}
