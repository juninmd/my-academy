import 'package:flutter/material.dart';

import '../../../../core/widgets/common_empty_state.dart';
import '../../domain/entities/gym_entities.dart';
import 'plan_form_dialog.dart';
import 'status_chip.dart';

class GymPlansTab extends StatelessWidget {
  const GymPlansTab({required this.gym, super.key});
  final GymEntity gym;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed:
                  () => showDialog<void>(
                    context: context,
                    builder: (_) => PlanFormDialog(gymId: gym.id),
                  ),
              icon: const Icon(Icons.add),
              label: const Text('Novo plano'),
            ),
          ),
        ),
        if (gym.plans.isEmpty)
          const CommonEmptyState(
            icon: Icons.sell_outlined,
            title: 'Nenhum plano',
            message: 'Crie planos para poder matricular alunos.',
          ),
        for (final plan in gym.plans)
          ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: Text(plan.name),
            subtitle: Text(
              plan.durationMonths == 1
                  ? '1 mês'
                  : '${plan.durationMonths} meses',
            ),
            trailing: Text(
              brl.format(plan.price),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
      ],
    );
  }
}
