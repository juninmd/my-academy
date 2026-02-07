import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/common_empty_state.dart';
import '../../domain/utils/muscle_group_mapper.dart';
import '../providers/favorites_provider.dart';
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
    final selectedMuscleGroup = useState<String?>(null);
    final showFavoritesOnly = useState(false);

    final exercisesAsync = ref.watch(exercisesProvider);
    final logsAsync = ref.watch(allExerciseLogsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final favorites = favoritesAsync.value ?? {};

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
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: filterType.value == FilterType.all && !showFavoritesOnly.value && selectedMuscleGroup.value == null,
                  onSelected: (selected) {
                    if (selected) {
                      filterType.value = FilterType.all;
                      showFavoritesOnly.value = false;
                      selectedMuscleGroup.value = null;
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Recentes'),
                  selected: filterType.value == FilterType.recent,
                  onSelected: (selected) {
                     filterType.value = selected ? FilterType.recent : FilterType.all;
                     if (selected) {
                       showFavoritesOnly.value = false;
                       selectedMuscleGroup.value = null;
                     }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Favoritos'),
                  selected: showFavoritesOnly.value,
                  avatar: Icon(
                    showFavoritesOnly.value ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: showFavoritesOnly.value ? Colors.red : null,
                  ),
                  onSelected: (selected) {
                    showFavoritesOnly.value = selected;
                    if (selected) {
                      filterType.value = FilterType.all;
                      // Keep muscle group selected if user wants "Favorite Chest Exercises"
                    }
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                ...['Peito', 'Costas', 'Pernas', 'Ombros', 'Bíceps', 'Tríceps', 'Core', 'Outros'].map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(group),
                      selected: selectedMuscleGroup.value == group,
                      onSelected: (selected) {
                        selectedMuscleGroup.value = selected ? group : null;
                        if (selected) {
                          filterType.value = FilterType.all;
                        }
                      },
                    ),
                  );
                }),
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

                final recentIds = logsAsync.value?.map((l) => l.exerciseId).toSet() ?? {};

                if (filterType.value == FilterType.recent) {
                   filtered = filtered.where((e) => recentIds.contains(e.id)).toList();
                }

                if (showFavoritesOnly.value) {
                  filtered = filtered.where((e) => favorites.contains(e.id)).toList();
                }

                if (selectedMuscleGroup.value != null) {
                  filtered = filtered.where((e) => MuscleGroupMapper.getMuscleGroup(e.name) == selectedMuscleGroup.value).toList();
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
                    final isRecent = recentIds.contains(exercise.id);
                    final isFav = favorites.contains(exercise.id);
                    final muscleGroup = MuscleGroupMapper.getMuscleGroup(exercise.name);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      surfaceTintColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isRecent
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.1),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push('/exercise-details', extra: exercise);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
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
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exercise.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (isRecent)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius: BorderRadius.circular(
                                                  8),
                                            ),
                                            child: Text(
                                              'Recente',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondaryContainer,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            muscleGroup,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  ref.read(favoritesProvider.notifier).toggleFavorite(exercise.id);
                                },
                              ),
                            ],
                          ),
                        ),
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
