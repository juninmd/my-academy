import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/workout_provider.dart';
import '../progress_chart.dart';

class WorkoutHistoryView extends HookConsumerWidget {
  const WorkoutHistoryView({required this.exerciseId, super.key});
  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(exerciseLogsProvider(exerciseId));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('Nenhum histórico encontrado'));
        }
        return Column(
          children: [
            if (logs.length >= 2)
              SizedBox(
                height: 200,
                child: ProgressChart(logs: logs),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 100, top: 16),
                itemCount: logs.length,
                separatorBuilder: (c, i) => const Divider(),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    title: Text(DateFormat('dd/MM/yyyy HH:mm').format(log.date)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...log.sets.asMap().entries.map((e) => Text(
                          'Série ${e.key + 1}: ${e.value.reps} reps @ ${e.value.weight}kg (RPE: ${e.value.rpe ?? "-"})',
                        )),
                        if (log.notes != null && log.notes!.isNotEmpty)
                           Text('Notas: ${log.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
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
