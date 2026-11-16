import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/suggestion_provider.dart';

/// "Next time" target for an exercise, from the server's progression rules.
class SuggestionCard extends ConsumerWidget {
  const SuggestionCard({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestion = ref.watch(suggestionProvider(exerciseId));
    return suggestion.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (s) {
        if (s == null) return const SizedBox.shrink();
        return Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: Icon(s.deload ? Icons.trending_down : Icons.trending_up),
            title: Text(
              'Próxima vez: ${s.sets} × ${s.reps} com ${s.weight.toStringAsFixed(1)} kg',
            ),
            subtitle: Text(s.reason),
          ),
        );
      },
    );
  }
}
