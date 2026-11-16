import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/pulse_tokens.dart';
import '../../../../../core/widgets/pulse/pulse_card.dart';
import '../../../../workouts/domain/entities/workout_group_entity.dart';

class PlanTile extends StatelessWidget {
  const PlanTile({
    required this.plan,
    required this.template,
    required this.onTap,
    super.key,
  });

  final WorkoutGroupEntity plan;
  final bool template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = plan.workouts.length;
    return SizedBox(
      width: 168,
      child: PulseCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: template ? scheme.secondaryContainer : scheme.primary,
                borderRadius: BorderRadius.circular(PulseRadii.pill),
              ),
              child: Text(
                template ? 'TEMPLATE' : 'PLANO',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: template
                      ? scheme.onSecondaryContainer
                      : scheme.onPrimary,
                ),
              ),
            ),
            const Spacer(),
            Text(
              plan.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              template ? '$count exercícios' : '$count treinos',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class NewPlanTile extends StatelessWidget {
  const NewPlanTile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 120,
      child: PulseCard(
        onTap: () => context.push('/workouts/create'),
        color: scheme.surfaceContainerLow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: scheme.primary),
            const SizedBox(height: 8),
            const Text('Criar Novo'),
          ],
        ),
      ),
    );
  }
}
