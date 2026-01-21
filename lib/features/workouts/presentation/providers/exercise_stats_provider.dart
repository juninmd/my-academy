import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'workout_provider.dart';

// Manual provider to avoid build_runner dependency for new code
final exerciseStatsProvider = FutureProvider.family.autoDispose<List<ExerciseLogEntity>, int>((ref, exerciseId) async {
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
