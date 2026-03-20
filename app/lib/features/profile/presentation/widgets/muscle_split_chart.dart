import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../workouts/domain/entities/exercise_entity.dart';
import '../../../workouts/domain/entities/exercise_log_entity.dart';
import '../../../workouts/domain/utils/muscle_group_mapper.dart';

class MuscleSplitChart extends StatelessWidget {
  const MuscleSplitChart({
    required this.logs,
    required this.exercises,
    super.key,
  });

  final List<ExerciseLogEntity> logs;
  final List<ExerciseEntity> exercises;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    // 1. Filter logs (last 30 days)
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentLogs =
        logs.where((l) => l.date.isAfter(thirtyDaysAgo)).toList();

    if (recentLogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Sem dados nos últimos 30 dias')),
      );
    }

    // 2. Map to Muscle Groups and Count Sets
    final distribution = <String, int>{};
    int totalSets = 0;

    for (final log in recentLogs) {
      final exercise =
          exercises.where((e) => e.id == log.exerciseId).firstOrNull;
      if (exercise == null) continue;

      final group = MuscleGroupMapper.getMuscleGroup(exercise.name);
      final setCheck = log.sets.length;

      distribution[group] = (distribution[group] ?? 0) + setCheck;
      totalSets += setCheck;
    }

    if (totalSets == 0) return const SizedBox.shrink();

    // 3. Create Pie Chart Sections
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int colorIndex = 0;

    // Sort by count descending
    final sortedEntries =
        distribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      final percentage = (entry.value / totalSets) * 100;
      final isLarge = percentage > 10;

      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(0)}%',
          radius: isLarge ? 60 : 50,
          titleStyle: TextStyle(
            fontSize: isLarge ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      );
      colorIndex++;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Divisão Muscular (30 dias)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event,
                            pieTouchResponse,
                          ) {
                            // Handle touch if needed
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: sections,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        sortedEntries.map((entry) {
                          final index = sortedEntries.indexOf(entry);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors[index % colors.length],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
