import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/exercise_entity.dart';
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
  // Add other methods (create, delete, update) as we implement them
}
