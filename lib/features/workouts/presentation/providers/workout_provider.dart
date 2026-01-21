import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/exercise_log_entity.dart';
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

// Manually defined to ensure availability without running build_runner
final exerciseLogsProvider = FutureProvider.family.autoDispose<List<ExerciseLogEntity>, int>((ref, exerciseId) async {
  final userAsync = ref.watch(authProvider);
  final user = userAsync.value;
  if (user == null) {
    return [];
  }
  final repository = ref.watch(workoutRepositoryProvider);
  final result = await repository.getExerciseLogs(user.id, exerciseId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (logs) => logs,
  );
});

// Manually defined provider to avoid generation issues if present,
// and to match the implementation expected by other files if generation is skipped.
// Also moving the `workoutGroupByIdProvider` here to be shared.
final workoutGroupByIdProvider = FutureProvider.family
    .autoDispose<WorkoutGroupEntity?, int>((ref, groupId) async {
  final user = ref.watch(authProvider).value;
  if (user == null) throw Exception('User not logged in');

  // This relies on the workoutGroups provider which fetches all groups.
  // Ideally this should fetch a single group from API if possible.
  final allGroups = await ref.watch(workoutGroupsProvider(user.id).future);
  try {
    return allGroups.firstWhere((g) => g.id == groupId);
  } catch (_) {
    return null;
  }
});
