import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../../utils/one_rep_max_calculator.dart';
import '../../domain/entities/exercise_entity.dart';
import '../providers/workout_create_provider.dart';
import '../providers/workout_provider.dart';

class AnalyticsPage extends HookConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      initializeDateFormatting('pt_BR', null);
      return null;
    }, []);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Análise de Progresso'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Progresso', icon: Icon(Icons.bar_chart)),
              Tab(text: 'Recordes', icon: Icon(Icons.emoji_events)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProgressTab(),
            _RecordsTab(),
          ],
        ),
      ),
    );
  }
}

class _ProgressTab extends HookConsumerWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allExerciseLogsProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(
            child: Text('Nenhum dado de treino registrado ainda.'),
          );
        }

        // Calculate chart data, memoized to prevent expensive recalculation on every rebuild.
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final chartData = useMemoized(() {
          final lowerBound = today.subtract(const Duration(days: 6));
          final upperBound = today.add(const Duration(days: 1));

          final Map<int, double> volumePerDay = {};
          final Map<int, int> setsPerDay = {};

          for (var log in logs) {
            // Check bounds efficiently without creating new DateTime objects
            if (log.date.compareTo(lowerBound) >= 0 &&
                log.date.isBefore(upperBound)) {
              // Calculate index based on difference from start of the window
              final dayIndex = log.date.difference(lowerBound).inDays;
              if (dayIndex >= 0 && dayIndex < 7) {
                // Volume
                final volume = log.sets.fold<double>(
                  0,
                  (sum, set) => sum + (set.weight * set.reps),
                );
                volumePerDay[dayIndex] =
                    (volumePerDay[dayIndex] ?? 0) + volume;

                // Sets
                setsPerDay[dayIndex] =
                    (setsPerDay[dayIndex] ?? 0) + log.sets.length;
              }
            }
          }
          return (volume: volumePerDay, sets: setsPerDay);
        }, [logs, today]);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVolumeChart(context, chartData.volume),
              const SizedBox(height: 24),
              _buildWorkoutFrequencyChart(context, chartData.sets),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro ao carregar dados: $e')),
    );
  }

  Widget _buildVolumeChart(
    BuildContext context,
    Map<int, double> volumePerDay,
  ) {
    // Labels for the last 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    final barGroups = List.generate(7, (index) {
      final volume = volumePerDay[index] ?? 0;
      final displayValue = volume / 1000.0; // Tonnes

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: displayValue,
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final maxVolume = barGroups.fold<double>(
      0,
      (max, group) => group.barRods[0].toY > max ? group.barRods[0].toY : max,
    );
    final maxY = maxVolume == 0 ? 1.0 : maxVolume * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume (Toneladas) - Últimos 7 dias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = last7Days[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat.E(
                                'pt_BR',
                              ).format(date)[0].toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutFrequencyChart(
    BuildContext context,
    Map<int, int> setsPerDay,
  ) {
    // Labels for the last 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    final barGroups = List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (setsPerDay[index] ?? 0).toDouble(),
            color: Theme.of(context).colorScheme.secondary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final maxSets = barGroups.fold<double>(
      0,
      (max, group) => group.barRods[0].toY > max ? group.barRods[0].toY : max,
    );
    final maxY = maxSets == 0 ? 1.0 : maxSets * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Séries Realizadas - Últimos 7 dias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = last7Days[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat.E(
                                'pt_BR',
                              ).format(date)[0].toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordsTab extends HookConsumerWidget {
  const _RecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allExerciseLogsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return logsAsync.when(
      data: (logs) {
        return exercisesAsync.when(
          data: (exercises) {
            if (logs.isEmpty) {
              return const Center(child: Text('Sem recordes ainda. Treine mais!'));
            }

            final prs = useMemoized(() {
              final Map<int, _PRItem> bests = {};

              for (var log in logs) {
                for (var set in log.sets) {
                  final oneRM = OneRepMaxCalculator.calculateEpley(
                    set.weight.toDouble(),
                    set.reps,
                  );

                  // If no entry or new 1RM is higher, update
                  if (!bests.containsKey(log.exerciseId) ||
                      oneRM > bests[log.exerciseId]!.weight) {

                    final exercise = exercises
                        .where((e) => e.id == log.exerciseId)
                        .firstOrNull;

                    if (exercise != null) {
                       bests[log.exerciseId] = _PRItem(
                        exerciseName: exercise.name,
                        weight: oneRM,
                        date: log.date,
                        actualSet: '${set.weight.toStringAsFixed(1)}kg x ${set.reps}',
                      );
                    }
                  }
                }
              }
              // Sort by date descending (newest PRs first)
              final list = bests.values.toList();
              list.sort((a, b) => b.date.compareTo(a.date));
              return list;
            }, [logs, exercises]);

            if (prs.isEmpty) {
              return const Center(child: Text('Nenhum recorde encontrado.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prs.length,
              itemBuilder: (context, index) {
                final pr = prs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, color: Colors.amber),
                    ),
                    title: Text(
                      pr.exerciseName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${DateFormat('dd/MM/yyyy').format(pr.date)} • ${pr.actualSet}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '1RM Est.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          '${pr.weight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Center(child: Text('Erro ao carregar exercícios')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Erro ao carregar logs')),
    );
  }
}

class _PRItem {
  final String exerciseName;
  final double weight;
  final DateTime date;
  final String actualSet;

  _PRItem({
    required this.exerciseName,
    required this.weight,
    required this.date,
    required this.actualSet,
  });
}
