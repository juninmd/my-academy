import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../workouts/presentation/providers/workout_provider.dart';
import '../../../workouts/presentation/providers/workout_create_provider.dart';
import '../../../workouts/domain/utils/muscle_group_mapper.dart';
import '../providers/dashboard_stats_provider.dart';

class DailyInsightCard extends ConsumerWidget {
  const DailyInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allExerciseLogsProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return logsAsync.when(
      data: (logs) {
        return statsAsync.when(
          data: (stats) {
            return exercisesAsync.when(
              data: (exercises) {
                String insightText = 'Pronto para o próximo treino? Lembre-se de manter a hidratação.';
                IconData insightIcon = Icons.lightbulb_outline;
                Color insightColor = Colors.amber;

                final now = DateTime.now();
                final startOfToday = DateTime(now.year, now.month, now.day);

                // Get yesterday's logs
                final yesterdayLogs = logs.where((l) {
                   final logDate = DateTime(l.date.year, l.date.month, l.date.day);
                   return startOfToday.difference(logDate).inDays == 1;
                }).toList();

                if (stats.streak > 3) {
                  insightText = 'Você está com uma ofensiva de ${stats.streak} dias! Incrível, mantenha o foco!';
                  insightIcon = Icons.local_fire_department;
                  insightColor = Colors.deepOrange;
                } else if (yesterdayLogs.isNotEmpty) {
                  // Figure out what they trained yesterday
                  final Map<int, String> exerciseMap = {for (var e in exercises) e.id: e.name};
                  final Map<String, int> muscleCounts = {};
                  for (final log in yesterdayLogs) {
                    final name = exerciseMap[log.exerciseId];
                    if (name != null) {
                      final group = MuscleGroupMapper.getMuscleGroup(name);
                      if (group != 'Outros') {
                         muscleCounts[group] = (muscleCounts[group] ?? 0) + 1;
                      }
                    }
                  }

                  if (muscleCounts.isNotEmpty) {
                    // Find the most trained muscle
                    final mostTrained = muscleCounts.keys.reduce((a, b) => muscleCounts[a]! > muscleCounts[b]! ? a : b);
                    insightText = 'Você treinou $mostTrained ontem. Considere descansar essa região hoje!';
                    insightIcon = Icons.info_outline;
                    insightColor = Colors.blue;
                  }
                } else if (stats.workoutsThisWeek >= stats.weeklyGoal) {
                   insightText = 'Meta semanal concluída! Qualquer treino extra agora é puro lucro na sua evolução.';
                   insightIcon = Icons.star_border;
                   insightColor = Colors.purple;
                } else if (logs.isEmpty) {
                   insightText = 'Seja bem-vindo! Faça seu primeiro treino e comece a registrar seu progresso.';
                   insightIcon = Icons.waving_hand;
                   insightColor = Colors.green;
                }

                final isDark = Theme.of(context).brightness == Brightness.dark;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: insightColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  color: isDark
                    ? insightColor.withValues(alpha: 0.1)
                    : insightColor.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: insightColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(insightIcon, color: insightColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dica do Dia',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: insightColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                insightText,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
