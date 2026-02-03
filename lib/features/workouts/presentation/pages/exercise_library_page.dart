import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/common_empty_state.dart';
import '../providers/workout_create_provider.dart';
import '../providers/workout_provider.dart';

enum FilterType { all, recent }

class ExerciseLibraryPage extends HookConsumerWidget {
  const ExerciseLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchTerm = useState('');
    final filterType = useState(FilterType.all);

    final exercisesAsync = ref.watch(exercisesProvider);
    final logsAsync = ref.watch(allExerciseLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Exercícios')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => searchTerm.value = val,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: filterType.value == FilterType.all,
                  onSelected: (selected) {
                    if (selected) filterType.value = FilterType.all;
                  },
                ),
                FilterChip(
                  label: const Text('Recentes'),
                  selected: filterType.value == FilterType.recent,
                  onSelected: (selected) {
                    if (selected) filterType.value = FilterType.recent;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                var filtered = exercises
                    .where((e) => e.name
                        .toLowerCase()
                        .contains(searchTerm.value.toLowerCase()))
                    .toList();

                if (filterType.value == FilterType.recent) {
                   final recentIds = logsAsync.value?.map((l) => l.exerciseId).toSet() ?? {};
                   filtered = filtered.where((e) => recentIds.contains(e.id)).toList();
                }

                if (filtered.isEmpty) {
                  return const CommonEmptyState(
                    title: 'Nenhum exercício encontrado',
                    message: 'Tente buscar com outro termo ou alterar o filtro.',
                    icon: Icons.search_off,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                             color: Theme.of(context).colorScheme.surfaceContainerHighest,
                             borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: exercise.image != null
                              ? CachedNetworkImage(
                                  imageUrl: exercise.image!,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.fitness_center),
                                )
                              : const Icon(Icons.fitness_center),
                        ),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          exercise.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/exercise-details', extra: exercise);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Erro: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
