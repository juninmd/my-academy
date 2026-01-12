import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/workout_summary_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._dataSource);
  final HomeRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, WorkoutSummaryEntity>> getWorkoutSummary() async {
    try {
      final summary = await _dataSource.getWorkoutSummary();
      return Right(summary);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
