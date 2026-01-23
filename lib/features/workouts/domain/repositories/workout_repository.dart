import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/exercise_entity.dart';
import '../entities/exercise_log_entity.dart';
import '../entities/workout_group_entity.dart';

abstract class WorkoutRepository {
  Future<Either<Failure, List<WorkoutGroupEntity>>> getWorkoutGroups(
    String userId,
  );
  Future<Either<Failure, WorkoutGroupEntity>> getWorkoutGroup(
    String userId,
    int groupId,
  );
  Future<Either<Failure, List<ExerciseEntity>>> getExercises();

  Future<Either<Failure, List<ExerciseLogEntity>>> getExerciseLogs(
    String userId,
    int exerciseId,
  );

  Future<Either<Failure, ExerciseLogEntity>> saveExerciseLog(
    ExerciseLogEntity log,
  );

  Future<Either<Failure, List<ExerciseLogEntity>>> getAllExerciseLogs(
    String userId,
  );
}
