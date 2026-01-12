import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/workout_group_entity.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'workout_provider.g.dart';

@riverpod
WorkoutRepository workoutRepository(Ref ref) =>
    WorkoutRepositoryImpl(ref.watch(apiClientProvider));

@riverpod
Future<List<WorkoutGroupEntity>> workoutGroups(
  Ref ref,
  String userId,
) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final result = await repository.getWorkoutGroups(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (groups) => groups,
  );
}
