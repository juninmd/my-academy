import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/pulse/pulse_card.dart';
import '../../../../../core/widgets/pulse/pulse_ring.dart';
import '../../providers/dashboard_stats_provider.dart';

/// Meta semanal em anel + volume e sequência.
class WeeklyPulseCard extends StatelessWidget {
  const WeeklyPulseCard({required this.stats, super.key});

  final DashboardStats stats;

  static String formatVolume(double kg) =>
      kg > 1000 ? '${(kg / 1000).toStringAsFixed(1)}k' : kg.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = stats.weeklyGoal <= 0 ? 1 : stats.weeklyGoal;
    final progress = stats.workoutsThisWeek / goal;
    final hit = stats.workoutsThisWeek >= goal;
    return PulseCard(
      onTap: () => context.go('/analytics'),
      child: Row(
        children: [
          PulseRing(
            value: progress,
            size: 92,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stats.workoutsThisWeek}/${stats.weeklyGoal}',
                  style: theme.textTheme.titleLarge,
                ),
                Text('Treinos', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hit ? 'Meta da semana batida' : 'Meta da semana',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        label: 'Volume',
                        value: '${formatVolume(stats.volumeThisWeek)} kg',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        label: 'Sequência',
                        value: '${stats.streak} dias',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.bodySmall),
        Text(value, style: text.titleLarge),
      ],
    );
  }
}
