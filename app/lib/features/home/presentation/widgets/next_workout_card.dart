import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../workouts/domain/entities/workout_group_entity.dart';
import 'pulse_hero_card.dart';

/// Sugestão do próximo treino da sequência.
class NextWorkoutCard extends StatelessWidget {
  const NextWorkoutCard({required this.workoutGroup, super.key});

  final WorkoutGroupEntity workoutGroup;

  @override
  Widget build(BuildContext context) {
    final count = workoutGroup.workouts.length;
    return PulseHeroCard(
      eyebrow: 'Próximo na sequência',
      tag: 'Sugestão',
      title: workoutGroup.name,
      subtitle: '$count ${count == 1 ? 'exercício' : 'exercícios'}',
      actionLabel: 'Ver treino',
      onAction: () => context.go('/workouts/${workoutGroup.id}'),
    );
  }
}
