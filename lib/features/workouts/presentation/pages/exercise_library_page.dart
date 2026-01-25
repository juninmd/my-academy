import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/workout_create_provider.dart';

class ExerciseLibraryPage extends HookConsumerWidget {
  const ExerciseLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchTerm = useState('');
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de Exercícios')),
      body: Column(
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
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filtered = exercises
                    .where((e) => e.name
                        .toLowerCase()
                        .contains(searchTerm.value.toLowerCase()))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Nenhum exercício encontrado'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (c, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                           color: Theme.of(context).colorScheme.surfaceContainerHighest,
                           borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: exercise.image != null
                            ? CachedNetworkImage(
                                imageUrl: exercise.image!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.fitness_center),
                              )
                            : const Icon(Icons.fitness_center),
                      ),
                      title: Text(exercise.name),
                      subtitle: Text(exercise.description ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/exercise-details', extra: exercise);
                      },
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
