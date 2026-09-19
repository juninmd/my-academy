import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/common_empty_state.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../domain/entities/set_log_entity.dart';
import '../../../../utils/one_rep_max_calculator.dart';
import '../providers/workout_provider.dart';
import '../widgets/progress_chart.dart';
import '../widgets/exercise_personal_records_widget.dart';
import '../../../../core/widgets/app_image.dart';

class ExerciseDetailsPage extends HookConsumerWidget {
  const ExerciseDetailsPage({required this.exercise, super.key});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(exerciseLogsProvider(exercise.id));
    final chartMetric = useState(ChartMetric.oneRM);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                exercise.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (exercise.image != null)
                    AppImage(source: exercise.image!, fit: BoxFit.cover)
                  else
                    Container(color: Theme.of(context).primaryColor),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Personal Records Section
          SliverToBoxAdapter(
            child: logsAsync.when(
              data: (logs) {
                if (logs.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ExercisePersonalRecordsWidget(logs: logs),
                );
              },
              loading: () => const SizedBox(height: 100),
              error: (e, s) => const SizedBox.shrink(),
            ),
          ),

          // Chart Section
          SliverToBoxAdapter(
            child: logsAsync.when(
              data: (logs) {
                if (logs.length < 2) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progresso',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SegmentedButton<ChartMetric>(
                            segments: const [
                              ButtonSegment(
                                value: ChartMetric.oneRM,
                                label: Text(
                                  '1RM',
                                  style: TextStyle(fontSize: 12),
                                ),
                                icon: Icon(Icons.show_chart, size: 16),
                              ),
                              ButtonSegment(
                                value: ChartMetric.volume,
                                label: Text(
                                  'Volume',
                                  style: TextStyle(fontSize: 12),
                                ),
                                icon: Icon(Icons.bar_chart, size: 16),
                              ),
                            ],
                            selected: {chartMetric.value},
                            onSelectionChanged: (
                              Set<ChartMetric> newSelection,
                            ) {
                              chartMetric.value = newSelection.first;
                            },
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: ProgressChart(
                          logs: logs,
                          metric: chartMetric.value,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
          ),

          // Tips & Mistakes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exercise.tips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'Dicas de Execução',
                      items: exercise.tips,
                      icon: Icons.lightbulb_outline,
                      color: Colors.amber,
                    ),
                  ],
                  if (exercise.mistakes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'Erros Comuns',
                      items: exercise.mistakes,
                      icon: Icons.error_outline,
                      color: Colors.redAccent,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Histórico de Treinos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: CommonEmptyState(
                      icon: Icons.history,
                      title: 'Nenhum registro encontrado',
                      message: 'O histórico de treinos aparecerá aqui.',
                    ),
                  ),
                );
              }
              // Sort logs descending (newest first)
              final sortedLogs = List<ExerciseLogEntity>.from(logs)
                ..sort((a, b) => b.date.compareTo(a.date));

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final log = sortedLogs[index];
                  return _LogCard(log: log);
                }, childCount: sortedLogs.length),
              );
            },
            loading:
                () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Text('Erro ao carregar histórico: $err'),
                  ),
                ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: color.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  item,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log});
  final ExerciseLogEntity log;

  @override
  Widget build(BuildContext context) {
    // Find best set (highest 1RM)
    SetLogEntity? bestSet;
    double max1RM = 0;
    double totalVolume = 0;

    for (final set in log.sets) {
      final rm = OneRepMaxCalculator.calculateEpley(
        set.weight.toDouble(),
        set.reps,
      );
      if (rm > max1RM) {
        max1RM = rm;
        bestSet = set;
      }
      totalVolume += set.weight * set.reps;
    }

    final dateFormat = DateFormat('dd/MM/yyyy • HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            dateFormat.format(log.date),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                _StatBadge(
                  icon: Icons.layers,
                  text: '${log.sets.length} séries',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                if (bestSet != null)
                  _StatBadge(
                    icon: Icons.star,
                    text: '${bestSet.weight}kg x ${bestSet.reps}',
                    color: Colors.amber,
                  ),
                const SizedBox(width: 12),
                _StatBadge(
                  icon: Icons.fitness_center,
                  text: '${(totalVolume / 1000).toStringAsFixed(1)}t',
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  ...log.sets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;
                    final isBest = set == bestSet;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '${set.weight} kg',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('x'),
                                const SizedBox(width: 8),
                                Text('${set.reps} reps'),
                              ],
                            ),
                          ),
                          if (isBest)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (log.notes != null && log.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notas',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(log.notes!),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
