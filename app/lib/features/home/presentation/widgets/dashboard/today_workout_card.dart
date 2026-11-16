import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../workouts/domain/utils/muscle_group_mapper.dart';
import '../../../domain/entities/workout_summary_entity.dart';
import '../pulse_hero_card.dart';

/// Treino programado para hoje.
class TodayWorkoutCard extends StatelessWidget {
  const TodayWorkoutCard({required this.summary, super.key});

  final WorkoutSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final name = summary.workoutName ?? 'Treino Personalizado';
    final muscle = MuscleGroupMapper.getMuscleGroup(name);
    final groupId = summary.workoutGroupId;
    return PulseHeroCard(
      eyebrow: 'Treino de hoje',
      tag: muscle == 'Outros' ? null : muscle,
      title: name,
      subtitle: summary.personalName == null
          ? 'Sessão programada'
          : 'Prescrito por ${summary.personalName}',
      actionLabel: 'Iniciar agora',
      onAction: () {
        if (groupId != null) context.go('/workouts/$groupId');
      },
    );
  }
}
