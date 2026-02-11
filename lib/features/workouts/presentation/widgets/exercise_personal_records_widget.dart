import 'package:flutter/material.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../../../utils/one_rep_max_calculator.dart';

class ExercisePersonalRecordsWidget extends StatelessWidget {
  const ExercisePersonalRecordsWidget({required this.logs, super.key});

  final List<ExerciseLogEntity> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    double max1RM = 0;
    double maxWeight = 0;
    double maxVolume = 0;

    for (final log in logs) {
      double sessionVolume = 0;
      for (final set in log.sets) {
        // 1RM
        final rm = OneRepMaxCalculator.calculateEpley(
          set.weight.toDouble(),
          set.reps,
        );
        if (rm > max1RM) max1RM = rm;

        // Max Weight
        if (set.weight > maxWeight) maxWeight = set.weight.toDouble();

        // Volume Accumulation
        sessionVolume += set.weight * set.reps;
      }
      if (sessionVolume > maxVolume) maxVolume = sessionVolume;
    }

    if (max1RM == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Recordes Pessoais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RecordCard(
                  label: '1RM Estimado',
                  value: '${max1RM.toStringAsFixed(1)} kg',
                  icon: Icons.fitness_center,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RecordCard(
                  label: 'Carga Máxima',
                  value: '${maxWeight.toStringAsFixed(1)} kg',
                  icon: Icons.monitor_weight,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RecordCard(
                  label: 'Volume Máximo',
                  value: '${maxVolume.toStringAsFixed(0)} kg',
                  icon: Icons.bar_chart,
                  color: Colors.green,
                  subtitle: '(por sessão)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
        ],
      ),
    );
  }
}
