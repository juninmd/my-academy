import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/exercise_log_entity.dart';
import '../../../../utils/one_rep_max_calculator.dart';

enum ChartMetric { oneRM, volume }

class ProgressChart extends HookWidget {
  const ProgressChart({
    required this.logs,
    this.metric = ChartMetric.oneRM,
    super.key,
  });

  final List<ExerciseLogEntity> logs;
  final ChartMetric metric;

  @override
  Widget build(BuildContext context) {
    if (logs.length < 2) return const SizedBox.shrink();

    // Process data
    final chartData = useMemoized(() {
      final points = <FlSpot>[];
      // Sort logs by date ascending
      final sortedLogs = List<ExerciseLogEntity>.from(logs)
        ..sort((a, b) => a.date.compareTo(b.date));

      for (int i = 0; i < sortedLogs.length; i++) {
        final log = sortedLogs[i];
        double value = 0;

        if (metric == ChartMetric.oneRM) {
          for (final set in log.sets) {
            final rm = OneRepMaxCalculator.calculateEpley(
              set.weight.toDouble(),
              set.reps,
            );
            if (rm > value) value = rm;
          }
        } else {
          // Volume calculation
          for (final set in log.sets) {
            value += set.weight * set.reps;
          }
        }

        if (value > 0) {
          points.add(FlSpot(i.toDouble(), value));
        }
      }
      return (sortedLogs: sortedLogs, points: points);
    }, [logs, metric]);

    final sortedLogs = chartData.sortedLogs;
    final points = chartData.points;

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
              horizontalInterval: metric == ChartMetric.volume ? 1000 : 10,
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
                  interval: metric == ChartMetric.volume ? null : 10,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    if (metric == ChartMetric.volume) {
                       if (value >= 1000) {
                         return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                       }
                    }
                    return Text(
                      '${value.toInt()}',
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
                  colors: [color.withValues(alpha: 0.5), color],
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
                    final val = metric == ChartMetric.volume
                        ? '${spot.y.toStringAsFixed(0)} kg'
                        : '${spot.y.toStringAsFixed(1)} kg';
                    return LineTooltipItem(
                      val,
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
