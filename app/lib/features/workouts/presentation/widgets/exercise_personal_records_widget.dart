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
    DateTime? max1RMDate;

    double maxWeight = 0;
    DateTime? maxWeightDate;

    double maxVolume = 0;
    DateTime? maxVolumeDate;

    for (final log in logs) {
      double sessionVolume = 0;
      for (final set in log.sets) {
        // 1RM
        final rm = OneRepMaxCalculator.calculateEpley(
          set.weight.toDouble(),
          set.reps,
        );
        if (rm > max1RM) {
          max1RM = rm;
          max1RMDate = log.date;
        }

        // Max Weight
        if (set.weight > maxWeight) {
          maxWeight = set.weight.toDouble();
          maxWeightDate = log.date;
        }

        // Volume Accumulation
        sessionVolume += set.weight * set.reps;
      }
      if (sessionVolume > maxVolume) {
        maxVolume = sessionVolume;
        maxVolumeDate = log.date;
      }
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
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 20,
                ),
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
                  date: max1RMDate,
                  icon: Icons.fitness_center,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RecordCard(
                  label: 'Carga Máxima',
                  value: '${maxWeight.toStringAsFixed(1)} kg',
                  date: maxWeightDate,
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
                  date: maxVolumeDate,
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
    this.date,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final DateTime? date;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isNew = date != null && DateTime.now().difference(date!).inDays < 7;
    final dateStr =
        date != null ? '${date!.day}/${date!.month}/${date!.year}' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isNew
                  ? color.withValues(alpha: 0.5)
                  : Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: isNew ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isNew
                    ? color.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
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
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isNew)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NOVO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                    fontSize: 10,
                  ),
                ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
