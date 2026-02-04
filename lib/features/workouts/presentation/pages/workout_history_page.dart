import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../providers/workout_provider.dart';
import '../providers/workout_create_provider.dart';
import '../widgets/workout_history_card.dart';

class WorkoutHistoryPage extends ConsumerWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogsAsync = ref.watch(allExerciseLogsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Treinos'),
        centerTitle: true,
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

              return WorkoutHistoryCard(
                date: date,
                logs: dateLogs,
                exerciseNameMap: exerciseMap,
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
