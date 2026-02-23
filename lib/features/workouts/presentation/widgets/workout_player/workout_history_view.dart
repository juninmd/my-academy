import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/workout_provider.dart';
import '../../../domain/entities/set_log_entity.dart';
import '../progress_chart.dart';
import '../../../../../core/widgets/common_empty_state.dart';

class WorkoutHistoryView extends HookConsumerWidget {
  const WorkoutHistoryView({required this.exerciseId, super.key});
  final int exerciseId;

  Color _getTypeColor(SetType type) {
    switch (type) {
      case SetType.warmup:
        return Colors.orange;
      case SetType.dropset:
        return Colors.purple;
      case SetType.failure:
        return Colors.red;
      case SetType.normal:
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(SetType type) {
    switch (type) {
      case SetType.warmup:
        return 'Aquecimento';
      case SetType.dropset:
        return 'Drop Set';
      case SetType.failure:
        return 'Falha';
      case SetType.normal:
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(exerciseLogsProvider(exerciseId));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const CommonEmptyState(
            title: 'Sem Histórico',
            message:
                'Complete este exercício pela primeira vez para ver seu progresso aqui.',
            icon: Icons.history,
          );
        }
        return Column(
          children: [
            if (logs.length >= 2)
              SizedBox(height: 200, child: ProgressChart(logs: logs)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 100, top: 16),
                itemCount: logs.length,
                separatorBuilder: (c, i) => const Divider(),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    title: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(log.date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        ...log.sets.asMap().entries.map((e) {
                          final set = e.value;
                          final typeLabel = _getTypeLabel(set.type);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  'Série ${e.key + 1}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${set.reps} reps @ ${set.weight}kg',
                                ),
                                if (set.rpe != null)
                                  Text(
                                    ' (RPE: ${set.rpe})',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                if (typeLabel.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(
                                        set.type,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      typeLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getTypeColor(set.type),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        if (log.notes != null && log.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sticky_note_2_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${log.notes}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar histórico: $e')),
    );
  }
}
