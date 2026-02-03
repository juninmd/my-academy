import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/exercise_log_entity.dart';
import '../providers/workout_provider.dart';
import '../providers/workout_create_provider.dart';

class WorkoutHistoryPage extends ConsumerWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogsAsync = ref.watch(allExerciseLogsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Treinos'),
      ),
      body: allLogsAsync.when(
        data: (logs) {
          // Create exercise map for lookup
          final exerciseMap = <int, String>{};
          if (exercisesAsync.hasValue) {
            final exercises = exercisesAsync.value;
            if (exercises != null) {
              for (final ex in exercises) {
                exerciseMap[ex.id] = ex.name;
              }
            }
          }
          if (logs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum treino registrado ainda.'),
                ],
              ),
            );
          }

          // Group logs by Date
          final groupedLogs = <DateTime, List<ExerciseLogEntity>>{};
          for (final log in logs) {
            final date = DateTime(
              log.date.year,
              log.date.month,
              log.date.day,
            );
            if (!groupedLogs.containsKey(date)) {
              groupedLogs[date] = [];
            }
            groupedLogs[date]!.add(log);
          }

          // Sort dates descending
          final sortedDates = groupedLogs.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateLogs = groupedLogs[date]!;

              // Calculate stats
              final uniqueExercises = dateLogs.map((e) => e.exerciseId).toSet().length;
              int totalSets = 0;
              double totalVolume = 0;

              for (final log in dateLogs) {
                totalSets += log.sets.length;
                for (final set in log.sets) {
                  totalVolume += (set.weight * set.reps);
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      DateFormat('dd').format(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    DateFormat('EEEE, d ' 'de' ' MMMM', 'pt_BR').format(date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$uniqueExercises exercícios • $totalSets séries • ${totalVolume.toStringAsFixed(0)} kg',
                  ),
                  children: dateLogs.map((log) {
                    // We don't have the Exercise Name here easily unless we fetch it or it's in the entity
                    // The entity usually has just ID. We might need to fetch names or just show ID/Stats.
                    // Checking entity definition: ExerciseLogEntity usually just has ID.
                    // However, for a history list, just showing volume/sets is okay for now.
                    // Or we can try to assume we have a way to get name.
                    // For now, let's show detailed stats.

                    double logVolume = 0;
                    for (var s in log.sets) {
                      logVolume += s.weight * s.reps;
                    }

                    final exerciseName = exerciseMap[log.exerciseId] ?? 'Exercício #${log.exerciseId}';

                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.fitness_center, size: 16),
                      title: Text(exerciseName),
                      subtitle: Text('${log.sets.length} séries • Vol: ${logVolume.toStringAsFixed(0)} kg'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
