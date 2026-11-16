import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/pulse/pulse_card.dart';
import '../../../../../core/widgets/pulse/pulse_entrance.dart';
import '../../../../workouts/domain/entities/workout_group_entity.dart';
import '../../../../workouts/presentation/providers/workout_create_provider.dart';
import '../../../../workouts/presentation/providers/workout_provider.dart';
import '../../../domain/starter_plans.dart';
import 'plan_tile.dart';

/// Seus planos (ou modelos iniciais) em carrossel horizontal.
class PlansCarousel extends ConsumerWidget {
  const PlansCarousel({required this.userId, super.key});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = userId != null
        ? ref.watch(workoutGroupsProvider(userId!))
        : const AsyncValue<List<WorkoutGroupEntity>>.data([]);
    final exercises = ref.watch(exercisesProvider);

    Widget list(List<WorkoutGroupEntity> plans, {required bool template}) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: plans.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i == plans.length) return const NewPlanTile().pulseIn(i);
          final plan = plans[i];
          return PlanTile(
            plan: plan,
            template: template,
            onTap: () {
              if (template) {
                ref.read(workoutCreateProvider.notifier).loadGroup(plan);
                context.push('/workouts/create');
              } else {
                context.go('/workouts/${plan.id}');
              }
            },
          ).pulseIn(i);
        },
      );
    }

    final body = groupsAsync.when(
      data: (groups) {
        if (groups.isNotEmpty) return list(groups, template: false);
        final starters = StarterPlans.getPlans(exercises.value ?? const []);
        if (starters.isEmpty) {
          return Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/workouts/create'),
              icon: const Icon(Icons.add),
              label: const Text('Criar Novo Plano'),
            ),
          );
        }
        return list(starters, template: true);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PulseSectionLabel('Seus planos'),
        const SizedBox(height: 10),
        SizedBox(height: 148, child: body),
      ],
    );
  }
}
