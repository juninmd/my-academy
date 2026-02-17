import 'package:flutter/material.dart';

class WeeklyGoalWidget extends StatelessWidget {
  const WeeklyGoalWidget({
    required this.completedDays,
    this.targetDays = 4,
    super.key,
  });

  final int completedDays;
  final int targetDays;

  @override
  Widget build(BuildContext context) {
    // Determine the color based on progress
    final progress = completedDays / targetDays;
    final progressColor =
        progress >= 1.0
            ? Colors.green
            : progress >= 0.5
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta Semanal',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$completedDays / $targetDays treinos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (progress > 1.0 ? 1.0 : progress),
              minHeight: 12,
              backgroundColor: Theme.of(
                context,
              ).disabledColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0
                ? 'Parabéns! Meta alcançada! 🎉'
                : 'Continue firme! Faltam ${targetDays - completedDays} treinos.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
