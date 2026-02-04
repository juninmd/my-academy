import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/exercise_log_entity.dart';

class WorkoutHistoryCard extends StatelessWidget {
  const WorkoutHistoryCard({
    required this.date,
    required this.logs,
    required this.exerciseNameMap,
    super.key,
  });

  final DateTime date;
  final List<ExerciseLogEntity> logs;
  final Map<int, String> exerciseNameMap;

  @override
  Widget build(BuildContext context) {
    // Calculate Stats
    int totalSets = 0;
    double totalVolume = 0;

    for (final log in logs) {
      totalSets += log.sets.length;
      for (final set in log.sets) {
        totalVolume += set.weight * set.reps;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd').format(date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'pt_BR').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE', 'pt_BR').format(date).capitalize(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.fitness_center, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${(totalVolume / 1000).toStringAsFixed(1)}t Vol',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.repeat, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '$totalSets Sets',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Exercise List
            ...logs.map((log) {
               final name = exerciseNameMap[log.exerciseId] ?? 'Exercício ${log.exerciseId}';
               // Find best set
               double maxWeight = 0;
               for (var s in log.sets) {
                 if (s.weight > maxWeight) {
                   maxWeight = s.weight.toDouble();
                 }
               }

               return Padding(
                 padding: const EdgeInsets.symmetric(vertical: 4),
                 child: Row(
                   children: [
                     Expanded(
                       child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                     ),
                     Text(
                       '${log.sets.length} x ',
                       style: const TextStyle(color: Colors.grey, fontSize: 12),
                     ),
                     Text(
                       '${maxWeight.toInt()}kg',
                       style: const TextStyle(fontWeight: FontWeight.bold),
                     ),
                   ],
                 ),
               );
            }),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
