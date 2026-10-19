import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../workouts/presentation/providers/workout_provider.dart';

class RecentProgressChart extends ConsumerWidget {
  const RecentProgressChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allExerciseLogsProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);

        // Calculate daily volume for the last 7 days
        final List<double> dailyVolumes = List.filled(7, 0.0);

        for (final log in logs) {
          final logDate = DateTime(log.date.year, log.date.month, log.date.day);
          final diff = startOfToday.difference(logDate).inDays;

          if (diff >= 0 && diff < 7) {
            double volume = 0;
            for (final set in log.sets) {
              volume += set.weight * set.reps;
            }
            dailyVolumes[6 - diff] += volume;
          }
        }

        final maxVolume = dailyVolumes.reduce((a, b) => a > b ? a : b);
        if (maxVolume == 0) {
          return const SizedBox.shrink(); // No activity in last 7 days
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso Recente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context).colorScheme.surface,
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
                    Text(
                      'Volume de Treino (kg)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxVolume * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor:
                                  (_) =>
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                              tooltipBorderRadius: BorderRadius.circular(8),
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} kg',
                                  TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date = startOfToday.subtract(
                                    Duration(days: 6 - value.toInt()),
                                  );
                                  final isToday = value.toInt() == 6;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      isToday
                                          ? 'Hoje'
                                          : DateFormat('E', 'pt_BR')
                                              .format(date)
                                              .substring(0, 3)
                                              .toUpperCase(),
                                      style: TextStyle(
                                        color:
                                            isToday
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        fontWeight:
                                            isToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 28,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: dailyVolumes[index],
                                  color:
                                      index == 6
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.5),
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
