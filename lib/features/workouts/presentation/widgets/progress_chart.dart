import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/exercise_log_entity.dart';
import '../../../../utils/one_rep_max_calculator.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({required this.logs, super.key});

  final List<ExerciseLogEntity> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.length < 2) return const SizedBox.shrink();

    // Process data
    final points = <FlSpot>[];
    // Sort logs by date ascending
    final sortedLogs = List<ExerciseLogEntity>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i < sortedLogs.length; i++) {
      final log = sortedLogs[i];
      double max1RM = 0;
      for (final set in log.sets) {
        final rm = OneRepMaxCalculator.calculateEpley(
          set.weight.toDouble(),
          set.reps,
        );
        if (rm > max1RM) max1RM = rm;
      }
      if (max1RM > 0) {
        points.add(FlSpot(i.toDouble(), max1RM));
      }
    }

    if (points.isEmpty) return const SizedBox.shrink();

    final color = Theme.of(context).colorScheme.primary;

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 10,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < sortedLogs.length) {
                      // Logic to avoid overcrowding labels
                      // Show first, last, and every ~3rd if many
                      if (sortedLogs.length > 5 &&
                          index != 0 &&
                          index != sortedLogs.length - 1 &&
                          index % (sortedLogs.length ~/ 3) != 0) {
                        return const SizedBox.shrink();
                      }
                      final date = sortedLogs[index].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd/MM').format(date),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}kg',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: points,
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.5),
                    color,
                  ],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} kg',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
