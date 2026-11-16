import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/pulse/pulse_card.dart';
import '../../../../workouts/presentation/providers/workout_create_provider.dart';
import '../../../../workouts/presentation/providers/workout_provider.dart';
import '../../../../workouts/presentation/widgets/workout_history_card.dart';

/// Última sessão registrada.
class LastWorkoutSection extends ConsumerWidget {
  const LastWorkoutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(allExerciseLogsProvider).value ?? const [];
    if (logs.isEmpty) return const SizedBox.shrink();
    final latest = logs.reduce((a, b) => a.date.isAfter(b.date) ? a : b).date;
    final session = logs
        .where(
          (e) =>
              e.date.year == latest.year &&
              e.date.month == latest.month &&
              e.date.day == latest.day,
        )
        .toList();
    final exercises = ref.watch(exercisesProvider).value;
    if (exercises == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PulseSectionLabel('Último treino'),
        const SizedBox(height: 10),
        WorkoutHistoryCard(
          date: latest,
          logs: session,
          exerciseNameMap: {for (final e in exercises) e.id: e.name},
        ),
      ],
    );
  }
}
