import 'package:flutter/material.dart';

class WorkoutWarmupList extends StatelessWidget {
  const WorkoutWarmupList({required this.warmupSetsNotifier, super.key});

  final ValueNotifier<List<Map<String, dynamic>>> warmupSetsNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: warmupSetsNotifier,
      builder: (context, sets, _) {
        if (sets.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.whatshot, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Aquecimento',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...sets.asMap().entries.map((e) {
              final index = e.key;
              final set = e.value;
              final isCompleted = set['completed'] as bool;

              return GestureDetector(
                onTap: () {
                   final newSets = List<Map<String, dynamic>>.from(sets);
                   newSets[index] = {...set, 'completed': !isCompleted};
                   warmupSetsNotifier.value = newSets;
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCompleted
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted ? Colors.orange : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${set['reps']} reps',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('x', style: TextStyle(color: Colors.grey)),
                      ),
                      Text('${set['weight']} kg'),
                      const Spacer(),
                      if (isCompleted)
                        const Icon(Icons.check, size: 16, color: Colors.orange),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
