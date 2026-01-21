import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/exercise_log_entity.dart';
import '../../domain/entities/set_log_entity.dart';
import '../../../../utils/one_rep_max_calculator.dart';
import '../providers/workout_provider.dart';

class ExerciseStatsPage extends ConsumerWidget {
  const ExerciseStatsPage({required this.exercise, super.key});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(exerciseLogsProvider(exercise.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(exercise.name),
              background: exercise.image != null
                  ? CachedNetworkImage(
                      imageUrl: exercise.image!,
                      fit: BoxFit.cover,
                      color: Colors.black45,
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(color: Theme.of(context).primaryColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exercise.tips.isNotEmpty) ...[
                    Text(
                      'Dicas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...exercise.tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 20, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                  if (exercise.mistakes.isNotEmpty) ...[
                    Text(
                      'Erros Comuns',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...exercise.mistakes.map((mistake) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 20, color: Colors.redAccent),
                              const SizedBox(width: 8),
                              Expanded(child: Text(mistake)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Histórico',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Nenhum registro encontrado.')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = logs[index];
                    return _LogCard(log: log);
                  },
                  childCount: logs.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Erro ao carregar histórico: $err')),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
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

    for (final set in log.sets) {
      final rm = OneRepMaxCalculator.calculateEpley(
        set.weight.toDouble(),
        set.reps,
      );
      if (rm > max1RM) {
        max1RM = rm;
        bestSet = set;
      }
    }

    final dateFormat = DateFormat('dd/MM/yyyy • HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(log.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (bestSet != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Melhor Série',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${bestSet.weight.toStringAsFixed(1)}kg x ${bestSet.reps}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('1RM Est.'),
                        Text(
                          '${max1RM.toStringAsFixed(1)}kg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Notas:',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(log.notes!),
            ],
          ],
        ),
      ),
    );
  }
}
