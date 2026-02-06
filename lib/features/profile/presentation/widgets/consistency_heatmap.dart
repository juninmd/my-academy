import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../workouts/domain/entities/exercise_log_entity.dart';

class ConsistencyHeatmap extends StatelessWidget {
  const ConsistencyHeatmap({
    required this.logs,
    this.daysToShow = 91, // ~3 months
    super.key,
  });

  final List<ExerciseLogEntity> logs;
  final int daysToShow;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Normalize today to midnight
    final today = DateTime(now.year, now.month, now.day);

    // Create a set of dates that have workouts
    final activeDates = logs.map((l) {
      return DateTime(l.date.year, l.date.month, l.date.day);
    }).toSet();

    // Calculate start date (ensure it aligns with Sunday/Monday if needed, but simple subtraction is fine for now)
    // We want to show weeks.
    // GitHub starts on Sunday.
    final startDate = today.subtract(Duration(days: daysToShow - 1));

    // Adjust startDate to the previous Sunday to align rows
    final weekdayOffset = startDate.weekday % 7; // Sunday=7->0, Mon=1
    final alignedStartDate = startDate.subtract(Duration(days: weekdayOffset));

    final totalDays = daysToShow + weekdayOffset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consistência',
              style: Theme.of(context).textTheme.titleMedium,
            ),
             Text(
              'Últimos 3 meses',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140, // 7 rows * (box + spacing)
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 Days a week
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemCount: totalDays,
            itemBuilder: (context, index) {
              final date = alignedStartDate.add(Duration(days: index));
              final isActive = activeDates.contains(date);
              final isFuture = date.isAfter(today);

              // Calculate intensity (optional, for now just binary)
              // If we had multiple workouts per day, we could darken.

              if (isFuture) return const SizedBox.shrink();

              return Tooltip(
                message: '${DateFormat('dd/MM/yyyy').format(date)}${isActive ? ': Treino realizado!' : ''}',
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: date == today
                       ? Border.all(color: Theme.of(context).colorScheme.secondary, width: 2)
                       : null,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Menos', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 4),
            _LegendBox(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            const SizedBox(width: 4),
            _LegendBox(color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text('Mais', style: Theme.of(context).textTheme.bodySmall),
          ],
        )
      ],
    );
  }
}

class _LegendBox extends StatelessWidget {
  const _LegendBox({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
