import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gym_providers.dart';
import 'status_chip.dart';

class GymKpis extends ConsumerWidget {
  const GymKpis({required this.gymId, super.key});
  final int gymId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(gymDashboardProvider(gymId)).value;
    final scheme = Theme.of(context).colorScheme;
    final tiles = [
      (
        'Alunos ativos',
        '${kpis?.activeMembers ?? '–'}',
        Icons.groups,
        scheme.primary,
      ),
      (
        'Receita do mês',
        kpis == null ? '–' : brl.format(kpis.revenueThisMonth),
        Icons.payments_outlined,
        Colors.green,
      ),
      (
        'Pendentes',
        '${kpis?.pendingPayments ?? '–'}',
        Icons.schedule,
        Colors.amber.shade800,
      ),
      (
        'Atrasados',
        '${kpis?.overduePayments ?? '–'}',
        Icons.error_outline,
        scheme.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (label, value, icon, color) in tiles)
              SizedBox(
                width: width,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: color),
                        const SizedBox(height: 8),
                        Text(
                          value,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
