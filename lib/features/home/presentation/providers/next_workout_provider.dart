import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../calendar/data/repositories/calendar_repository.dart';
import '../../../workouts/domain/entities/workout_group_entity.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';

// Manual provider definition to avoid build_runner dependency for this task
final nextWorkoutProvider = FutureProvider.autoDispose<WorkoutGroupEntity?>((
  ref,
) async {
  final userAsync = ref.watch(authProvider);
  final user = userAsync.value;
  if (user == null) return null;

  // Watch workout groups
  final groupsAsync = await ref.watch(workoutGroupsProvider(user.id).future);
  if (groupsAsync.isEmpty) return null;
  final groups = groupsAsync; // Already list

  // Fetch recent sessions (this month)
  final now = DateTime.now();
  final currentSessions = await ref.watch(
    workoutSessionsProvider(user.id, now.month, now.year).future,
  );

  final sessions = [...currentSessions];

  // If no sessions this month, check last month
  if (sessions.isEmpty) {
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastYear = now.month == 1 ? now.year - 1 : now.year;
    // Note: workoutSessionsProvider is family, so we must invoke it
    final prevSessions = await ref.watch(
      workoutSessionsProvider(user.id, lastMonth, lastYear).future,
    );
    sessions.addAll(prevSessions);
  }

  if (sessions.isEmpty) {
    // No history, suggest the first workout
    return groups.first;
  }

  // Find the last completed session
  sessions.sort((a, b) => b.date.compareTo(a.date));
  final lastSession = sessions.first;

  // Find the group index
  final lastGroupIndex = groups.indexWhere(
    (g) => g.id == lastSession.workoutGroupId,
  );

  if (lastGroupIndex == -1) {
    // Group deleted or not found, suggest first
    return groups.first;
  }

  // Next group in cycle
  final nextIndex = (lastGroupIndex + 1) % groups.length;
  return groups[nextIndex];
});
